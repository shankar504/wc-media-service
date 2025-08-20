variable "vpc_id" {
    description = "vpc id of hanwha-vision-vpc"
    type = string
    default = "vpc-012ae848bc2ca2e2a"
}
variable "region" {
  type        = string
  description = "AWS Deployment region.."
  default     = "us-west-2"
}
variable "lt_name" {
  description = "Name of the Launch Template"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type for the Launch Template"
  type        = string
  default     = "t3.medium"
}
variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "NonprodDuclo"
}
variable "volume_size" {
  description = "Volume size"
  type        = number
  default     = 100
}
variable "volume_type" {
  description = "volume type of ec2"
  type        = string
  default     = "gp3"
}
variable "device_name" {
  description = "strorage device name for launch template ec2"
  type        = string
  default     = "/dev/xvda"
}
variable "image_name" {
  description = "strorage device name for launch template ec2"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "health_check_type" {
  description = "health check type for the ASG"
  type        = string
  default     = "EC2"
}

variable "Private_subnets" {
    description = "List of Private subnest available in duclo-vpc"
    type = list(string)
    default     = ["subnet-04a42b1a5edb20b8e","subnet-0905bf6d928e6ef26","subnet-0cbda69b54942d834"]
}
