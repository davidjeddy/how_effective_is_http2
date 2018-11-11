# Create a new GitLab Lightsail Instance
provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region                  = "us-east-1"
  version                 = "~> 1.2.0"
}

resource "aws_lightsail_instance" "traffic_target" {
  provider          = "aws"
  name              = "Traffic_Target"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "nano_1_0"
  key_pair_name     = "http2_effectiveness"

  # This is where we configure the instance with ansible-playbook
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_DEBUG=1 ANSIBLE_COWSAY=0 ansible-playbook -i '${self.public_ip_address}', -u ubuntu --private-key ../shared/http2_effectiveness.pem ./master.yml"
  }

  connection {
    type        = "ssh"
    host        = "${self.public_ip_address}"
    private_key = "${file("../shared/http2_effectiveness.pem")}"
    user        = "ubuntu"
    timeout     = "60s"
  }
}

resource "aws_lightsail_static_ip" "traffic_target" {
  name = "traffic_target"
}

resource "aws_lightsail_static_ip_attachment" "traffic_target" {
  static_ip_name = "${aws_lightsail_static_ip.traffic_target.name}"
  instance_name  = "${aws_lightsail_instance.traffic_target.name}"
  depends_on = ["aws_lightsail_instance.traffic_target"]
}

output "public_ip_address" {
  value = "${aws_lightsail_static_ip.traffic_target.ip_address}"
}
