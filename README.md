# TicketDesk

TicketDesk is a cloud-deployed ticket management application with a FastAPI backend and web frontend.

The application is containerized with Docker and deployed on AWS using Terraform, Amazon ECS Fargate, Application Load Balancer, Amazon RDS PostgreSQL, Amazon S3, AWS Secrets Manager, AWS Systems Manager Parameter Store, CloudWatch, SNS, and ECR.

The frontend is currently served separately and communicates with the backend through the AWS Application Load Balancer.

---

## Architecture

```text
                         Internet
                            |
                            v
                    +----------------+
                    |      ALB       |
                    | Public Subnets |
                    +--------+-------+
                             |
                             v
                    +----------------+
                    | ECS Fargate    |
                    | FastAPI API    |
                    | Private Subnet |
                    +--------+-------+
                             |
                  +----------+----------+
                  |                     |
                  v                     v
          +---------------+     +---------------+
          | PostgreSQL RDS|     |      S3       |
          |    Private    |     |  Attachments  |
          +---------------+     |    Private    |
                                +---------------+

Configuration:

    Secrets Manager
          |
          v
    Database password

    SSM Parameter Store
          |
          v
    Runtime application configuration

Observability:

    ECS / ALB / RDS
          |
          v
      CloudWatch
          |
          v
         SNS
```

---

## Frontend

The TicketDesk frontend is a static HTML/CSS/Vanilla JavaScript application located in:

```text
TicketDeck_Frontend/
```

It provides:

* Dashboard metrics
* Ticket creation and listing
* Search and filtering
* Ticket details
* Status updates
* Comments
* File attachments
* Direct S3 uploads using presigned URLs
* Presigned attachment downloads

### Current Frontend / Backend Flow

The frontend is currently served locally during development while the backend is deployed behind the AWS ALB.

```text
Browser
   |
   v
Frontend
localhost:8080
   |
   | API requests
   v
AWS Application Load Balancer
   |
   v
ECS Fargate
   |
   v
FastAPI Backend
   |
   +------------------+
   |                  |
   v                  v
RDS PostgreSQL       S3
                    Attachments
```

The current frontend API configuration is:

```javascript
const BASE_URL = "http://ticketdesk-alb-779410850.ap-south-1.elb.amazonaws.com";
```

The frontend README contains the complete frontend setup, configuration, attachment flow, and troubleshooting documentation.

---

## Prerequisites

Install/configure:

* Git
* Python 3.11+
* Docker
* Terraform >= 1.5
* AWS CLI
* An AWS account with permissions to create the required resources

Configure AWS credentials:

```powershell
aws configure
```

Use:

```text
Region: ap-south-1
```

Verify:

```powershell
aws sts get-caller-identity
aws configure get region
```

The expected region is:

```text
ap-south-1
```

---

## Repository Structure

```text
TicketDesk/
│
├── Ticketdeck_backend/
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── ...
│
├── TicketDeck_Frontend/
│   ├── index.html
│   ├── README.md
│   ├── css/
│   │   └── styles.css
│   └── js/
│       ├── api.js
│       ├── app.js
│       ├── dashboard.js
│       ├── tickets.js
│       └── ticket-detail.js
│
├── infrastructure/
│   ├── ticketdesk-network.yaml
│   ├── ticketdesk-security.yaml
│   ├── ticketdesk-rds.yaml
│   │
│   └── terraform/
│       ├── backend.tf
│       ├── ecs.tf
│       ├── network.tf
│       ├── security_groups.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

---

## Backend

Go to the backend:

```powershell
cd D:\TicketDesk\Ticketdeck_backend
```

Install dependencies locally if required:

```powershell
pip install -r requirements.txt
```

Run locally:

```powershell
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Health endpoint:

```text
http://localhost:8000/api/health
```

Expected response:

```json
{
  "status": "ok",
  "service": "TicketDesk API"
}
```

---

## Docker

The backend uses a multi-stage Docker build.

Build:

```powershell
docker build -t ticketdesk-api .
```

Run:

```powershell
docker run -p 8000:8000 ticketdesk-api
```

The production image runs as a non-root user and does not contain the build-stage tooling.

---

## ECR

The application image is stored in Amazon ECR.

Repository:

```text
ticketdesk-api
```

Region:

```text
ap-south-1
```

Login:

```powershell
aws ecr get-login-password --region ap-south-1 |
    docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com
```

Build an image using the Git commit SHA:

```powershell
$SHA = git rev-parse --short HEAD
docker build -t ticketdesk-api:$SHA .
```

Tag:

```powershell
docker tag ticketdesk-api:$SHA `
    <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/ticketdesk-api:$SHA
```

Push:

```powershell
docker push `
    <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/ticketdesk-api:$SHA
```

