provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAXM3UIMQSN5PDBFNY"
  secret_key = "ktNJagiPAUDVO9lGsrBO4OlCWe2nlcMKhjRn65tg"
  token = "FwoGZXIvYXdzED8aDESNPL/lmJa+17PFhyLKAZO7gHamloLSxLVH03bdwbEIQMR8ILWi2OMKHED5PoaoLvnBl5vaUb4SJjC/4WJipaFmUrrwD55DjIlBmhYZTP4qnDO9PE2K0mxgz3mdeCqRqQsd8j/Oh5+OZuQCvXPnCAaj26++xj66p1x+yigYaPaNhkVix7W3ZCnz7sN+tpbQQKpF1g+P76B6IABsVcDIGbgJJnowc9KdQ/2IFc5d6EitBgPayDRrBA7ftMO/0ZpnqFVGVitdUJ8HMIgQ/44RS2D6dbcrNiIsnw4o4N7DqwYyLYd5yaIfONdsuYzoz9rUkcyt6xjR4OrVzSFZ5xkyGcpssJV6ahG39sRRb6rbWg=="
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
}

resource "aws_instance" "t2_micro_standalone" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Ubuntu 20.04 LTS image ID in us-east-1 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  count                  = 1

  tags = {
    Name = "t2_micro_sql_standalone"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mysql-server sysbench"
    ]
  }
}

resource "aws_instance" "t2_micro_manager" {
  ami                    = "ami-0fc5d935ebf8bc3bc"  # Ubuntu 20.04 LTS image ID in us-east-1 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  private_ip             = "172.31.17.1"
  count                  = 1

  tags = {
    Name = "manager"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mysql-server sysbench libncurses5",
      "mkdir -p /opt/mysqlcluster/home",
      "cd /opt/mysqlcluster/home",
      "wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz",
      "tar xvf mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz",
      "ln -s mysql-cluster-gpl-7.2.1-linux2.6-x86_64 mysql",
      "echo ‘export MYSQLC_HOME=/opt/mysqlcluster/home/mysqlc’ > /etc/profile.d/mysqlc.sh",
      "echo ‘export PATH=$MYSQLC_HOME/bin:$PATH’ >> /etc/profile.d/mysqlc.sh",
      "source /etc/profile.d/mysqlc.sh",
      "mkdir -p /opt/mysqlcluster/deploy",
      "cd /opt/mysqlcluster/deploy",
      "mkdir conf",
      "mkdir mysqld_data",
      "mkdir ndb_data",
      "cd conf",

      "echo '[mysqld]",
      "ndbcluster",
      "datadir=/opt/mysqlcluster/deploy/mysqld_data",
      "basedir=/opt/mysqlcluster/home/mysqlc",
      "port=3306' | tee -a my.cnf",

      "echo '[ndb_mgmd]",
      "hostname=ip-172-31-17-1.ec2.internal",
      "datadir=/opt/mysqlcluster/deploy/ndb_data",
      "nodeid=1",

      "[ndbd default]",
      "noofreplicas=3",
      "datadir=/opt/mysqlcluster/deploy/ndb_data",
      "[ndbd]",
      "hostname=ip-172-31-17-2.ec2.internal",
      "nodeid=2",
      "[ndbd]",
      "hostname=ip-172-31-17-3.ec2.internal",
      "nodeid=3",
      "[ndbd]",
      "hostname=ip-172-31-17-4.ec2.internal",
      "nodeid=4",
      "[mysqld]",
      "nodeid=50'",

      "cd /opt/mysqlcluster/home/mysqlc",
      "scripts/mysql_install_db –-no-defaults --datadir=/opt/mysqlcluster/deploy/mysqld_data"
    ]
  }
}

resource "aws_instance" "t2_micro_worker" {
  ami                    = "ami-0a91cd140a1fc148a"  # Ubuntu 20.04 LTS image ID in us-est-2 region
  instance_type          = "t2.micro"
  key_name               = "final_project"
  vpc_security_group_ids = [aws_security_group.final_security_group.id]
  subnet_id              = "subnet-0cf73552fbe274b6b"
  private_ip             = "172.31.17.${count.index + 2}"
  count                  = 3

  tags = {
    Name = "worker-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mysql-server sysbench libncurses5",
      "mkdir -p /opt/mysqlcluster/home",
      "cd /opt/mysqlcluster/home",
      "wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz",
      "tar xvf mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz",
      "ln -s mysql-cluster-gpl-7.2.1-linux2.6-x86_64 mysql",
      "echo ‘export MYSQLC_HOME=/opt/mysqlcluster/home/mysqlc’ > /etc/profile.d/mysqlc.sh",
      "echo ‘export PATH=$MYSQLC_HOME/bin:$PATH’ >> /etc/profile.d/mysqlc.sh",
      "source /etc/profile.d/mysqlc.sh",
      "mkdir -p /opt/mysqlcluster/deploy/ndb_data"
    ]
  }
}