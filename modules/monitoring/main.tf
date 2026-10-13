resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

locals {
  alarms = {
    alb-5xx = {
      namespace  = "AWS/ApplicationELB"
      metric     = "HTTPCode_Target_5XX_Count"
      statistic  = "Sum"
      comparison = "GreaterThanOrEqualToThreshold"
      threshold  = 10
      dimensions = tomap({ LoadBalancer = var.alb_arn_suffix })
    }
    unhealthy-web-hosts = {
      namespace  = "AWS/ApplicationELB"
      metric     = "UnHealthyHostCount"
      statistic  = "Maximum"
      comparison = "GreaterThanThreshold"
      threshold  = 0
      dimensions = tomap({ LoadBalancer = var.alb_arn_suffix, TargetGroup = var.target_group_arn_suffix })
    }
    web-cpu-high = {
      namespace  = "AWS/EC2"
      metric     = "CPUUtilization"
      statistic  = "Average"
      comparison = "GreaterThanThreshold"
      threshold  = var.cpu_threshold
      dimensions = tomap({ AutoScalingGroupName = var.web_asg_name })
    }
    app-cpu-high = {
      namespace  = "AWS/EC2"
      metric     = "CPUUtilization"
      statistic  = "Average"
      comparison = "GreaterThanThreshold"
      threshold  = var.cpu_threshold
      dimensions = tomap({ AutoScalingGroupName = var.app_asg_name })
    }
    rds-cpu-high = {
      namespace  = "AWS/RDS"
      metric     = "CPUUtilization"
      statistic  = "Average"
      comparison = "GreaterThanThreshold"
      threshold  = var.cpu_threshold
      dimensions = tomap({ DBInstanceIdentifier = var.rds_instance_id })
    }
    rds-low-storage = {
      namespace  = "AWS/RDS"
      metric     = "FreeStorageSpace"
      statistic  = "Minimum"
      comparison = "LessThanThreshold"
      threshold  = 5368709120 # 5 GiB
      dimensions = tomap({ DBInstanceIdentifier = var.rds_instance_id })
    }
    cache-cpu-high = {
      namespace  = "AWS/ElastiCache"
      metric     = "EngineCPUUtilization"
      statistic  = "Average"
      comparison = "GreaterThanThreshold"
      threshold  = var.cpu_threshold
      # node -001 of the replication group
      dimensions = tomap({ CacheClusterId = "${var.cache_replication_group_id}-001" })
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.alarms

  alarm_name          = "${var.name}-${each.key}"
  namespace           = each.value.namespace
  metric_name         = each.value.metric
  statistic           = each.value.statistic
  comparison_operator = each.value.comparison
  threshold           = each.value.threshold
  dimensions          = each.value.dimensions
  period              = 300
  evaluation_periods  = 2
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
