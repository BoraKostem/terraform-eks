variable "vault_role_id" {
    description = "Vault role id"
    type = string
}

variable "vault_secret_id" {
    description = "Vault secret id"
    type = string
}

variable "aws_region" {
    description = "AWS region"
    default     = "us-west-2"
  
}