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
    keyname = "log8415-API"
    secgroupname = "log8415-API"
    count = "2"
    }
}

variable "db" {
  type = map(string)
  default = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.micro"
    keyname = "log8415-DB"
    secgroupname = "log8415-DB"
    }
}
variable "worker" {
  type = map(string)
  default = {
    region = "us-east-1"
    vpc = "vpc-032556978aaa97712"
    ami = "ami-04505e74c0741db8d"
    itype = "t2.medium"
    keyname = "log8415-Worker"
    secgroupname = "log8415-Worker"
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

resource "aws_security_group" "log8415-DB" {
  name = var.db.secgroupname
  description = var.db.secgroupname
  vpc_id = var.db.vpc

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 5000
    protocol = "tcp"
    to_port = 5003
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 9000
    protocol = "tcp"
    to_port = 9000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 6379
    protocol = "tcp"
    to_port = 6379
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
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 5001
    protocol = "tcp"
    to_port = 5001
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
  count = var.api.count

  vpc_security_group_ids = [
    aws_security_group.log8415-API.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  tags = {
    Name ="API"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "API"
  }

  depends_on = [ aws_security_group.log8415-API ]
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "default"
}
data "aws_subnet" "test_subnet" {
  count = "${length(data.aws_subnet_ids.subnet_ids.ids)}"
  id    = "${tolist(data.aws_subnet_ids.subnet_ids.ids)[count.index]}"
}


resource "aws_elb" "log8415-API-ELB" {
  name = "log8415-API-elb"
  subnets = "${data.aws_subnet.test_subnet.*.id}"
  security_groups = [aws_security_group.log8415-API]
  instances       = "${aws_instance.log8415-API.*.id}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 5001
    instance_protocol = "http"
    lb_port           = 5001
    lb_protocol       = "http"
  }
}

resource "aws_instance" "log8415-DB" {
  ami = var.db.ami
  instance_type = var.db.itype
  key_name = var.db.keyname


  vpc_security_group_ids = [
    aws_security_group.log8415-DB.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  tags = {
    Name ="DB"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "DB"
  }

  depends_on = [ aws_security_group.log8415-DB ]
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
    Name ="Worker"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "WORKER"
  }

  depends_on = [ aws_security_group.log8415-WORKER ]
}

output "ec2instance_log8415-WORKER" {
  value = aws_instance.log8415-WORKER.public_ip
}

output "ec2instance_log8415-DB" {
  value = aws_instance.log8415-DB.public_ip
}
output "ec2instance_log8415-API" {
  value = "${aws_instance.log8415-API.*.id}"
}


