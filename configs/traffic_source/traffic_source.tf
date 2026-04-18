# Create a new GitLab Lightsail Instance
provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region                  = "us-east-1"
  version                 = "~> 1.2.0"
}

resource "aws_lightsail_instance" "traffic_source" {
  provider          = "aws"
  name              = "Traffic_Source"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "nano_1_0"
  key_pair_name     = "http2_effectiveness"

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = "sleep 60;  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip_address}', -u ubuntu --private-key ../shared/http2_effectiveness.pem ./master.yml"
  }

  connection {
    type        = "ssh"
    host        = "${self.public_ip_address}"
    private_key = "${file("../shared/http2_effectiveness.pem")}"
    user        = "ubuntu"
    timeout     = "15s"
  }
}

output "public_ip_address" {
  value = "${aws_lightsail_instance.traffic_source.public_ip_address}"
}
