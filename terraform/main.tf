
provider "aws" {
 region = "ap-south-1"
}

############################
# UBUNTU AMI
############################

data "aws_ami" "ubuntu" {

most_recent = true
owners = ["099720109477"]

filter {
name = "name"
values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

}

############################
# VPC
############################

resource "aws_vpc" "devops_vpc" {

cidr_block = "10.0.0.0/16"
enable_dns_hostnames = true

tags = {
Name = "devops-vpc"
}

}

############################
# SUBNET
############################

resource "aws_subnet" "public_subnet" {

vpc_id = aws_vpc.devops_vpc.id
cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = true

tags = {
Name = "public-subnet"
}

}

############################
# INTERNET GATEWAY
############################

resource "aws_internet_gateway" "igw" {

vpc_id = aws_vpc.devops_vpc.id

}

############################
# ROUTE TABLE
############################

resource "aws_route_table" "public_rt" {

vpc_id = aws_vpc.devops_vpc.id

route {

cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id

}

}

resource "aws_route_table_association" "rt_assoc" {

subnet_id = aws_subnet.public_subnet.id
route_table_id = aws_route_table.public_rt.id

}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "jenkins" {

name = "jenkins-sg"
vpc_id = aws_vpc.devops_vpc.id

ingress {

from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]

}

ingress {

from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]

}

egress {

from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]

}

}

############################
# EC2 MASTER
############################

resource "aws_instance" "master" {

ami = data.aws_ami.ubuntu.id
instance_type = "t2.small"
subnet_id = aws_subnet.public_subnet.id
vpc_security_group_ids = [aws_security_group.jenkins.id]

associate_public_ip_address = true

root_block_device {

volume_size = 15
volume_type = "gp2"

}

tags = {

Name = "jenkins-master"

}

}

############################
# EC2 AGENT
############################

resource "aws_instance" "agent" {

ami = data.aws_ami.ubuntu.id
instance_type = "t2.small"
subnet_id = aws_subnet.public_subnet.id
vpc_security_group_ids = [aws_security_group.jenkins.id]

associate_public_ip_address = true

root_block_device {

volume_size = 15
volume_type = "gp2"

}

tags = {

Name = "jenkins-agent"

}

}

############################
# OUTPUTS
############################

output "master_ip" {

value = aws_instance.master.public_ip

}

output "agent_ip" {

value = aws_instance.agent.public_ip

}

