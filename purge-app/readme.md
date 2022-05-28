# Cloud Functions Python Applications

This folder contains:

- The purge application:
  - main.py - the Python code that defines Google Cloud Functions
    - ghost_posts_get - for retrieving posts in the DB
    - ghost_posts_purge - for purging the posts in the DB
  - requirements.txt - the Python packages required by the function
- tf-purge-app - The Terraform configuration to deploy the application as Cloud Functions
- cloudbuild.yaml - Configuration for Cloud Build to invoke the Terraform when triggered

Note that the Cloud Functions connect to the backend Cloud SQL DB.  For this reason, the Functions must utilise a Serverless VPC Connector, which will have been deployed in hte networking Terraform configuration.

## Typical Deployment

- A Cloud Build trigger will monitor for changes in the function source code.
- When the trigger fires, Cloud Build will copy the changed code to the project's source bucket.
- Cloud Build will then redeploy the functions.

## Manual Installation

With a command like this:

```bash
gcloud functions deploy ghost_posts_get --project=<target-prj> --runtime python39 --trigger-http --allow-unauthenticated --region=europe-west2 --vpc-connector=pri-serverless-vpc-conn
```