# TicketDesk — AWS Cost Report

## Billing Summary

| Item | Value |
|---|---:|
| Billing Period | August 1–31, 2026 |
| AWS Region | Asia Pacific (Mumbai) (`ap-south-1`) |
| Account | TicketDesk AWS Account |
| Bill Status | Pending |
| Total AWS Usage | **$14.19** |
| AWS Credits | **-$14.19** |
| Estimated Grand Total | **$0.00** |
| Current Amount Payable | **$0.00** |

## AWS Cost Breakdown

| AWS Service | Usage Cost (USD) |
|---|---:|
| Amazon Elastic Container Service (ECS / Fargate) | $4.11 |
| Amazon Elastic Load Balancing (ALB) | $3.85 |
| Amazon Relational Database Service (RDS PostgreSQL) | $3.79 |
| Amazon Virtual Private Cloud (VPC) | $2.40 |
| AWS Secrets Manager | $0.02 |
| Amazon Elastic Compute Cloud (EC2) | $0.02 |
| Amazon Elastic Container Registry (ECR) | $0.00 |
| Amazon Simple Storage Service (S3) | $0.00 |
| AWS WAF | $0.00 |
| AWS Data Transfer | $0.00 |
| **Total AWS Usage** | **$14.19** |

## Detailed Cost Breakdown

### Amazon ECS / Fargate

| Component | Usage | Cost (USD) |
|---|---:|---:|
| Fargate Memory | 158.148 hours | $0.74 |
| Fargate vCPU | 79.074 hours | $3.37 |
| **ECS Total** | | **$4.11** |

### Elastic Load Balancing

| Component | Usage | Cost (USD) |
|---|---:|---:|
| Application Load Balancer | 161 hours | $3.85 |
| ALB Capacity Units | 0.015 LCU-hours | $0.00 |
| **ALB Total** | | **$3.85** |

### Amazon RDS PostgreSQL

| Component | Usage | Cost (USD) |
|---|---:|---:|
| PostgreSQL `db.t3.micro` | 128.473 hours | $3.34 |
| GP3 Provisioned Storage | 3.454 GB-month | $0.45 |
| **RDS Total** | | **$3.79** |

### Amazon VPC

| Component | Usage | Cost (USD) |
|---|---:|---:|
| In-use Public IPv4 Address | 479.975 hours | $2.40 |
| Idle Public IPv4 Address | 0.136 hours | $0.00 |
| **VPC Total** | | **$2.40** |

### AWS Secrets Manager

| Component | Usage | Cost (USD) |
|---|---:|---:|
| Secret storage | 0.055 secrets | $0.02 |
| API requests | 160 requests | $0.00 |
| **Secrets Manager Total** | | **$0.02** |

### Amazon EC2

| Component | Usage | Cost (USD) |
|---|---:|---:|
| Linux/UNIX EC2 | 0.141 hours | $0.00 |
| GP3 EBS Storage | 0.172 GB-month | $0.02 |
| **EC2 Total** | | **$0.02** |

## Services With No Recorded Usage Cost

| AWS Service | Cost (USD) |
|---|---:|
| Amazon ECR | $0.00 |
| Amazon S3 | $0.00 |
| AWS WAF | $0.00 |
| AWS Data Transfer | $0.00 |
| AWS Lambda | $0.00 |
| Amazon CloudWatch | $0.00 |
| AWS CloudFormation | $0.00 |
| AWS Glue | $0.00 |
| AWS KMS | $0.00 |
| Amazon SNS | $0.00 |
| Amazon SQS | $0.00 |

## AWS Credits

AWS applied credits that completely offset the recorded usage costs.

| Item | Amount (USD) |
|---|---:|
| AWS Usage | $14.19 |
| AWS Credits | -$14.19 |
| **Net Amount Payable** | **$0.00** |

## Main Cost Drivers

| Rank | Service | Cost (USD) | Percentage of $14.19 |
|---:|---|---:|---:|
| 1 | ECS / Fargate | $4.11 | 28.97% |
| 2 | Elastic Load Balancing | $3.85 | 27.13% |
| 3 | RDS PostgreSQL | $3.79 | 26.71% |
| 4 | VPC / Public IPv4 | $2.40 | 16.91% |
| 5 | Secrets Manager | $0.02 | 0.14% |
| 6 | EC2 | $0.02 | 0.14% |

## Cost Observations

| Observation | Details |
|---|---|
| Largest cost | ECS / Fargate at $4.11 |
| Second largest | Application Load Balancer at $3.85 |
| Third largest | RDS PostgreSQL at $3.79 |
| Significant network cost | Public IPv4 addresses at $2.40 |
| Storage cost | RDS GP3 storage at $0.45 |
| Current payable amount | $0.00 after AWS credits |
| Billing status | Pending |

## Project Resources Contributing to Cost

| Project Resource | AWS Service | Cost |
|---|---|---:|
| TicketDesk API Fargate task | ECS / Fargate | $4.11 |
| TicketDesk Application Load Balancer | Elastic Load Balancing | $3.85 |
| TicketDesk PostgreSQL database | RDS | $3.79 |
| Public IPv4 addresses | VPC | $2.40 |
| Database credentials | Secrets Manager | $0.02 |
| EC2-related resources | EC2 / EBS | $0.02 |

## Cost Control Assessment

| Area | Status |
|---|---|
| ECS task count | 1 task |
| ECS task size | 0.5 vCPU / 1 GiB |
| RDS instance | `db.t3.micro` |
| RDS storage | 20 GB allocated |
| RDS backup retention | 1 day |
| Database encryption | Enabled |
| S3 storage | No recorded cost |
| ECR storage | No recorded cost |
| CloudWatch | No recorded cost |
| AWS credits | Cover current $14.19 usage |

## Conclusion

The TicketDesk AWS environment generated approximately **$14.19 of
AWS usage** during the current August 2026 billing period.

The primary cost contributors are:

1. **ECS / Fargate — $4.11**
2. **Application Load Balancer — $3.85**
3. **RDS PostgreSQL — $3.79**
4. **VPC public IPv4 addresses — $2.40**
5. **Secrets Manager — $0.02**
6. **EC2 — $0.02**

AWS credits currently offset the entire **$14.19** usage amount, resulting
in an **estimated grand total of $0.00** and **no current amount payable**.

The bill is still **Pending**, and AWS notes that estimated charges can
change as additional usage is recorded during the billing period.

> **Deployment-readiness cost assessment:** Current AWS usage is
> approximately **$14.19**, fully covered by available AWS credits,
> resulting in **$0.00 payable** at the time of this report.