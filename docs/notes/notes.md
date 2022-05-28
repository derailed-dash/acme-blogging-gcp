# Billing

```sql
SELECT  FROM `acme-infra-admin-6821.billing_export_dataset.gcp_billing_export_v1_012345-6789AB-CDEF01` WHERE DATE(_PARTITIONTIME) = "2022-04-28" LIMIT 1000
```

```sql
SELECT
  project.name,
  TO_JSON_STRING(project.labels) as project_labels,
  sum(cost) as total_cost,
  SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits) c), 0)) as total_credits
FROM `acme-infra-admin-6821.billing_export_dataset.gcp_billing_export_v1_012345-6789AB-CDEF01`
WHERE invoice.month = "202204"
GROUP BY name, project_labels
ORDER BY total_cost desc;
```

# Shutting down for the night

Turn off auto scaling and remove health check from auto healing, in the MIG.
Set min instances to 0.
The shut down the instances.

VM instances --> Instance group --> edit ghost-mig-1 --> Auto-healing off, Auto-scaling, off
                                --> In use by lb-backend-service --> In use by lb-ghost --> 

# Cloud SQL Testing Local

## Get and install the proxy

See here for how to connect with Auth Proxy:
https://cloud.google.com/sql/docs/mysql/connect-admin-proxy#authentication-options

```
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O ~/cloud_sql_proxy
chmod +x ~/cloud_sql_proxy
```

```
export DB_HOST='127.0.0.1:3306'
export DB_USER='root'
export DB_NAME='ghost'
```

## Running the Cloud SQL proxy

```
./cloud_sql_proxy -instances=<project-id>:<region>:<instance-name>=tcp:3306 -credential_file=$GOOGLE_APPLICATION_CREDENTIALS &

~/cloud_sql_proxy -instances=prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137=tcp:0.0.0.0:3306 &

./cloud_sql_proxy -instances=prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137=tcp:3306 -credential_file=cred.json &

# IP in the container
./cloud_sql_proxy -instances=INSTANCE_CONNECTION_NAME=tcp:172.17.0.1:3306
```

Or if we want to connect using Unix socket rather than TCP:

```
mkdir /cloudsql
sudo chmod 777 /cloudsql
/cloud_sql_proxy -dir=/cloudsql -instances=prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137 &
```

## Testing with the mysql Client

MySQL client stuff: https://dev.mysql.com/doc/refman/8.0/en/retrieving-data.html

```
apt install mysql-client
```

```
mysql -u root -p --host 127.0.0.1
```

OR with Unix socket:

```
mysql -u ghost -p -S /cloudsql/prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137
```

Testing some SQL:

```sql
select version();
select user();
show databases;
```

```sql
use ghostdb;
show tables;
select id, title, author_id, created_at from posts;
```

OR

```sql
select id, title, author_id, created_at from ghostdb.posts;
```

Or from Cloud Shell: you can't.  Cloud Shell is in a different VPC. Use a bastion.

# Cloud Functions

## Roles and Permissions 

I've added Cloud Functions Admin to 800117839038@cloudbuild.gserviceaccount.com at org level

## Launching

```
gcloud functions deploy hello_get --runtime python39 --trigger-http --allow-unauthenticated
gcloud functions deploy hello_get --runtime python39 --trigger-http

gcloud functions describe hello_get
gcloud functions delete hello_get
```

### With Serverless VPC Connection

We can restrict access to the Cloud Function by only allowing access from within the VPC, in the same VPC and same project.
So, we can just limit it to users on the bastion! Or we build a frontend.

```
gcloud functions deploy ghost_posts_get --project=prj-ghost-dev-1-2eb70c61 \
  --runtime python39 \
  --trigger-http --allow-unauthenticated \
  --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn
```

Do this by adding --ingress-settings=internal-only

### From Source Repo

Now let's create the Cloud Function from source repo.  Source repo in the format:
```
https://source.developers.google.com/projects/${PROJECT_ID}/repos/${REPO}
```

E.g. 
```
https://source.developers.google.com/projects/cb-cloudbuild-6a53/repos/ghost-purge-app
```

But we seem to need this:
https://source.developers.google.com/projects/cb-cloudbuild-6a53/repos/ghost-purge-app/moveable-aliases/master/paths/

### With Env Vars

```
export db_conn_name="prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
export db_user='root'
export db_name='ghostdb'
```

Put them in .env.yaml:

```json
db_conn_name: "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
db_user: 'root'
db_name: 'ghostdb'
```

