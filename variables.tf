variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment for the deployment (dev or prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "The desired number of instances"
  type        = number
  default     = 1
}

variable "zone_name" {
  description = "The DNS zone name for Route53"
  type        = string
  default     = "<hostname>.<domain>"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}
