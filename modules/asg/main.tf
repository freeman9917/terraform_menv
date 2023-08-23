resource "aws_launch_template" "my_launch_template" {
    name = "${var.env_prefix}-template"
    image_id = "ami-04e601abe3e1a910f"
    instance_type = "t2.micro"
    key_name = "my-${var.env_prefix}-key"
    user_data = filebase64("./modules/asg/launch_template_install.sh")
 
    network_interfaces {
        associate_public_ip_address = true
        security_groups = [var.security_groups]
    }

    iam_instance_profile {
        name = "myrole1"
  }


  tags = {
    Name = "${var.env_prefix}-launch-template"
  }
}

resource "aws_autoscaling_group" "my-asg" {
    name = "${var.env_prefix}-asg"
    max_size = 3
    min_size = 1
    desired_capacity = 2
    health_check_grace_period = 300
    health_check_type = "ELB"
    vpc_zone_identifier = [var.pub1_subnet_id, var.pub2_subnet_id]
    target_group_arns = [var.target_group_id]


    
    metrics_granularity = "1Minute"
    launch_template {
        id = aws_launch_template.my_launch_template.id
    }
}

###scale up####
resource "aws_autoscaling_policy" "scale-up" {
    name = "${var.env_prefix}-asg-scale-up"
    autoscaling_group_name = aws_autoscaling_group.my-asg.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

####scale up alarm######
resource "aws_cloudwatch_metric_alarm" "scale-up-alarm" {
    alarm_name = "${var.env_prefix}-asg-scale-up-alarm"
    alarm_description = "asg-scale-up-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "30"
    dimensions = {
        "AutoscalingGroupName" = aws_autoscaling_group.my-asg.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.scale-up.arn]
}

#####scale down#############
resource "aws_autoscaling_policy" "scale-down" {
    name = "${var.env_prefix}-asg-scale-down"
    autoscaling_group_name = aws_autoscaling_group.my-asg.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

#####scale down alarm############
resource "aws_cloudwatch_metric_alarm" "scale-down-alarm" {
    alarm_name = "${var.env_prefix}-asg-scale-down-alarm"
    alarm_description = "asg-scale-down-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "5"
    dimensions = {
        "AutoscalingGroupName" = aws_autoscaling_group.my-asg.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.scale-down.arn]
}



#################key-pair#############################
resource "aws_key_pair" "my_key"{
    key_name = "my-${var.env_prefix}-key"
    public_key = tls_private_key.rsa.public_key_openssh
    
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_file" "my-priv-key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "my-${var.env_prefix}-priv-key"

}