ECR image scanning is enabled on push.

---

## Infrastructure

Terraform manages the AWS application infrastructure.

Go to:

```powershell
cd D:\TicketDesk\infrastructure\terraform
```

Initialize:

```powershell
terraform init
```

Validate:

```powershell
terraform validate
```

Format:

```powershell
terraform fmt
```

Review:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

---

## Terraform State

Terraform state is stored remotely in:

```text
S3:
ticketdesk-terraform-state

Key:
ticketdesk/terraform.tfstate
```

State locking is provided by:

```text
DynamoDB:
ticketdesk-terraform-locks
```

The state bucket uses encryption and versioning.

Do not delete or manually edit the Terraform state.

---

## AWS Resources

The deployment includes:

* Amazon VPC
* Public and private subnets
* Internet Gateway
* Route tables
* Security groups
* Application Load Balancer
* Amazon ECS cluster
* ECS service
* ECS task definition
* Amazon ECR
* Amazon RDS PostgreSQL
* Amazon S3
* AWS Secrets Manager
* AWS Systems Manager Parameter Store
* CloudWatch Logs
* CloudWatch Dashboard
* CloudWatch Alarms
* Amazon SNS
* Terraform remote state

---

## Network Design

The application follows a public/private subnet architecture.

### Public Subnet

The Application Load Balancer is deployed in public subnets.

### Private Subnet

The ECS application tasks run in private subnets.

The RDS database is also private.

The application is accessed through:

```text
Internet
   |
   v
ALB
   |
   v
ECS
   |
   v
RDS
```

The application container is not directly exposed to the Internet.

---

## Database

The application uses PostgreSQL on Amazon RDS.

Database:

```text
ticketdesk
```

Port:

```text
5432
```

The database is:

* Private
* Not publicly accessible
* Encrypted at rest

Database credentials are not stored in the application repository.

---

## Secrets Management

The database password is stored in AWS Secrets Manager.

The ECS task retrieves:

```text
DATABASE_PASSWORD
```

from Secrets Manager at runtime.

Do not place database passwords in:

* Git
* `.tf` files
* Dockerfiles
* source code
* README files
* environment files committed to Git

---

## Parameter Store

Non-secret application configuration is stored in AWS Systems Manager Parameter Store.

Parameters:

```text
/ticketdesk/dev/AWS_REGION
/ticketdesk/dev/DATABASE_HOST
/ticketdesk/dev/DATABASE_NAME
/ticketdesk/dev/DATABASE_PORT
/ticketdesk/dev/DATABASE_USER
/ticketdesk/dev/PORT
/ticketdesk/dev/S3_BUCKET
```

ECS retrieves these values at runtime.

---

## Health Check

API health endpoint:

```text
/api/health
```

Example:

```powershell
curl.exe -f "http://<ALB-DNS>/api/health"
```

Expected:

```json
{
  "status": "ok",
  "service": "TicketDesk API"
}
```

---

## Load Test

The deployed API was tested with:

```text
Concurrent users: 20
Duration: 5 minutes
```

Result:

```text
Total requests: 185853
Successful 200s: 185853
Total errors: 0
```

Result:

```text
PASS - No errors detected
```

---

## Monitoring

CloudWatch contains:

* ECS logs
* ALB metrics
* RDS metrics
* Application dashboard

Dashboard:

```text
TicketDesk-Observability
```

Configured alarms include:

```text
ticketdesk-alb-5xx-errors
ticketdesk-alb-unhealthy-target
ticketdesk-rds-cpu-high
```

Notifications are sent through the TicketDesk SNS topic.

---

## Deployment Verification

### 1. ECS

```powershell
aws ecs describe-services `
  --cluster ticketdesk-cluster `
  --services ticketdesk-cluster `
  --region ap-south-1
```

Verify:

```text
Status: ACTIVE
Desired: 1
Running: 1
```

### 2. Target Health

```powershell
aws elbv2 describe-target-health `
  --target-group-arn <TARGET_GROUP_ARN> `
  --region ap-south-1
