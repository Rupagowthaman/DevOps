terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }
  }
}


# configured aws provider with proper credentials
provider "aws" {
  region    = "eu-central-1"
#   profile   =
  access_key = "ASIAWUXGJJQEOA5LLCVU"
  secret_key = "42n81Zhrzk0Rmyqsl3TJIJvy+XadCLZK7KJHwzSs"
  token = "IQoJb3JpZ2luX2VjECcaDGV1LWNlbnRyYWwtMSJGMEQCIEugzAssKPDuvdcRWv8Xj5L5QxIoxDKxnefkZMHI81k5AiBcua1kcv0yq66RzIPMlKd24ujXu8f8OSGWvdnXI9tFbCqrAwjw//////////8BEAEaDDQ1NjgyMzIyOTQ0OCIM8KPPK0zZQQGbILcTKv8Cc3Sc0uzXTJoqcpMnG9DIQoD5Sf+fYNkUqv/XvPG1EEftjnA9yYFuz85A3lTV3yx74GEd0yjC8PjmSeN6AXxg1sthipo3M/wEMiwyBFPw74LGIhbNhRveu4auJ7bgOsqHzPhV9BSJgVpTtcGY5RvRcVgnbOdWPexgbbvmAvhlSGeX3pLi8vPAdZZfUBrKEMpBCKLHp60BNmcxbVAe6KXV6HdM51tUauK9rvQ4RY0IFU3cQI/lPG0LjCfzBn2uVC1N8yG5lQ9fQGoy+46yHKU1p0IaDTtUpRTqshrjZibWYTBJeRGdEs9hbMJUCKMa1hZHz25VbHt7195ODH6EhI3rarbpZV5wjc+l6N4aMYQIC+LQTU9pDmAfDqdePwU2IZFl4cas3jeZWw7WVSawBxBKKjguVCU3IxjF0fMYof+iXhIn+TKLU9Gmzl6sP4WkXbEEHT9rsyeG3sF9xgVYVXFGX4X2c8eYaCRAZvAjdVcIZR/K4Kyqs7JVPsrhXX0yjkcwkv/HpwY6pwFJqcFidsHcDZfrXcMVHwKE04kCYrMHY6ZYC8oNlwl8XnY0sZWeulhIDGBgD4iuHky2MzigqVrgdN2BplXlRXFREAWJOe8zea2f8eg/JgTkTkHGTzs7mNw5JXtnQ9amdXmw4lN3vroZohNz8o9cAfcFXtpxTSZiLecyU8/3+kuPkXxeNhph2xSeaIhDwc8NYQWXWxvvDhUu2I6FGKxkz9QDqbMuvA2+zQ=="
  }


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "ec2 security group"
  }
}


# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0766f68f0b06ab145"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "ssh-key"
  user_data              = file("web.sh")

  tags = {
    Name = "Receipes-server"
  }
}


# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}