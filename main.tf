terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudtrail" "my-trail" {
  name                          = "my-trail"
  s3_bucket_name                = aws_s3_bucket.trail-bucket.id
  s3_key_prefix                 = "trails"
  include_global_service_events = true
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail-roles.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trails.arn}:*"
  depends_on                    = [aws_s3_bucket_policy.bucket-policy]
}

resource "aws_cloudwatch_log_group" "trails" {
  name = "trails"
}



resource "aws_cloudwatch_metric_alarm" "metric-alarms" {
  for_each = {
    for m in local.metrics : m.name => m
  }
  alarm_name        = "${each.value.name}-alarm"
  alarm_description = "metric from cloudtrail"
  metric_name       = each.value.name
  namespace         = each.value.namespace

  comparison_operator = each.value.alarm.comparison_operator
  evaluation_periods  = each.value.alarm.evaluation_periods
  period              = each.value.alarm.period
  statistic           = each.value.alarm.statistic
  threshold           = each.value.alarm.threshold
  alarm_actions = [
    aws_sns_topic.trail-log-metrics.arn
  ]
}

resource "aws_cloudwatch_log_metric_filter" "trail-metrics" {
  for_each = {
    for m in local.metrics : m.name => m
  }
  name           = each.value.name
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.trails.name
  metric_transformation {
    name      = each.value.name
    namespace = each.value.namespace
    value     = "1"
  }
}
