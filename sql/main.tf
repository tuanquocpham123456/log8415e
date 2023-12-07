provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
  token      = ""
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "final_security_group" {
  vpc_id      = data.aws_vpc.default.id
  name        = "final_security_group"
  description = "My final security group"

  #SSH use
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP use
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS use
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #All protocol
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  #All protocol
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "t2_micro_standalone" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Ubuntu 20.04 LTS image ID in us-east-1 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  count                  = 1
  private_ip             = "172.31.17.141"
  tags                   = {
    Name = "t2_micro_sql_standalone"
  }
}

/*resource "aws_instance" "t2_micro_manager" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Ubuntu 20.04 LTS image ID in us-east-1 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  private_ip             = "172.31.17.1"
  count                  = 1
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("final_project.pem")}"
    host        = "${self.private_ip}"
  }
  tags = {
    Name = "manager"
  }
}

resource "aws_instance" "t2_micro_worker" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Ubuntu 20.04 LTS image ID in us-est-2 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  private_ip             = "172.31.17.${count.index + 2}"
  count                  = 3
  tags = {
    Name = "worker-${count.index + 1}"
  }
}
*/