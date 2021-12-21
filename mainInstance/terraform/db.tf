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

resource "aws_elb" "log8415-DB-ELB" {
  name = "log8415-DB-elb"
  subnets = "${data.aws_subnet.test_subnet.*.id}"
  security_groups = [aws_security_group.log8415-DB.id]
  instances       = "${aws_instance.log8415-DB.*.id}"

  listener {
    instance_port     = 6379
    instance_protocol = "tcp"
    lb_port           = 6379
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = 5002
    instance_protocol = "tcp"
    lb_port           = 5002
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = 5003
    instance_protocol = "tcp"
    lb_port           = 5003
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
    listener {
    instance_port     = 9000
    instance_protocol = "tcp"
    lb_port           = 9000
    lb_protocol       = "tcp"
  }
}
output "ec2instance_log8415-DB" {
  value = aws_instance.log8415-DB.public_ip
}

output "awsElb_log8415-DB" {
  value = aws_elb.log8415-DB-ELB.dns_name
}

