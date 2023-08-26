data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "b51-tf-remote-state-bucket"
    key    = "vpc/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "b51-tf-remote-state-bucket"
    key    = "alb/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}


# Fecthes the AMI ID of the AMI To Use
data "aws_ami" "myami" {
  most_recent      = true
  name_regex       = "b51-ansible-base"
  owners           = ["self"]
}

# Fecthing the information of the existing secret which has multiple values
data "aws_secretsmanager_secret" "robot-secrets" {
  name = "robot/secrets"
}

# Fecthing the ID of the secret version of the above secret
data "aws_secretsmanager_secret_version" "robot-secrets" {
  secret_id = data.aws_secretsmanager_secret.robot-secrets.id
}

# Using data source to fetch the DocDB Endpoint.
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "b51-tf-remote-state-bucket"
    key    = "databases/dev/terraform.tfstate"
    region = "us-east-1"
  }
}