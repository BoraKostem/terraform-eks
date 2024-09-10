provider "vault" {
    address = "http://localhost:8200"
    skip_child_token = true

    auth_login {
        path = "auth/approle/login"
        parameters = {
            role_id   = var.vault_role_id
            secret_id = var.vault_secret_id
        }
    }
}

data "vault_kv_secret_v2" "aws_iam" {
  mount = "kv"
  name = "aws"
}

module "eks" {
    source = "./aws/eks"
    aws_region = var.aws_region
    aws_access_key = data.vault_kv_secret_v2.aws_iam.data["ACCESS_KEY"]
    aws_secret_key = data.vault_kv_secret_v2.aws_iam.data["SECRET_ACCESS_KEY"]
}