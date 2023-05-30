  resource "random_string" "autogenerated_password" {
    length  = 16
    special = false
  }

resource "aws_ssm_parameter" "rabbit_password" {
  count       = !var.create_aws_activemq && var.create_aws_ec2_rabbitmq ? 1: 0
  name        = "/${var.environment_name}/rabbit/PASSWORD"
  description = "Rabbit Password"
  type        = "SecureString"
  value       = random_string.autogenerated_password.result

}

resource "aws_ssm_parameter" "rabbit_username" {
  count       = !var.create_aws_activemq && var.create_aws_ec2_rabbitmq ? 1: 0
  name        = "/${var.environment_name}/rabbit/USERNAME"
  description = "Rabbit Username"
  type        = "String"
  value       = "admin"

}

resource "aws_ssm_parameter" "rabbit_endpoint" {
  count       = !var.create_aws_activemq && var.create_aws_ec2_rabbitmq ? 1: 0
  name        = "/${var.environment_name}/rabbit/ENDPOINT"
  description = "Rabbit Endpoint"
  type        = "String"
  value       = "${aws_instance.ec2_rabbitmq_master[0].private_ip}"
  depends_on = [
    aws_instance.ec2_rabbitmq_master
  ]
}

resource "aws_ssm_parameter" "active_password" {
  count       = var.create_aws_activemq && !var.create_aws_ec2_rabbitmq ? 1 : 0
  name        = "/${var.environment_name}/activemq/PASSWORD"
  description = "Activemq Password"
  type        = "SecureString"
  value       = random_string.autogenerated_password.result
}

resource "aws_ssm_parameter" "activemq_username" {
  count       = var.create_aws_activemq && !var.create_aws_ec2_rabbitmq ? 1 : 0
  name        = "/${var.environment_name}/activemq/USERNAME"
  description = "Rabbit Username"
  type        = "String"
  value       = "admin"

}

resource "aws_ssm_parameter" "activemq_endpoint" {
  count       = var.create_aws_activemq && !var.create_aws_ec2_rabbitmq ? 1 : 0
  name        = "/${var.environment_name}/activemq/ENDPOINT"
  description = "Activemq Endpoint"
  type        = "String"
  value       = "${aws_mq_broker.activemq[0].instances[0].console_url}"

}

resource "aws_mq_broker" "activemq" {
  count       = var.create_aws_activemq && !var.create_aws_ec2_rabbitmq ? 1 : 0
  broker_name = "${var.project_name_prefix}-Activemq"

  engine_type                = var.engine_type
  engine_version             = var.engine_version
  storage_type               = var.storage_type
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  host_instance_type         = var.host_instance_type
  security_groups            =  ["${aws_security_group.rabbit_sg.id}"]
  deployment_mode            = var.deployment_mode
  subnet_ids                 = var.subnet_ids
  publicly_accessible        = var.publicly_accessible
  logs {
    audit   = var.audit_logs
    general = var.general_logs
  }

  user {
    username       = var.activemq_username
    password       = var.activemq_password != "" ? var.activemq_password : random_string.autogenerated_password.result

    console_access = var.console_access
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = file(try(var.master_user_data_path,"${path.module}/user_data.sh"))
  vars = {
    environment_name = var.environment_name
    region           = var.region
  }
}

resource "aws_instance" "ec2_rabbitmq_master" {
  count                   = !var.create_aws_activemq && var.create_aws_ec2_rabbitmq ? var.master: 0
                         
  ami                     = var.ami_id == "" ? data.aws_ami.amazon-linux-2.id : var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.ec2_subnet_id
  vpc_security_group_ids  = ["${aws_security_group.rabbit_sg.id}"]
  key_name                = var.key_name
  iam_instance_profile    = "${aws_iam_instance_profile.rabbit-instance-profile.name}" 
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  user_data        = data.template_file.user_data.rendered
  source_dest_check       = var.source_dest_check
  disable_api_stop        = var.disable_api_stop

  volume_tags = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-Rabbit-MQ-Master" }))
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-Rabbit-MQ-Master"}))

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
    kms_key_id            =  var.kms_key_id  
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
  }

   depends_on = [
    aws_ssm_parameter.rabbit_password    
  ]
}

data "template_file" "user_data_worker" {
  template = file(try(var.worker_user_data_path,"${path.module}/worker.sh"))
  vars = {
    environment_name = var.environment_name
    region           = var.region
    Name             = "${var.project_name_prefix}-Rabbit-MQ-Master"
  }
}


resource "aws_instance" "ec2_rabbitmq_worker" {
  count                   = !var.create_aws_activemq && var.create_aws_ec2_rabbitmq ? var.worker: 0
  
  ami                     = data.aws_ami.amazon-linux-2.id
  instance_type           = var.instance_type
  subnet_id               = var.ec2_subnet_id
  vpc_security_group_ids  = ["${aws_security_group.rabbit_sg.id}"]
  key_name                = var.key_name
  iam_instance_profile    = "${aws_iam_instance_profile.rabbit-instance-profile.name}"
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  user_data               = data.template_file.user_data_worker.rendered
  source_dest_check       = var.source_dest_check
  disable_api_stop        = var.disable_api_stop

  volume_tags = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-Rabbit-MQ-worker" }))
  tags        = merge(var.common_tags, tomap({ "Name" : "${var.project_name_prefix}-Rabbit-MQ-worker"}))

  root_block_device {
    delete_on_termination = var.delete_on_termination
    encrypted             = var.encrypted
    kms_key_id            =  var.kms_key_id  
    volume_size           = var.root_volume_size
    volume_type           = var.volume_type
  }
 depends_on = [
    aws_instance.ec2_rabbitmq_master
  ]
}


###security group for rabbit
resource "aws_security_group" "rabbit_sg" {
  
  name   = "${var.rabbit_sg_name}"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
    ingress {
    from_port   = 8162
    to_port     = 8162
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol = "icmp"
    cidr_blocks        = ["${var.vpc_cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.rabbit_sg_name}"
  }
}


###IAM policy for rabbit instance

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "rabbit-role" {
  name               = "${var.environment_name}-${var.region}-rabbit_role"
  path               = "/system/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}
resource "aws_iam_instance_profile" "rabbit-instance-profile" {
  name = "${var.environment_name}-${var.region}-rabbit-instance-profile"
  role = "${aws_iam_role.rabbit-role.name}"
}
resource "aws_iam_role_policy" "ec2-describe-instance-policy" {
  name = "${var.environment_name}-${var.region}-ec2-describe-instance-policy"
  role = "${aws_iam_role.rabbit-role.id}"
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:DescribeTags",
                  "ssm:GetParameterHistory",
                  "ssm:GetParameters",
                  "ssm:GetParameter"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

