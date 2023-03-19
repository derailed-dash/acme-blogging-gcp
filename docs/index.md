---
layout: default
title: Introduction
---
<img src="{{'/assets/images/mini-drone.gif' | relative_url }}" alt="Drone" style="margin:15px 10px 10px 15px; float: right; width:255px" />

# {{ page.title }}

This site has been created to document my approach to sample **Acme Ltd** case study.

Here I will:

- Capture the requirements and assumptions.
- Present solution options and rationale for selected options.
- Present a business case for the solution.
- Present a brief overall design.
- Point to the GitHub repo where this solution is stored.

To proceed, please follow the navigation links above.

## Some Key Links

- [This documentation site](https://acme-blogging-docs.just2good.co.uk/)
- [Repo on GitHub](https://github.com/derailed-dash/acme-blogging-gcp){:target="_blank"}
- The Demo Application, on GCP (now decommissioned, as there's a cost to running it!)
  - [Billing Dashboard](https://datastudio.google.com/u/0/reporting/a0f62bfa-ba65-46d8-aa15-e121c834150e){:target="_blank"}
  - [Dev-1 Environment Ghost Application](https://dev-1.acme-blogging.just2good.co.uk/){:target="_blank"}
  - [Cloud Function Posts-Get (access requires an account within the demo organisation)](https://europe-west2-prj-ghost-dev-1-2eb70c61.cloudfunctions.net/ghost-func-posts-get){:target="_blank"}

## Repo Layout

```bash
.
├── docs                              # The documentation website src for ths repo
│   ├── pages                           # Content pages
│   ├── _data                           # Lookups, e.g. site navigation
│   ├── _layouts                        # Page templates
│   └── assets                          # Styling and images
├── iac                               # IaC
│   ├── 0-infra-bootstrap               # Create the Terraform bootstrap project, service account and permissions
│   ├── 1-cloud-build-shared-services   # Create the project for hosting the Cloud Build CI/CD pipeline
│   ├── 2-project-factory-init          # Terraform Project Factory for creating repeatable project environments
│   ├── 3-project-factory-network       # Terraform for deploying standard networking to the project
│   ├── 4-app-infra-db                  # Terraform for deploying HA DB, and DB secrets
│   └── 5-app-infra-frontend            # Terraform for deploying Ghost app servers, MIGs, load balancer
├── purge-app                         # Application for viewing and purging Ghost posts, written in Python.
│   └── tf-purge-app                     # Terraform for deploying Cloud Functions; expected to be triggered by Cloud Build
└── README.md                         # Repo readme
```

## About Me

My name is Darren Lester. I am an experienced enterprise architect with a focus on technology, cloud, and hosting infrastructure.

The content presented here is my own work.  It is the accompanying documentation (e.g. solution options, solution design, deployment instructions, etc) for a case study I have implemented using Google Cloud.

Check out some of my other content:

- [My GitHub Homepage](https://github.com/derailed-dash){:target="_blank"}
- [My Blog](https://content.just2good.co.uk/){:target="_blank"}
- [My Content on Medium](https://medium.com/@derailed.dash){:target="_blank"}


