# cloudTrails-Alert

Terraform that sets up AWS CloudTrail monitoring with alerts: CloudTrail events are logged to S3 and CloudWatch Logs, matched by metric filters, and raised as CloudWatch alarms that notify an SNS topic.

## What it creates

| Resource | Purpose |
|---|---|
| `aws_cloudtrail` (`my-trail`) | Records account activity, including global service events |
| `aws_s3_bucket` + bucket policy | Private bucket (`trail-bucket-<uuid>`) that stores trail logs under `trails/` |
| `aws_cloudwatch_log_group` (`trails`) | Receives CloudTrail events |
| IAM role and policy | Lets CloudTrail write to the log group (`logs:CreateLogStream`, `logs:PutLogEvents`) |
| `aws_cloudwatch_log_metric_filter` | Turns matching log events into custom metrics |
| `aws_cloudwatch_metric_alarm` | Alarms when a metric crosses its threshold (5-minute window, `Sum`) |
| `aws_sns_topic` + subscription | Receives alarm notifications |

## Alerts

| Alert | Filter pattern | Namespace | Fires when |
|---|---|---|---|
| `new-user-created` | `{ $.eventName = CreateUser }` | IAM | 2 or more events in 5 minutes |
| `security-group-changed` | `{ $.eventName = *SecurityGroup }` | SecurityGroup | 1 or more events in 5 minutes |
| `lambda-invoked` | `{ $.eventName = *LambdaInvoked }` | Lambda | 1 or more events in 5 minutes |

Alerts are defined in the `metrics` list in `modules/trails/alarms.tf`. Add an entry there to monitor another event.

## Structure

```
main.tf                    # AWS provider (us-east-1) and module calls
modules/trails/
  main.tf                  # CloudTrail
  cloudwatch.tf            # log group
  role.tf                  # IAM role and policy for CloudTrail -> CloudWatch Logs
  s3.tf                    # bucket and bucket policy
  alarms.tf                # metric filters and alarms
  sns.tf                   # SNS topic and subscription
  variables.tf
```

## Usage

Requirements: Terraform and the AWS CLI configured with credentials.

```bash
terraform init
terraform fmt
terraform plan
terraform apply      # type "yes" to confirm
terraform destroy    # remove everything it created
```

Before applying, set the notification target in `modules/trails/sns.tf`. It currently uses the `sms` protocol with a placeholder phone number; switch `protocol` to `email` and set `endpoint` to an address if you prefer email.

## Known issues

- The root `main.tf` points the modules at `./modules/`, but the code lives in `./modules/trails`, so `terraform init` fails until the `source` is changed to `./modules/trails`.
- The root file calls the module twice (`aws-cloudtrail` and `aws-alarm`) and also declares its own `trails` log group, which duplicates the one in the module. One call is enough.
- The `random` provider (used for the bucket name) is not declared in `required_providers`.
- The AWS provider is pinned to `~> 3.5.0`, which is old.
