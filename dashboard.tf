/*
resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "MyInfrastructureDashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_launch_template.cms_lt}" ]
        ],
        "title": "EC2 CPU Utilization",
        "period": 300,
        "stat": "Average",
        "region": "${var.aws_region}"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.cms_rds}" ],
          [ ".", "DatabaseConnections", ".", "." ]
        ],
        "title": "RDS CPU Utilization & Connections",
        "period": 300,
        "stat": "Average",
        "region": "${var.aws_region}"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.external_lb}" ],
          [ ".", "HTTPCode_ELB_4XX_Count", ".", "." ],
          [ ".", "HTTPCode_ELB_5XX_Count", ".", "." ]
        ],
        "title": "Load Balancer Requests and Errors",
        "period": 300,
        "stat": "Sum",
        "region": "${var.aws_region}"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/CloudFront", "Requests", "DistributionId", "${aws_cloudfront_distribution.www_distribution}" ],
          [ ".", "BytesDownloaded", ".", "." ]
        ],
        "title": "CloudFront Traffic",
        "period": 300,
        "stat": "Sum",
        "region": "${var.aws_region}"
      }
    }
  ]
}
EOF
}
*/