Then:

```
gcloud functions deploy ghost_posts_get --project=prj-ghost-dev-1-2eb70c61 --runtime python39 --trigger-http \
  --allow-unauthenticated --ingress-settings=internal-only --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn \
  --env-vars-file .env.yaml
```

And now with secret:

```
gcloud functions deploy ghost_posts_get --project=prj-ghost-dev-1-2eb70c61 --runtime python39 --trigger-http \
  --allow-unauthenticated --ingress-settings=internal-only --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn \
  --env-vars-file .env.yaml --set-secrets=db_pwd=projects/197270889644/secrets/db_pwd/versions/latest
```

And now with source:

```
gcloud functions deploy ghost_posts_get --project=prj-ghost-dev-1-2eb70c61 --runtime python39 --trigger-http \
  --allow-unauthenticated --ingress-settings=internal-only --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn \
  --env-vars-file .env.yaml --set-secrets=db_pwd=projects/197270889644/secrets/db_pwd/versions/latest \
  --source=https://source.developers.google.com/projects/cb-cloudbuild-6a53/repos/ghost-purge-app/moveable-aliases/master/paths/

gcloud functions deploy ghost_posts_purge --project=prj-ghost-dev-1-2eb70c61 --runtime python39 --trigger-http \
  --allow-unauthenticated --ingress-settings=internal-only --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn \
  --env-vars-file .env.yaml --set-secrets=db_pwd=projects/197270889644/secrets/db_pwd/versions/latest \
  --source=https://source.developers.google.com/projects/cb-cloudbuild-6a53/repos/ghost-purge-app/moveable-aliases/master/paths/
```

## Testing

```
curl https://europe-west2-prj-ghost-dev-1-2eb70c61.cloudfunctions.net/ghost_posts_get

curl -X POST "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/FUNCTION_NAME" -H "Content-Type:application/json" --data '{"name":"Keyboard Cat"}'
```

## Connecting Functions to Cloud SQL

https://cloud.google.com/sql/docs/mysql/connect-functions

# Some Blog URLs

Admin: https://acme-blogging.just2good.co.uk.co.uk/ghost
https://acme-blogging.just2good.co.uk.co.uk/ghost/#/posts

https://dev-1.acme-blogging.just2good.co.uk.co.uk/
https://acme-blogging.just2good.co.uk.co.uk/woop-the-drones-are-here/
https://acme-blogging.just2good.co.uk.co.uk/author/dazbo/

We can back up in Cloud SQL, purge the data, and then restore.

# Certs

## DNS Checks

Use dnschecker.og.

## Cert Provisioning
It can take 10 minutes for the provisioning, and then maybe another 30 mins before this goes away on the client:
ERR_SSL_VERSION_OR_CIPHER_MISMATCH

Testing:

```
echo | openssl s_client -showcerts -servername acme-blogging.just2good.co.uk.co.uk -connect 34.117.164.145:443 -verify 99 -verify_return_error
```

SSL Test:
https://www.ssllabs.com/ssltest/analyze.html?d=acme-blogging.just2good.co.uk.co.uk&hideResults=on

## Error With Service Account Key Credentials?

```
gcloud iam service-accounts keys create ~/cred.json --iam-account 197270889644-compute@developer.gserviceaccount.com
ERROR: (gcloud.iam.service-accounts.keys.create) FAILED_PRECONDITION: Precondition check failed.
```

You've probably created to many keys!  Don't create a new key every time.  Store it in a secret and pull it in when needed.

# Ghost and Cloud SQL Proxy as Docker Container

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker-compose.yml

```json
version: '3'
services:
  cloudsql-proxy:
      container_name: cloudsql-proxy
      image: eu.gcr.io/cloudsql-docker/gce-proxy:1.28.0
      command: /cloud_sql_proxy -instances=prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137=tcp:0.0.0.0:3306 -credential_file=/secrets/cloudsql/cred.json
      ports:
        - 3306:3306
      volumes:
        - ./cred.json:/secrets/cloudsql/cred.json
      restart: always

  dazbo-ghost:
    image: eu.gcr.io/cb-cloudbuild-6a53/dazbo-ghost:0.1
    ports:
      - 80:2368
    environment:
      url: http://localhost:80
      database__client: mysql
      database__connection__host: cloudsql-proxy
      database__connection__user:ghost
      database__connection__password:ghost
      database__connection__database:ghostdb
    restart: always
```

https://stackoverflow.com/questions/45836831/is-there-a-way-to-access-google-cloud-sql-via-proxy-inside-docker-container

