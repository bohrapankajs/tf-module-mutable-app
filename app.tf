resource "null_resource" "app" {

  triggers = {
     always_run = timestamp()   # Everytime, timestamp changes. So, obviously this provisioner runs all the time
  }

  count = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT 

  provisioner "remote-exec" {
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = element(local.ALL_INSTANCE_IPS, count.index)
  }
    inline = [
      "ansible-pull -U https://github.com/b51-clouddevops/ansible.git -e DOCDB_ENDPOINT=${data.terraform_remote_state.db.outputs.DOCDB_ENDPOINT} -e ansible_user=centos -e ansible_password=DevOps321 -e DB_PASSWORD=RoboShop@1 -e COMPONENT=${var.COMPONENT} -e APP_VERSION=${var.APP_VERSION} -e ENV=dev roboshop-pull.yml"
    ]
  }
}

# Note: Provisioners are create time by defaut.
# What it means ?  Provisioners will only run during the resource creation, rest of the times, they won't run.

# But, we can define when this provisioner has to run.

# In my case, I want provisioner to run all the time, whenever I run the job