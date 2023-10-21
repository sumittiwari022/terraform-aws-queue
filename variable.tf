variable "create_aws_activemq" {
  type        = bool
  description = "If you want to create the AWS active-mq enable this check"
  default     = false
}

variable "create_aws_ec2_rabbitmq" {
  type        = bool
  description = "If you want to create the AWS EC2 instance rabbit-mq enable this check"
  default     = true
}

variable "project_name_prefix" {
  description = "A string value to describe prefix of all the resources"
  type        = string
}

variable "master_user_data_path" {
  description = "Path for userdata file"
  type = string
  default = ""
}

variable "worker_user_data_path" {
  description = "Path for userdata file"
  type = string
  default = ""
}

variable "engine_type" {
  type        = string
  description = "Type of broker engine, `ActiveMQ` or `RabbitMQ`"
  default     = "ActiveMQ"
}

variable "engine_version" {
  type        = string
  description = "The version of the broker engine. See https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html for more details"
  default     = "5.15.14"
}

variable "storage_type" {
  type        = string
  description = "Type of storage"
  default     = "ebs"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "host_instance_type" {
  type        = string
  description = "The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
  default     = "mq.m5.large"
}

variable "deployment_mode" {
  type        = string
  description = "The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
  default     = "SINGLE_INSTANCE"
}

variable "subnet_ids" {
  description = "The VPC Subnet IDs to launch in"
  type        = list(string)
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets"
  default     = true
}

variable "activemq_username" {
  type        = string
  description = "Admin username"
  default     = ""
}

variable "activemq_password" {
  type        = string
  description = "Admin password"
  default     = ""
  sensitive   = true
}

variable "console_access" {
  type        = bool
  description = "Whether to enable console access"
  default     = true
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "common_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}

variable "project" {
  type    = string
  default = "test"
}

variable "ec2_subnet_id" {
  description = "The VPC Subnet IDs to launch in"
  type        = string
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
}

variable "vpc_cidr_block" {
  default     = "0.0.0.0/0"
  description = "CIDR for SG"
}

variable "vpc_id" {
  description = "vpc id for rabbit"
  default     = ""
}
variable "rabbit_sg_name" {
  default     = "rabbit-sg"
  description = "SG name for rabbit"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t4g.medium"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = true
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection."
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "source_dest_check" {
  description = "Source destination Check. Used for NAT or VPNs."
  type        = bool
  default     = true
}

variable "delete_on_termination" {
  description = "Whether EBS volume will be deleted when instance gets deleted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
    type    = string
    description = "KMS key ID for creating AWS resources"
}


variable "encrypted" {
  description = "Whether EBS volume will be encrypted."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size of the EC2 instance"
  type        = number
  default     = 50
}

variable "volume_type" {
  description = "Volume type for EC2 instance default latest type"
  type        = string
  default     = "gp3"
}

variable "audit_logs" {
  type        = bool
  description = "If you want to enable audit log for active-mq this check"
  default     = false
}

variable "general_logs" {
  type        = bool
  description = "If you want to enable general log for active-mq this check"
  default     = false
}

variable worker {
  type        = number
  default     = 1
  description = "number of worker node"
}

variable master {
  type        = number
  default     = 1
  description = "number of master node"
}

variable "secret_method" {
  description = "Use ssm for SSM parameters store which is the default option, or secretsmanager for AWS Secrets Manager"
  type        = string
  default     = "ssm"
}

variable "ssm_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS Key Id to use a CMK instead of default shared key for SSM parameters"
}

variable environment_name {
  type        = string
  default     = "prod"
  description = "Environment name"
}

variable region {
  type        = string
  default     = "af-south-1"
  description = "Region where resources will deploy"
}
variable "ami_id" {
  type = string
  description = "AMI id of the Amazon Linux 2"
  default = ""
}