Interrogating the container:

```
djl@ghost-svr-0cd1:~$ ip addr show docker0
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:da:4b:6d:2b brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
```

This is the IP the container can see the host IP on.

```
mkdir /etc/ghost

cat <<- EOF > /etc/ghost/config.json
{
  "url": "http://localhost",
  "server": {
    "port": 2368,
    "host": "127.0.0.1"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "127.0.0.1",
      "port": 3306,
      "user": "ghost",
      "password": "ghost",
      "database": "ghostdb"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "file",
      "stdout"
    ]
  },
  "process": "systemd",
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  }
}
EOF

sudo docker pull eu.gcr.io/cb-cloudbuild-6a53/dazbo-ghost/4.44.0
```

To test: curl localhost

To inspect:
sudo docker exec -it dazbo-ghost sh

# Cloud Run Config

## VPC

Already have VPC Network Peering: servicenetworking-googleapis-com on the VPC
Already have private service connection: db-private-ip-2eb70c61, 10.225.0.0/16 on connection servicenetworking-googleapis-com

## SQL

database__client=mysql
database__connection__user=root
database__connection__password=${_DB_PWD} 
database__connection__socketPath=/cloudsql/<INSTANCE_CONNECTION_NAME>
database__connection__database=ghost
url=<HOSTNAME>

database__connection__socketPath=/cloudsql/prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137
prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137

prj-ghost-dev-1-2eb70c61:europe-west2:ghost-2eb70c61
projects/prj-ghost-dev-1-2eb70c61/global/networks/dev-1-vpc

prj-ghost-dev-1-2eb70c61:europe-west2:

With /cloudsql/ghost-2eb70c61 --> DatabaseError: connect ENOENT /cloudsql/ghost-2eb70c61
With /cloudsql/prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137 --> DatabaseError: Invalid database host.

# Useful properties

cb_project_id = "800117839038"
800117839038@cloudbuild.gserviceaccount.com
  - Needs iam.serviceaccounts.actAs on 197270889644-compute@developer.gserviceaccount.com

cb_gcr_id = "eu.artifacts.cb-cloudbuild-6a53.appspot.com"

parent_folder_id = {
  dev-1 = "713338487121"
  uat = "713338487121"
  prod = "1049973940464"
}

Dev-1 = prj-ghost-dev-1 = prj-ghost-dev-1-2eb70c61 = 197270889644

# Outputs

## Boostrap 0

```
cloudbuild_project_id = "prj-b-cicd-c7ed"
csr_repos = {
  "gcp-environments" = {
    "id" = "projects/prj-b-cicd-c7ed/repos/gcp-environments"
    "name" = "gcp-environments"
    "project" = "prj-b-cicd-c7ed"
    "pubsub_configs" = toset([])
    "size" = 0
    "timeouts" = null /* object */
    "url" = "https://source.developers.google.com/p/prj-b-cicd-c7ed/r/gcp-environments"
  }
  "gcp-networks" = {
    "id" = "projects/prj-b-cicd-c7ed/repos/gcp-networks"
    "name" = "gcp-networks"
    "project" = "prj-b-cicd-c7ed"
    "pubsub_configs" = toset([])
    "size" = 0
    "timeouts" = null /* object */
    "url" = "https://source.developers.google.com/p/prj-b-cicd-c7ed/r/gcp-networks"
  }
  "gcp-org" = {
    "id" = "projects/prj-b-cicd-c7ed/repos/gcp-org"
    "name" = "gcp-org"
    "project" = "prj-b-cicd-c7ed"
    "pubsub_configs" = toset([])
    "size" = 0
    "timeouts" = null /* object */
    "url" = "https://source.developers.google.com/p/prj-b-cicd-c7ed/r/gcp-org"
  }
  "gcp-projects" = {
    "id" = "projects/prj-b-cicd-c7ed/repos/gcp-projects"
    "name" = "gcp-projects"
    "project" = "prj-b-cicd-c7ed"
    "pubsub_configs" = toset([])
    "size" = 0
    "timeouts" = null /* object */
    "url" = "https://source.developers.google.com/p/prj-b-cicd-c7ed/r/gcp-projects"
  }
}
gcs_bucket_cloudbuild_artifacts = "prj-cloudbuild-artifacts-bcc8"
gcs_bucket_tfstate = "bkt-b-tfstate-ec19"
seed_project_id = "prj-b-seed-4178"
terraform_sa_name = "projects/prj-b-seed-4178/serviceAccounts/org-terraform@prj-b-seed-4178.iam.gserviceaccount.com"
terraform_service_account = "org-terraform@prj-b-seed-4178.iam.gserviceaccount.com"
terraform_validator_policies_repo = {
  "id" = "projects/prj-b-cicd-c7ed/repos/gcp-policies"
  "name" = "gcp-policies"
  "project" = "prj-b-cicd-c7ed"
  "pubsub_configs" = toset([])
  "size" = 0
  "timeouts" = null /* object */
  "url" = "https://source.developers.google.com/p/prj-b-cicd-c7ed/r/gcp-policies"
}
```

