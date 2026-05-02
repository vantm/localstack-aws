# Refactor Plan: Consolidate `functions` → `function`, Absorb `storage`, Remove `monitoring`

## Goal

1. Rename `functions` → `function` (singular), make it a generic single-Lambda module
2. In root `main.tf`, instantiate 2 copies: `module "function_convert"` and `module "function_watermark"`
3. Absorb `storage` into `function` — each function gets its own S3 bucket + IAM policy
4. Disperse `monitoring` to corresponding modules — log groups to their respective modules, dashboard to `api`, then delete `monitoring`

## Current Module Graph

```
storage ──┬──► functions ──┬──► api ──► security
          │               │
database ─┘               ├──► monitoring (log groups + dashboard)
                          │
auth ─────────────────────┘
```

## Target Module Graph

```
database ──┬──► function_convert ──┬──► api (includes own log group + dashboard) ──► security
           │                      │
           ├──► function_watermark ┘
           │
auth ──────┘
```

**Net change: 7 modules → 5 modules.** Removed: `storage`, `monitoring`. Renamed: `functions` → `function`.

---

## Step-by-Step File Changes

### 1. Create new module: `terraform/modules/function/`

Each `function` module provisions: 1 ECR repo, 1 Lambda, 1 IAM role + 3 policy attachments, 1 API Gateway permission, **1 S3 bucket**, **1 S3 IAM policy**, **1 CloudWatch log group**.

#### `terraform/modules/function/variables.tf`

```hcl
variable "name" {
  description = "Base name for all resources (e.g. 'convert' or 'watermark')"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_access_policy_arn" {
  description = "ARN of the DynamoDB access IAM policy"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "additional_env_vars" {
  description = "Additional environment variables for the Lambda (e.g. OUTPUT_FORMAT, WATERMARK_TEXT)"
  type        = map(string)
  default     = {}
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "logs_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
```

#### `terraform/modules/function/main.tf`

Resources (in dependency order):

```
aws_s3_bucket.results              → name = "${var.name}-results"
aws_iam_policy.s3_access           → grants s3:PutObject/GetObject/DeleteObject/ListBucket on results bucket
aws_ecr_repository.function        → name = "${var.name}-document"
aws_ecr_lifecycle_policy.function  → keep last 5 tagged images
aws_iam_role.lambda                → assume_role for lambda.amazonaws.com
aws_iam_role_policy_attachment.logs        → CloudWatchLogsFullAccess
aws_iam_role_policy_attachment.dynamodb    → var.dynamodb_access_policy_arn
aws_iam_role_policy_attachment.s3          → aws_iam_policy.s3_access.arn
aws_lambda_function.function        → image_uri from ECR, merge(additional_env_vars, {DYNAMO_TABLE, S3_BUCKET})
aws_lambda_permission.api_gateway   → allow apigateway to invoke
aws_cloudwatch_log_group.function   → name = "/aws/lambda/${var.name}-document"
```

Key design decisions:
- Bucket name: `"${var.name}-results"`
- Function name: `"${var.name}-document"`
- S3 policy name: `"${var.name}-lambda-s3-access"`
- Role name: `"${var.name}-lambda-role"`
- `DYNAMO_TABLE` and `S3_BUCKET` env vars are auto-set by the module (merged with `var.additional_env_vars`)

#### `terraform/modules/function/outputs.tf`

```hcl
output "lambda_invoke_arn"   { value = aws_lambda_function.function.invoke_arn }
output "lambda_arn"          { value = aws_lambda_function.function.arn }
output "lambda_name"         { value = aws_lambda_function.function.function_name }
output "ecr_url"             { value = aws_ecr_repository.function.repository_url }
output "results_bucket_name" { value = aws_s3_bucket.results.id }
output "results_bucket_arn"  { value = aws_s3_bucket.results.arn }
```

---

### 2. Update `terraform/modules/api/`

#### Add CloudWatch log group for API Gateway

Add to `main.tf`:
```hcl
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.retention_in_days
}
```

#### Add CloudWatch dashboard

