# ── CloudWatch Log Groups ─────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/devops/${var.project_name}/application"
  retention_in_days = 14
  tags              = var.tags
}

# ── SNS Topic for Alerts ──────────────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── CloudWatch Alarms ─────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "CPU utilization exceeded 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "node_not_ready" {
  alarm_name          = "${var.project_name}-node-not-ready"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "cluster_node_count"
  namespace           = "ContainerInsights"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  dimensions = {
    ClusterName = var.cluster_name
  }
  alarm_description = "EKS cluster node count dropped below threshold"
  alarm_actions     = [aws_sns_topic.alerts.arn]
  tags              = var.tags
}

# ── CloudWatch Dashboard ──────────────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title   = "EKS Cluster CPU"
          metrics = [["AWS/EC2", "CPUUtilization"]]
          period  = 60
          stat    = "Average"
          region  = var.aws_region
        }
      },
      {
        type = "log"
        properties = {
          title   = "Application Logs"
          query   = "SOURCE '/devops/${var.project_name}/application' | fields @timestamp, @message | sort @timestamp desc | limit 50"
          region  = var.aws_region
          view    = "table"
        }
      }
    ]
  })
}

output "sns_topic_arn"          { value = aws_sns_topic.alerts.arn }
output "cloudwatch_dashboard_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home#dashboards:name=${var.project_name}-dashboard"
}

variable "project_name" { type = string }
variable "cluster_name" { type = string }
variable "aws_region"   { type = string }
variable "alert_email"  { type = string }
variable "tags"         { type = map(string); default = {} }
