# TicketDesk M0 Terraform

This directory adopts the existing TicketDesk M0 network into Terraform. It does
not manage application, RDS, IAM, S3, CloudFront, or secrets resources.

## First validation

1. Ensure the AWS CLI is authenticated to account `956118719056`.
2. Run `terraform init`.
3. Run `terraform fmt -check` and `terraform validate`.
4. Run `terraform plan` and review every import and proposed change.

The `import.tf` blocks reference the current production resource IDs. `plan` may
write a local state file, which is ignored by Git, but it does not modify AWS.
Do not run `terraform apply` until a reviewed plan has no unintended changes.

## Known boundary

The deployed RDS security group still permits the legacy CloudFormation backend
security group (`sg-01edcba4cf55f7223`) in addition to the active API group.
That legacy rule is deliberately outside this M0 adoption to avoid changing a
running database during the Terraform migration.
