# Agents

## Commands

- **Working directory**: `terraform/envs/dev/` — init, plan, apply all run from here
- **Only touch the `dev` environment** — no staging/prod envs exist

## Architecture

Modular Terraform project that provisions a document conversion + watermarking API on AWS/LocalStack.

```
terraform/envs/dev/          ← entrypoint (terraform init/plan/apply here)
terraform/                   ← root module, composes 5 submodules
terraform/modules/           ← database, function, api, auth, security
```

**5 modules** with strict output→input chains:

| Module     | Resources created                                                                  |
| ---------- | ---------------------------------------------------------------------------------- |
| database   | 1 DynamoDB table (hash=`id`, range=`created_at`), 1 IAM policy                     |
| auth       | 1 Cognito User Pool, 1 User Pool Client                                            |
| function   | 1 S3 bucket, 1 S3 IAM policy, 1 ECR repo, 1 Lambda (container/ECR), 1 IAM role, 1 CloudWatch log group |
| api        | REST API Gateway, /convert + /watermark POST, Cognito authorizer, 1 CloudWatch log group, 1 Dashboard |
| security   | 1 WAFv2 Web ACL (managed rules + rate limit), API association                      |

Lambda functions are **container-based** (`package_type = "Image"`) pointing at ECR repos. No function code is defined in Terraform — images must be pushed separately.

## Variable flow

Root `variables.tf` has defaults. Env-level `variables.tf` re-declares all vars **without** defaults (must be supplied). `terraform.tfvars` in `envs/dev/` sets actual values.