## 1 - Cloud Build Shared

```
cb_project_id = "cb-cloudbuild-6a53"
gcr_bucket_id = "eu.artifacts.cb-cloudbuild-6a53.appspot.com"
gcr_url = "eu.gcr.io/cb-cloudbuild-6a53"
```

## 2

```
project_info = {
  "auto_create_network" = true
  "billing_account" = "012345-6789AB-CDEF01"
  "folder_id" = "713338487121"
  "id" = "projects/prj-ghost-dev-1-2eb70c61"
  "labels" = tomap({})
  "name" = "prj-ghost-dev-1"
  "number" = "197270889644"
  "org_id" = ""
  "project_id" = "prj-ghost-dev-1-2eb70c61"
  "skip_delete" = tobool(null)
  "timeouts" = null /* object */
}
project_suffix = "2eb70c61"
```

## 3

```
bastion_pri_hostname = "bastion-pri"
vpc_network_id = "projects/prj-ghost-dev-1-2eb70c61/global/networks/dev-1-vpc"
```

## 4 terraform.tfvars

```
project_id = "prj-ghost-dev-1-2eb70c61"  # This is project ID, NOT project number
prj_suffix = "2eb70c61"
vpc_id = "projects/prj-ghost-dev-1-2eb70c61/global/networks/dev-1-vpc"

secret_ids = {
  "db_pwd" = "projects/prj-ghost-dev-1-2eb70c61/secrets/db_pwd"
}
secrets = {
  "db_pwd" = {
    "create_time" = "2022-04-23T21:13:17.128262Z"
    "expire_time" = ""
    "id" = "projects/prj-ghost-dev-1-2eb70c61/secrets/db_pwd"
    "labels" = tomap({})
    "name" = "projects/197270889644/secrets/db_pwd"
    "project" = "prj-ghost-dev-1-2eb70c61"
    "replication" = tolist([
      {
        "automatic" = true
        "user_managed" = tolist([])
      },
    ])
    "rotation" = tolist([])
    "secret_id" = "db_pwd"
    "timeouts" = null /* object */
    "topics" = tolist([])
    "ttl" = tostring(null)
  }
}
```

## 5

```
websvr_lb_ip = "34.117.164.145"
```

# How to Perform CI/CD Builds on a Branch

Deploying to multiple projects with Cloud Build: https://www.cyberithub.com/deploy-a-container-to-multiple-gcp-projects-and-host-with-cloud-run/
Cloud Build project: https://console.cloud.google.com/cloud-build/builds?project=prj-b-cicd-c7ed

```bash
git checkout -b plan
```

Make changes.

```bash
git add .
git commit -m "Some update message"
git push --set-upstream origin plan
```

Because branch `plan` is not a named environment branch, this only triggers a plan, but not an apply.

Review.
Merge.

```bash
git checkout -b production
git push origin production
```

# Cloud Run

gcloud cloud run deploy ref: https://cloud.google.com/sdk/gcloud/reference/run/deploy

## Errors

```
Step #2: ERROR: (gcloud.beta.run.deploy) PERMISSION_DENIED: Permission 'run.services.get' denied on resource 'namespaces/prj-ghost-dev-1-19e58fc7/services/ghost-service' (or resource may not exist).
```

## Grant the Cloud Run Admin role to the Cloud Build service account

gcloud projects add-iam-policy-binding $GC_PROJECT \
  --member "serviceAccount:$GC_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role roles/run.admin

## Grant the IAM Service Account User role to the Cloud Build service account on the Cloud Run runtime service account
 
Cloud Run Service Account = [PROJECT_NUMBER]-compute@developer.gserviceaccount.com, e.g. 898721639901-compute@developer.gserviceaccount.com

Cloud Build Service Account = [PROJECT_NUMBER]@cloudbuild.gserviceaccount.com, i.e. 164687367083@cloudbuild.gserviceaccount.com

