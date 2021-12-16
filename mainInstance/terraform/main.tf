provider "aws" {
region = "us-east-1"
}

variable "api" {
  type = map(string)
  default = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.micro"
    keyname = "myseckey"
    secgroupname = "log8415-API"
    }
}

variable "worker" {
  type = map(string)
  default = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.medium"
    keyname = "myseckey"
    secgroupname = "log8415-Worker"
    }
}

resource "aws_security_group" "log8415-API" {
  name = var.api.secgroupname
  description = var.api.secgroupname
  vpc_id = var.api.vpc

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "log8415-WORKER" {
  name = var.worker.secgroupname
  description = var.worker.secgroupname
  vpc_id = var.worker.vpc

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "log8415-API" {
  ami = var.api.ami
  instance_type = var.api.itype
  key_name = var.api.keyname


  vpc_security_group_ids = [
    aws_security_group.log8415-API.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "API"
  }

  depends_on = [ aws_security_group.log8415-API ]
}

resource "aws_instance" "log8415-WORKER" {
  ami = var.worker.ami
  instance_type = var.worker.itype
  key_name = var.worker.keyname


  vpc_security_group_ids = [
    aws_security_group.log8415-WORKER.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "WORKER"
  }

  depends_on = [ aws_security_group.log8415-WORKER ]
}

output "ec2instance_log8415-API" {
  value = aws_instance.log8415-API.public_ip
}
output "ec2instance_log8415-WORKER" {
  value = aws_instance.log8415-WORKER.public_ip
}

