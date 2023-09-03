resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "webserver-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors ec2 instance CPU utilization"
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:automate:eu-central-1:ec2:stop" , aws_sns_topic.topic.arn]
  dimensions          = {
    InstanceId = aws_instance.ec2_instance.id
  }
}