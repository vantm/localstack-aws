# Agents

## Commands

- **Working directory**: `terraform/envs/dev/` — init, plan, apply all run from here
- **Only touch the `dev` environment** — no staging/prod envs exist

## Development

- Project uses MiniStack to perform tests.
- [MiniStack limitation](./MINISTACK.md)

## Architecture

Modular Terraform project that provisions a document conversion + watermarking API on AWS/LocalStack.

```
terraform/envs/dev/          ← entrypoint (terraform init/plan/apply here)
terraform/                   ← root module, composes 7 submodules
terraform/modules/           ← storage, database, functions, api, auth, monitoring, security
```

**7 modules** with strict output→input chains:

| Module     | Resources created                                                |
| ---------- | ---------------------------------------------------------------- |
| storage    | 2 S3 buckets, 1 IAM policy                                       |
| database   | 1 DynamoDB table (hash=`id`, range=`created_at`), 1 IAM policy   |
| auth       | 1 Cognito User Pool, 1 User Pool Client                          |
| functions  | 2 Lambda (container/ECR), 2 ECR repos, 2 IAM roles, permissions  |
| api        | REST API Gateway, /convert + /watermark POST, Cognito authorizer |
| monitoring | 3 CloudWatch Log Groups, 1 Dashboard                             |
| security   | 1 WAFv2 Web ACL (managed rules + rate limit), API association    |

Lambda functions are **container-based** (`package_type = "Image"`) pointing at ECR repos. No function code is defined in Terraform — images must be pushed separately.

## Variable flow

Root `variables.tf` has defaults. Env-level `variables.tf` re-declares all vars **without** defaults (must be supplied). `terraform.tfvars` in `envs/dev/` sets actual values.
