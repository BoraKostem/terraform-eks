variable "aws_region" {
    description = "AWS region"
    default     = "us-west-2"
  
}

variable "aws_access_key" {
    description = "AWS access key"
    type = string
}

variable "aws_secret_key" {
    description = "AWS secret"
    type = string
}