Move the full dashboard from `monitoring/main.tf` into `api/main.tf`.

#### Add new variables to `variables.tf`

```hcl
variable "convert_lambda_name"       { type = string }
variable "watermark_lambda_name"     { type = string }
variable "logs_retention_in_days"    { type = number; default = 7 }
variable "monitoring_dashboard_name" { type = string; default = "documents-api-monitoring" }
```

#### Add new outputs to `outputs.tf`

```hcl
output "monitoring_dashboard_name" { value = aws_cloudwatch_dashboard.main.dashboard_name }
```

---

### 3. Rewrite root `terraform/main.tf`

Remove `module "storage"`, `module "functions"`, `module "monitoring"`.

Add:
```hcl
module "function_convert" {
  source = "./modules/function"

  name                        = "convert"
  dynamodb_table_name         = module.database.table_name
  dynamodb_access_policy_arn  = module.database.dynamodb_access_policy_arn
  api_gateway_execution_arn   = module.api.execution_arn
  additional_env_vars = {
    OUTPUT_FORMAT = var.output_format
  }
  logs_retention_in_days = var.logs_retention_in_days
}

module "function_watermark" {
  source = "./modules/function"

  name                        = "watermark"
  dynamodb_table_name         = module.database.table_name
  dynamodb_access_policy_arn  = module.database.dynamodb_access_policy_arn
  api_gateway_execution_arn   = module.api.execution_arn
  additional_env_vars = {
    WATERMARK_TEXT = var.watermark_text
  }
  logs_retention_in_days = var.logs_retention_in_days
}
```

Update `module "api"`:
```hcl
module "api" {
  source = "./modules/api"

  api_name                    = var.api_name
  api_description             = var.api_description
  user_pool_arn               = module.auth.user_pool_arn
  convert_lambda_invoke_arn   = module.function_convert.lambda_invoke_arn
  watermark_lambda_invoke_arn = module.function_watermark.lambda_invoke_arn
  convert_lambda_name         = module.function_convert.lambda_name
  watermark_lambda_name       = module.function_watermark.lambda_name
  authorizer_credentials_arn  = var.authorizer_credentials_arn
  logs_retention_in_days      = var.logs_retention_in_days
  monitoring_dashboard_name   = var.monitoring_dashboard_name
}
```

Remove `module "monitoring"` entirely.

---

### 4. Update root `terraform/variables.tf`

**Remove** (no longer needed at root):
- `convert_results_bucket_name`
- `watermark_results_bucket_name`
- `s3_access_policy_name`

**Rename:**
- `dashboard_name` → `monitoring_dashboard_name`
- `retention_in_days` → `logs_retention_in_days`
- `rate_limit` → `waf_rate_limit`

All other variables remain unchanged.

---

### 5. Update root `terraform/outputs.tf`

Change:
```hcl
output "convert_ecr_url"   { value = module.function_convert.ecr_url }
output "watermark_ecr_url" { value = module.function_watermark.ecr_url }
```

Rest unchanged (`api_url`, `user_pool_id`, `user_pool_client_id`).

---

### 6. Update `terraform/envs/dev/variables.tf`

Remove re-declarations for:
- `convert_results_bucket_name`
- `watermark_results_bucket_name`
- `s3_access_policy_name`

Rename:
- `dashboard_name` → `monitoring_dashboard_name`
- `retention_in_days` → `logs_retention_in_days`
- `rate_limit` → `waf_rate_limit`

---

### 7. Update `terraform/envs/dev/terraform.tfvars`

Remove entries:
- `convert_results_bucket_name`
- `watermark_results_bucket_name`
- `s3_access_policy_name`

Rename:
- `dashboard_name` → `monitoring_dashboard_name`
- `retention_in_days` → `logs_retention_in_days`
- `rate_limit` → `waf_rate_limit`

---

### 8. Delete old module directories

```bash
rm -rf terraform/modules/storage/
rm -rf terraform/modules/functions/
rm -rf terraform/modules/monitoring/
```

---

### 9. Update `AGENTS.md`

