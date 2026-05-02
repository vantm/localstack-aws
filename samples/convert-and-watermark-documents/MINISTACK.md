# MiniStack

MiniStack supports those services:

- S3
- DynamoDB
- SQS
- SNS
- Lambda
- IAM
- STS
- Secrets Manager
- SSM
- CloudFormation
- CloudWatch
- CloudWatch Logs
- EventBridge
- EventBridge Scheduler
- Pipes
- Step Functions
- Kinesis
- Firehose
- Athena
- Glue
- EMR
- EC2
- ECS
- EKS
- AutoScaling
- ALB / ELBv2
- RDS
- RDS Data API
- ElastiCache
- Route53
- CloudFront
- ServiceDiscovery
- API Gateway v1 (REST)
- API Gateway v2 (HTTP/WS)
- AppSync
- KMS
- ACM
- WAFv2
- Cognito
- SES
- EFS
- ECR
- Transfer
- S3 Files
- AppConfig
- CodeBuild

## Limitations

### Stored but not dispatched

These integrations accept configuration and return correct shapes, but the
side-effect is not performed. Tests that assert on the stored config pass; tests
that assert on downstream side-effects will not.

| Surface                                 | What's missing                                                                                                 |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| CloudWatch Alarm -> SNS / Lambda        | AlarmActions stored; state transitions never fire the actions.                                                 |
| CloudWatch Metrics for Lambda           | No Invocations, Errors, Duration, Throttles, ConcurrentExecutions emitted.                                     |
| CloudWatch Metrics for SQS              | ApproximateNumberOfMessagesVisible, ApproximateAgeOfOldestMessage not tracked.                                 |
| EventBridge -> API Destination HTTP     | Connections + ApiDestinations accepted; no outbound HTTP call made.                                            |
| EventBridge scheduled rules             | ScheduleExpression (cron/rate) stored; rule never fires on schedule.                                           |
| EventBridge Scheduler                   | Schedules stored; never triggered. Same class of gap as scheduled rules.                                       |
| EventBridge StartReplay                 | Status flips to RUNNING → COMPLETED without re-dispatching events.                                             |
| EventBridge Pipes                       | Source → target routing stored; messages are not piped.                                                        |
| ECS -> CloudWatch Logs (awslogs driver) | Log driver config parsed; stdout/stderr not written to log groups.                                             |
| API Gateway access logs                 | AccessLogSettings stored; no log events written.                                                               |
| Step Functions logging                  | loggingConfiguration stored; not written to CloudWatch Logs. No ExecutionsStarted/Failed/Duration metrics.     |
| CodeBuild logs                          | Log group created on project creation; build output never written to it.                                       |
| WAFv2 rule evaluation                   | WebACLs, rules, IP sets all stored. Rules are not enforced against incoming requests.                          |
| AutoScaling policy triggers             | Scaling policies + lifecycle hooks stored; never fired by CloudWatch alarms.                                   |
| CloudFormation Stack                    | Policy Stored / retrievable via API; not enforced during UpdateStack.                                          |
| Cognito Lambda triggers                 | PreSignUp, PostConfirmation, CustomMessage, PreAuth, PostAuth, PreTokenGeneration all stored; none invoked.    |
| SES identity verification               | VerifyEmailIdentity / VerifyDomainIdentity jump straight to Success — no pending state, no confirmation email. |
| Route53 health checks                   | Checks stored; status never updated; no CloudWatch bridge.                                                     |
| RDS event subscriptions                 | Subscriptions stored; not wired to SNS.                                                                        |
| DynamoDB Streams -> Kinesis             | Streams can be enabled on a table; no records are produced.                                                    |
| S3 SSE-KMS                              | Encryption key stored per object; encrypt/decrypt is a silent no-op.                                           |
| ECS task state -> EventBridge           | SubmitTaskStateChange exists; event is not put on the default bus.                                             |

### Metadata-only services

These services accept and return realistic shapes so IaC tools plan and apply,
but no real infrastructure is created:

- EC2 — instances, VPCs, subnets, SGs exist as data. No real VMs, no ENI
  networking, no IAM permission evaluation.
- CloudFront — distributions stored and returned; no edge caching or content
  delivery.
- Transfer Family — servers and users stored; no SFTP/FTPS listener.
- EFS — file systems, mount targets, access points stored; no POSIX filesystem
  or NFS mount.
- AppSync — GraphQL APIs, data sources, resolvers defined; no query execution.
- EMR / Glue (jobs) — job metadata tracked; no Spark/Hadoop execution.
- ACM — certificates auto-ISSUED; no DNS/HTTP validation occurs.
- Athena without DuckDB — with ATHENA_ENGINE=mock, query results are empty.
  auto/duckdb gives real SQL on S3 data.
- Firehose non-S3 destinations — Redshift, OpenSearch, Splunk, Snowflake all
  stored; no delivery performed.

### Impossible locally

These are structural — a single-process emulator cannot simulate them.

- Real IAM enforcement. Policy evaluation is a full language with global state;
  not in scope.
- Real VPC networking. Subnets, route tables, and NAT all exist as metadata;
  packet routing is not simulated.
- Cross-AZ / cross-region replication primitives. S3 cross-region replication,
  DDB global tables, KMS multi-region keys require real regional endpoints.
- Real DNS propagation. Route53 changes are visible inside MiniStack only; they
  don't affect your host's resolver.
- SMTP delivery without a real MTA. Unless SMTP_HOST points at one (e.g.
  MailHog), SES emails stay in memory.
- Real Kubernetes control plane. EKS runs k3s as a sidecar — powerful, but not
  byte-identical to EKS.

### By-design differences

- No SigV4 signature validation. Any access key/secret works.
- Default account 000000000000 (some paths use 123456789012 interchangeably).
- Epoch floats vs ISO timestamps. Some responses emit epoch floats for
  Go/Terraform SDK compatibility where AWS emits ISO 8601. This is intentional.
- State shared across regions within an account for most services — use unique
  resource names if your tests exercise two regions.
- Lenient validation. Required fields are checked; optional fields are accepted
  more permissively than AWS.
- CloudFront response latency — near-zero (no real CDN). Tests that depend on
  eventual-consistency windows won't see them unless you add a sleep.
