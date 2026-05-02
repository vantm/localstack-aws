# Terraform Migration Plan

## Project Overview

Migrate flat Terraform structure to modular architecture with environment separation.

## Current State

- **Structure**: Flat `.tf` files at root level
- **Files**: 10 resource files, no modules
- **Backend**: Local state

## Target Structure

```
terraform/
├── main.tf                 # Root module - calls all submodules
├── providers.tf           # Provider config
├── backend.tf            # S3 backend for state
├── variables.tf           # Shared variables
├── outputs.tf            # Shared outputs
├── envs/
│   └── dev/
│       ├── main.tf       # Env-specific config
│       ├── backend.tf   # Env-specific backend
│       └── terraform.tfvars
└── modules/
    ├── storage/          # S3 buckets + IAM policies
    ├── database/        # DynamoDB table
    ├── functions/      # Lambda functions + IAM
    ├── api/             # API Gateway + Cognito Authorizer
    ├── auth/            # Cognito User Pool
    ├── monitoring/      # CloudWatch logs + dashboard
    └── security/        # WAF ACL
```

## Migration Phases

### Phase 1: Setup Structure

- [ ] Create `terraform/modules/` subdirectories
- [ ] Create `terraform/envs/dev/`
- [ ] Create `providers.tf`
- [ ] Create `backend.tf`
- [ ] Create `variables.tf`
- [ ] Create `outputs.tf`
- [ ] Create root `main.tf`

### Phase 2: Create Modules

#### modules/storage/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- **Resources**: S3 buckets (convert_results, watermark_results), IAM policy for S3 access

#### modules/database/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- **Resources**: DynamoDB table (documents), IAM policy for DynamoDB access

#### modules/functions/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- **Resources**: Lambda functions (convert, watermark), IAM roles, ECR repositories

#### modules/auth/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- **Resources**: Cognito User Pool, User Pool Client

#### modules/api/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- **Resources**: API Gateway REST API, Resources, Methods, Integrations, Authorizer, Deployment, Stage

#### modules/monitoring/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- [ ] CloudWatch Log Groups, Dashboard

#### modules/security/

- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- [ ] WAF Web ACL, WAF Association

### Phase 3: Environment Setup

#### envs/dev/

- [ ] main.tf - imports root module with env-specific vars
- [ ] backend.tf - local backend (or S3 for remote)
- [ ] terraform.tfvars - dev values

### Phase 4: State Migration

- [ ] Move existing `.terraform/` to `terraform/`
- [ ] Move existing `.tfstate*` files to `terraform/envs/dev/`
- [ ] Run `terraform init` in new structure
- [ ] Run `terraform refresh` to verify state
- [ ] Test plan to confirm no drift

## Resource Mapping

| Current File | → Module |
|--------------|----------|
| buckets.tf | modules/storage/ |
| dynamodb.tf | modules/database/ |
| lambda-convert.tf + lambda-watermark.tf + ecr.tf | modules/functions/ |
| gateway.tf | modules/api/ |
| cognito.tf | modules/auth/ |
| cloudwatch.tf | modules/monitoring/ |
| waf.tf | modules/security/ |

## Implementation Order

1. Create directory structure
2. Create modules/storage/
3. Create modules/database/
4. Create modules/functions/
5. Create modules/auth/
6. Create modules/api/
7. Create modules/monitoring/
8. Create modules/security/
9. Create root main.tf (composes all modules)
10. Create envs/dev/ configuration
11. Migrate state
12. Test and verify

## Notes

- Keep existing resource names for backwards compatibility
- Use module composition in root main.tf
- Pass outputs between modules via root module
- Use terraform.workspace for environment differentiation