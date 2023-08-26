# Creates SPOT Server
resource "aws_spot_instance_request" "spot" {
  count                        = var.SPOT_INSTANCE_COUNT
  ami                          = data.aws_ami.myami.image_id
  instance_type                = var.INSTANCE_TYPE
  wait_for_fulfillment         = true
  vpc_security_group_ids       = [aws_security_group.allow_app.id]
  subnet_id                    = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_ID, count.index)
  iam_instance_profile         = "b51-admin-role"

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}


# Creates On-Demand-Server
resource "aws_instance" "od" {
  count                      = var.OD_INSTANCE_COUNT
  ami                        = data.aws_ami.myami.image_id
  instance_type              = var.INSTANCE_TYPE
  vpc_security_group_ids     = [aws_security_group.allow_app.id]
  subnet_id                  = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_ID, count.index)
  iam_instance_profile       = "b51-admin-role"
}




# tags for ec2
resource "aws_ec2_tag" "name-tags" {
  count       = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  resource_id = element(local.ALL_INSTANCE_IDS, count.index)
  key         = "Name"
  value       = "${var.COMPONENT}-${var.ENV}"
}

# tags for ec2 prometheus-monitor 
resource "aws_ec2_tag" "prometheus-tags" {
  count       = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  resource_id = element(local.ALL_INSTANCE_IDS, count.index)
  key         = "prometheus-monitor"
  value       = "yes"
}