```

Expected:

```text
healthy
```

### 3. API

```powershell
curl.exe -f "http://<ALB-DNS>/api/health"
```

---

## Terraform Rebuild Test

The infrastructure can be destroyed and rebuilt using Terraform.

Destroy:

```powershell
terraform destroy
```

Recreate:

```powershell
terraform apply
```

After recreation, verify:

```text
ECS task healthy
ALB target healthy
RDS available
/api/health returns HTTP 200
```

---

## Frontend / CloudFront

The frontend files are managed through Terraform and stored in a private S3 bucket with public access blocked.

The planned production architecture uses CloudFront as the public entry point:

```text
                         Internet
                            |
                            v
                    +-----------------+
                    |   CloudFront    |
                    |   Distribution  |
                    +--------+--------+
                             |
                  +----------+----------+
                  |                     |
               Default                /api/*
                  |                     |
                  v                     v
          Private S3 Bucket            ALB
          Frontend Files                |
                                        v
                                  ECS Fargate
                                        |
                              +---------+---------+
                              |                   |
                              v                   v
                         PostgreSQL RDS      S3 Attachments
```

In the final CloudFront setup, the frontend should use:

```javascript
const BASE_URL = "/api";
```

CloudFront will route `/api/*` requests to the existing ALB.

This makes CloudFront the single public entry point and avoids exposing the ALB hostname directly in browser JavaScript.

### Current CloudFront Limitation

CloudFront distribution creation is currently blocked by an AWS account-level verification requirement:

```text
Your account must be verified before you can add new CloudFront resources.
```

Therefore:

```text
Frontend S3 deployment       -> available
CloudFront Terraform config -> prepared
CloudFront distribution      -> blocked by AWS verification
```

The CloudFront Terraform configuration is retained and can be enabled after AWS account verification is completed.

Do not repeatedly run `terraform apply` expecting this AWS account restriction to disappear.

---

## Important AWS Commands

### Check ECS

```powershell
aws ecs list-services `
  --cluster ticketdesk-cluster `
  --region ap-south-1
```

### Check RDS

```powershell
aws rds describe-db-instances `
  --db-instance-identifier ticketdesk-postgres `
  --region ap-south-1
```

### Check ECR

```powershell
aws ecr describe-repositories `
  --repository-names ticketdesk-api `
  --region ap-south-1
```

### Check SSM

```powershell
aws ssm get-parameters-by-path `
  --path /ticketdesk/dev `
  --region ap-south-1
```

### Check Terraform State

```powershell
terraform state list
```

---

## Troubleshooting

### ECS Task Is Not Running

Check:

```powershell
aws ecs describe-services `
  --cluster ticketdesk-cluster `
  --services ticketdesk-cluster `
  --region ap-south-1
```

Then inspect ECS events and CloudWatch logs.

### ALB Target Is Unhealthy

Check:

```text
/api/health
```

Verify:

* ECS container is listening on port 8000
* Target group port is correct
* ECS security group allows traffic from the ALB security group
* Health check path is `/api/health`

### Terraform Shows Unexpected Region

Check:

```powershell
aws configure get region
```

Expected:

```text
ap-south-1
```

Set it:

```powershell
aws configure set region ap-south-1
```

### CloudFront Creation Fails

If AWS returns:

```text
Your account must be verified before you can add new CloudFront resources.
```

Contact AWS Support/account verification.

Do not repeatedly run `terraform apply` expecting the restriction to disappear.

---

## Security Rules

Never commit:

```text
AWS access keys
AWS secret keys
database passwords
API keys
tokens
private credentials
terraform.tfstate
```

Terraform state contains infrastructure information and should remain in the remote encrypted backend.

---

## Deployment Checklist

* [x] Multi-stage Dockerfile
* [x] Container runs as non-root
* [x] Build tools excluded from production image
* [x] Git SHA image tagging
* [x] ECR image scanning
* [x] Terraform-managed infrastructure
* [x] Remote Terraform state
* [x] DynamoDB state locking
* [x] Private ECS subnet
* [x] Public ALB
* [x] Security-group based access
* [x] Health check
* [x] Two Availability Zones
* [x] ALB application access
* [x] Private encrypted RDS
* [x] Secrets Manager database password
* [x] SSM runtime configuration
* [x] No credentials in repository
* [x] Encryption at rest
* [x] Frontend files managed through Terraform and stored in private S3
* [x] CloudWatch logging
* [x] CloudWatch dashboard
* [x] CloudWatch alarms
* [x] SNS notifications
* [x] Resource tagging
* [x] IAM least privilege
* [x] Cost report
* [x] Terraform destroy/apply rebuild tested
* [x] Load test passed
* [ ] CloudFront distribution — blocked by AWS account verification

---

## New Joiner Quick Start

```powershell
git clone <REPOSITORY_URL>
cd TicketDesk

aws configure
aws configure set region ap-south-1

cd infrastructure/terraform

terraform init
terraform validate
terraform plan
terraform apply
```

After deployment:

```powershell
terraform output
```

Get the ALB DNS name and test:

```powershell
curl.exe -f "http://<ALB-DNS>/api/health"
```

A successful deployment returns:

```json
{
  "status": "ok",
  "service": "TicketDesk API"
}
```

---

## Project Information

**Project:** TicketDesk

**Owner:** Mouktik

**Environment:** dev

**AWS Region:** ap-south-1

**Cost Center:** TicketDesk
