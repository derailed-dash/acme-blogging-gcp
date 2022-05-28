# Acme Blogging App Case Study Repo

## Documentation Site

**See [Acme Blogging App Case Study Documentation](https://acme-blogging-docs.just2good.co.uk/)**

## Structure

```bash
.
├── docs                               # The documentation website src for ths repo
│   ├── pages                            # Content pages
│   ├── _data                            # Lookups, e.g. site navigation
│   ├── _layouts                         # Page templates
│   └── assets                           # Styling and images
├── iac                                # IaC
│   ├── 0-infra-bootstrap                # Create the Terraform bootstrap project, service account and permissions
│   ├── 1-cloud-build-shared-services    # Create the project for hosting the Cloud Build CI/CD pipeline
│   ├── 2-project-factory-init           # Terraform Project Factory for creating repeatable project environments
│   ├── 3-project-factory-network        # Terraform for deploying standard networking to the project
│   ├── 4-app-infra-db                   # Terraform for deploying HA DB, and DB secrets
│   └── 5-app-infra-frontend             # Terraform for deploying Ghost app servers, MIGs, load balancer
├── purge-app                         # Application for viewing and purging Ghost posts, written in Python.
│   └── tf-purge-app                     # Terraform for deploying Cloud Functions; expected to be triggered by Cloud Build
└── README.md                          # This file
```