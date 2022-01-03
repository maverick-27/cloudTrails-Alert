locals {
  metrics = [
    {
      "name" : "new-user-created",
      "pattern" : "{ $.eventName = CreateUser }",
      "namespace" : "IAM",
      "alarm" : {
        "comparison_operator" : "GreaterThanOrEqualToThreshold",
        "evaluation_periods" : 1,
        "period" : 300,
        "statistic" : "Sum",
        "threshold" : 2,
      }
    },
    {
      "name" : "security-group-changed",
      "pattern" : "{ $.eventName = *SecurityGroup }",
      "namespace" : "SecurityGroup",
      "alarm" : {
        "comparison_operator" : "GreaterThanOrEqualToThreshold",
        "evaluation_periods" : 1,
        "period" : 300,
        "statistic" : "Sum",
        "threshold" : 1,
      },
    },
    {
      "name" : "lambda-invoked",
      "pattern" : "{ $.eventName = *LambdaInvoked }",
      "namespace" : "Lambda",
      "alarm" : {
        "comparison_operator" : "GreaterThanOrEqualToThreshold",
        "evaluation_periods" : 1,
        "period" : 300,
        "statistic" : "Sum",
        "threshold" : 1,
      }
    }
  ]
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




