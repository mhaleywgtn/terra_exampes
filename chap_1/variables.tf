variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
  }
  
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
  }

