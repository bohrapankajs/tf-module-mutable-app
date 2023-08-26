# Locals : Locals are used to elimate the repitative things, like functions in bash 
locals {
  ALL_INSTANCE_IDS = concat(aws_spot_instance_request.spot.*.spot_instance_id, aws_instance.od.*.id)
  ALL_INSTANCE_IPS = concat(aws_spot_instance_request.spot.*.private_ip, aws_instance.od.*.private_ip)
}