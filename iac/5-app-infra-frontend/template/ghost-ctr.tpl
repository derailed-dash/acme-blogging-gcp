#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

# json processor
sudo apt-get install -y jq 

# install mysql-client, in case we need it; note: we need Ubuntu for this! Won't work on Debian.
sudo apt install -y mysql-client

##################
# Install Docker #
##################
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# refresh now we've added the docker repo
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# authenticate docker to access GCR
gcloud auth configure-docker --quiet

# install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Obtain the compute SA private key from Secret Manager.
# We need to provide this to the Cloud SQL Auth Proxy in its container
# gcloud iam service-accounts keys create ~/cred.json --iam-account 197270889644-compute@developer.gserviceaccount.com
cat <<- EOF > ~/cred.json
${compute_sa_key}
EOF
chmod 644 ~/cred.json

###########################
# Assemble docker-compose #
###########################
cat <<- EOF > docker-compose.yml
version: '3'
services:
  cloudsql-proxy:
      container_name: cloudsql-proxy
      image: ${cloud-sql-proxy-img}
      command: /cloud_sql_proxy -instances=${db_conn_name}=tcp:0.0.0.0:3306 -credential_file=/secrets/cloudsql/cred.json
      ports:
        - 3306:3306
      volumes:
        - ~/cred.json:/secrets/cloudsql/cred.json
      restart: always

  dazbo-ghost:
    image: ${ghost-img}
    ports:
      - 80:2368
    environment:
      url: http://localhost
      database__client: mysql
      database__connection__host: cloudsql-proxy
      database__connection__user: root
      database__connection__password: "${db_pwd}"
      database__connection__database: ghostdb
    restart: always
EOF

# Launch our ghost service with its proxy sidecar
docker-compose up -d