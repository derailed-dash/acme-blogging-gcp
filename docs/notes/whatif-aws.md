# What If We Wanted to Host in AWS?

## Options and Design Decicions

### Application Frontend

- Options:
  - EC2 instances with Auto Scaling Group, EC2 Auto Scaler and Application LB (ALB)
    - ALB is cloud-native and HA.
    - Internet-facing
    - With TLS certificate (using ARN of the certificate)
    - LB to an Auto Scaling Target Group
    - Use a TargetTrackingScaling policy to auto scale based on CPU.
    - Will use a Health Check, looking for HTTP 200 responses
    - Install application
  - AWS Lightsail Virtual Private Server
    - Simplified server deployment experience
    - But doesn't support auto scaling.
  - Containerised application:
    - Elastic Container Service (ECS)
      - Fully managed container orchestration.
      - Deployed as clusters, running on top of either EC2 (supporting auto scaling groups) or AWS Fargate (supporting Fargate capacity providers).
      - Integratedw with LB, autoscaling, IAM, Networking, Monitoring, Logging
    - Elastic Kubernetes Service (EKS)
      - Fully managed Kubernetes
    - AWS Fargate (Serverless containers)
      - Serverless container hosting. 
      - No clusters.  No provisioning and managing of servers.
  - Elastic Beanstalk
  - For shared file (NFS): 
    - Amazon Elastic File Service (EFS). EFS is HA.
    - S3 - not sure if we have a connector.

### Pruning

- AWS Lambda
- AWS Elastic Beanstalk

### Persistence / DB

- Amazon RDS MySQL
  - Fully-managed, as with Google.
  - Offers multi-AZ implementation as well as dual region DR.

### Networking

- VPC: Amazon VPC
  - Note that VPCs in Amazon are regional, not global.
  - Subnets are zonal, not regional.
- Hybrid Connectivity: AWS Direct Connect
- For Internet egress: NAT Gateway
- CDN: Amazon CloudFront
- Consider Route 53 failover records for failing over to the second region.
  - Clients come in with a specific domain name.
  - Route 53 routes to two different ELBs.

### IaC

- Terraform
- AWS CloudFormation
- Need an S3 bucket for storing state

### CI/CD Pipeline

- AWS CodeCommit (Private Git)
- AWS CodeBuild
- AWS CodeDeploy?
- AWS CodePipeline?
  - ??
- Container Registry: Amazon Elastic Container Registry (ECR)

## Security

- Use Service Control Policies (SCPs), applied at OU levels.
- IAM: AWS Identity and Access Management
- Use CloudTrail to view audit history.
- Firewalling: AWS Firewall Manager
- For WAF: AWS WAF
- For DDoS protection: AWS Shield
  - Always on
- Secrets: AWS Secrets Manager
- Vulnerability Scanning: Amazon Inspector
- Use Amazon Certificate Manager (ACM) to provision a TLS certificate for our URL

## Billing and Cost Control

- Enable AWS Cost Explorer - visualise spend, set up budgets
- AWS Budgets
  - Set up a budget with alerts
- EC2 Savings Plans - 1 or 3 year commitment
- EC2 Reserved Instances
- AWS Cost Anomaly Detection
- AWS Trusted Advisor - to make cost optimisation recomments and right-size.
- AWS Cost and Usage Report
- Use tags. Equivalent of labels in Google Cloud.
- Consider use of CloudFront for CDN.

## Operations and Observability

- AWS Health Dashboard
- Amazon CloudWatch
- Amazon CloudWatch Logs
- Amazon Managed Service for Prometheus
- Security: AWS Security Hub

## Interaction

- AWS CloudShell
- Bastion hosts using EC2, with Amazon WorkLink?

## Create AWS Organisation

- Start with creating the organisation.
- Then create the OUs, to mirror the folder hiearchy we created in GCP.
- This allows us to do billing and cost management at org level.  It also means we can leverage volume discounts on the combined usage of member accounts.
