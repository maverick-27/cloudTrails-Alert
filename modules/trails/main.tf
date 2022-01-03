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
