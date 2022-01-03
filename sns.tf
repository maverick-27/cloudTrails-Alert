resource "aws_sns_topic" "trail-log-metrics" {
  name = "trail-log-metrics-topic"
}
resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.trail-log-metrics.arn
  protocol  = "sms"
  endpoint  = "+91 7009498574"
}
