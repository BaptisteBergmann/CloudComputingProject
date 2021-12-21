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
  vpc_id = var.api.vpc
}
data "aws_subnet" "test_subnet" {
  count = "${length(data.aws_subnet_ids.subnet_ids.ids)}"
  id    = "${tolist(data.aws_subnet_ids.subnet_ids.ids)[count.index]}"
}

resource "aws_elb" "log8415-API-ELB" {
  name = "log8415-API-elb"
  subnets = "${data.aws_subnet.test_subnet.*.id}"
  security_groups = [aws_security_group.log8415-API.id]
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
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  
}

output "ec2instance_log8415-API" {
  value = "${aws_instance.log8415-API.*.public_ip}"
}

output "awsElb_log8415-API" {
  value = aws_elb.log8415-API-ELB.dns_name
}