Reflect new architecture: 5 modules, renamed `function`, removed `storage`/`monitoring`.

- Line 14: `7 submodules` → `5 submodules`
- Line 15: `storage, database, functions, api, auth, monitoring, security` → `database, function, api, auth, security`
- Module table: remove `storage` and `monitoring` rows, rename `functions` → `function`, update descriptions:
  - `function` row: `1 S3 bucket, 1 S3 IAM policy, 1 ECR repo, 1 Lambda (container/ECR), 1 IAM role, 1 CloudWatch log group`
  - `api` row: append `, 1 CloudWatch log group, 1 Dashboard`

---

## Variable Flow (Target State)

| Root var                  | Goes to module(s)                          |
| ------------------------- | ------------------------------------------ |
| `aws_region`              | provider                                   |
| `output_format`           | `function_convert.additional_env_vars`     |
| `watermark_text`          | `function_watermark.additional_env_vars`   |
| `dynamodb_table_name`     | `database`                                 |
| `dynamodb_access_policy_name` | `database`                             |
| `user_pool_name`          | `auth`                                     |
| `user_pool_client_name`   | `auth`                                     |
| `api_name`                | `api`                                      |
| `api_description`         | `api`                                      |
| `authorizer_credentials_arn` | `api`                                   |
| `monitoring_dashboard_name` | `api`                                      |
| `logs_retention_in_days`  | `function_convert`, `function_watermark`, `api` |
| `waf_name`                | `security`                                 |
| `waf_description`         | `security`                                 |
| `waf_rate_limit`          | `security`                                 |

---

## Module Inputs (Target State)

### `function` module inputs

| Input                       | Source / Value                          |
| --------------------------- | --------------------------------------- |
| `name`                      | `"convert"` / `"watermark"`             |
| `dynamodb_table_name`       | `module.database.table_name`            |
| `dynamodb_access_policy_arn`| `module.database.dynamodb_access_policy_arn` |
| `api_gateway_execution_arn` | `module.api.execution_arn`              |
| `additional_env_vars`       | `{ OUTPUT_FORMAT = ... }` / `{ WATERMARK_TEXT = ... }` |
| `logs_retention_in_days`   | `var.logs_retention_in_days`              |

### `api` module inputs (delta — new items only)

| Input                       | Source                                 |
| --------------------------- | -------------------------------------- |
| `convert_lambda_name`       | `module.function_convert.lambda_name`  |
| `watermark_lambda_name`     | `module.function_watermark.lambda_name`|
| `logs_retention_in_days`    | `var.logs_retention_in_days`           |
| `monitoring_dashboard_name` | `var.monitoring_dashboard_name`        |

---

## Notes / Risks

1. **Circular dependency `function_*` ↔ `api`**: Exists in current codebase too. Works because `execution_arn` and `invoke_arn` are known at plan time from the resource addresses, not from actual resource creation. No change in behavior.

2. **S3 bucket naming**: Previously configurable via `tfvars`. Now deterministic: `"${var.name}-results"`. This means `convert-results` and `watermark-results` are hard-derived from the function `name`. If customization is ever needed, add an optional `bucket_name` override variable to the function module.

3. **IAM policy granularity**: Previously one shared S3 policy covered both buckets. Now each function's IAM role attaches a policy scoped to only its own bucket — **more secure**.

4. **Dashboard ownership**: The CloudWatch dashboard moves under the `api` module. It references both API Gateway and Lambda metrics, which is coherent since the dashboard is about the API service as a whole.

5. **No `terraform state mv` needed**: Since we are not renaming existing resources in-place but replacing modules, running `terraform plan` after the refactor will show resources being destroyed and recreated. If preserving existing infrastructure is required, `terraform state mv` commands must be applied first. However, for a LocalStack development environment, destroy-and-recreate is acceptable.

6. **Resource name changes**: Lambda function names (`convert-document`, `watermark-document`), ECR repo names, S3 bucket names, IAM role names all remain identical. Only IAM policy names change from `lambda-s3-access` (shared) to `convert-lambda-s3-access` / `watermark-lambda-s3-access` (per-function).
