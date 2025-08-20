# Launch template creation for auto scalling group
resource "aws_launch_template" "media-clipper-lt" {
  name = var.lt_name
  instance_type = var.instance_type
  key_name      = var.key_name
  image_id  = var.image_name //var.ami_id
  # update_default_version = true
  # for customised volume of ec2 instance
  block_device_mappings {
    device_name = var.device_name
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }
  iam_instance_profile {
    name = "clipper-service-role"
  }
  vpc_security_group_ids = ["sg-0f094ff753bc41e2a"]

  tags = {
    Category = "Media"
    ServiceName = "clipper"
    ResourceType = "Launch_Template"
  } 
  user_data = filebase64("./userdata.sh")
}
output "lt_id" {
  value = aws_launch_template.media-clipper-lt.id
}

resource "aws_autoscaling_group" "media-clipper-asg" {
  name = var.asg_name
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = var.Private_subnets
  health_check_type = var.health_check_type
  
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.media-clipper-lt.id
        version = "$Latest"
      }

    }
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      max_healthy_percentage = 110
      instance_warmup = "160"
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "launch version"
    value               = aws_launch_template.media-clipper-lt.latest_version
    propagate_at_launch = true
  }
  tag  {
    key = "Name"
    value = "DevMediaClipperServiceASG"
    propagate_at_launch = true
  }
 
depends_on = [aws_launch_template.media-clipper-lt]
}

# Create CloudWatch metric alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "asg_media_clipper_cpu_alarm" {
  alarm_name          = "mediaclipper-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # Change this to your desired threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.media-clipper-asg.name
  }
}

resource "aws_autoscaling_policy" "instance_refresh" {
  name                   = "instance_refresh"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown  = 180
  autoscaling_group_name = aws_autoscaling_group.media-clipper-asg.name
  depends_on = [aws_launch_template.media-clipper-lt]
}

# Create Dynamic Target Tracking Scaling Policy based on CPU Utilization
resource "aws_autoscaling_policy" "asg_media_clipper_cpu_policy" {
  name                   = "Target Tracking Policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = "180"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70  # Change this to your desired target value
  }

  autoscaling_group_name = aws_autoscaling_group.media-clipper-asg.name
}

#TG ASG attachment
#resource "aws_autoscaling_attachment" "media-clipper-tg" {
#  autoscaling_group_name = aws_autoscaling_group.keycloak-cluster-asg.name
#  lb_target_group_arn   = "arn:aws:elasticloadbalancing:us-west-2:699858537356:targetgroup/keycloak-cluster/794e05570aa2a02d"
#  depends_on = [aws_autoscaling_group.media-clipper-asg]
#}
