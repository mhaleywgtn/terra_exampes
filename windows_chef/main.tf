# this is an example off website: http://datatomix.com/?p=318

# Set the target provider
provider "aws" {
  region = "eu-west-1"
}

# Set an admin password for the configuration
variable "admin_password" {
  default     = "ChefDemo,1"
}

# Create an new Security Group for WinRM and RDP
resource "aws_security_group" "default" {
  name        = "terraform-windows-server"
  description = "Terraform Windows Security Group"

  # WinRM access from anywhere
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Set the right Windows Server 2012R2 AMI
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

# Create a new EC2 instance with Chef as provisioner
resource "aws_instance" "windows" {
  provisioner "chef" {
  server_url      = "https://api.chef.io/organizations/pb_cjo"
  user_name       = "cjohannsen"
  user_key        = "${file("~/Downloads/chef-repo-2/.chef/cjohannsen.pem")}"
  node_name       = "windows-server01"
  run_list        = [ "puttyWindows" ]
  version         = "12.4.1"
  }
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "ChefDemo,1"
  }
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.amazon_windows_2012R2.image_id}"
  key_name = "cjohannsen"
  security_groups = ["${aws_security_group.default.name}"]
  user_data = <<EOF
    <script>
      winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
    </script>
    <powershell>
      netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
      $admin = [adsi]("WinNT://./administrator, user")
      $admin.psbase.invoke("SetPassword", "${var.admin_password}")
    </powershell>
  EOF
}

# Show the public IP address at the end
output "address" {
  value = "${aws_instance.windows.public_ip}"
}
