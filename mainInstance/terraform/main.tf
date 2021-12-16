provider "aws" {
region = "us-east-1"
}

variable "awsprops" {
    type = "map"
  api = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.micro"
    keyname = "myseckey"
    secgroupname = "log8415-API"
  }
  worker = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.medium"
    keyname = "myseckey"
    secgroupname = "log8415-Worker"
  }
}

resource "aws_security_group" "log8415-API" {
  name = lookup(var.awsprops.api, "secgroupname")
  description = lookup(var.awsprops.api, "secgroupname")
  vpc_id = lookup(var.awsprops.api, "vpc")

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
  name = lookup(var.awsprops.worker, "secgroupname")
  description = lookup(var.awsprops.worker, "secgroupname")
  vpc_id = lookup(var.awsprops.worker, "vpc")

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
  ami = lookup(var.awsprops.api, "ami")
  instance_type = lookup(var.awsprops.api, "itype")
  key_name = lookup(var.awsprops.api, "keyname")


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
  ami = lookup(var.awsprops.worker, "ami")
  instance_type = lookup(var.awsprops.worker, "itype")
  key_name = lookup(var.awsprops.worker, "keyname")


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

output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
