#! /bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_RUN=Oorah
sudo apt-get update

sudo apt-get install -y jq # json processor

# Install node.js
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash
sudo apt-get install -y nodejs
sudo apt autoremove -y

# install nginx
sudo apt-get install -y nginx
ufw allow 'Nginx Full'

# Install Ghost-CLI
sudo npm install ghost-cli@latest -g

NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')
cat <<- EOF > /var/www/html/index.html
  <!doctype html>
  <html><head><title>${labels.application} World!</title></head>
  <body>
  <h1>${labels.application}!</h1>
  <h2>Machine Instrospection</h2>
  <pre>
  Name: $NAME
  IP: $IP
  </pre>
  <h2>Labels:</h2>
  <p>
  %{ for label_key, label_value in labels ~}
  ${label_key} = ${label_value}<br/>
  %{ endfor ~}
  </p>
  </body>
EOF