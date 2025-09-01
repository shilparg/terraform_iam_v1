locals {
 name_prefix = "shilpa"
}

# Creating IAM Role, Policies and Instance Profile

resource "aws_iam_role" "role_example" {
 name = "${local.name_prefix}-role-example"


 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "ec2.amazonaws.com"
       }
     },
   ]
 })
}


data "aws_iam_policy_document" "policy_example" {
 statement {
   effect    = "Allow"
   actions   = ["ec2:Describe*"]
   resources = ["*"]
 }
 statement {
   effect    = "Allow"
   actions   = ["s3:ListBucket"]
   resources = ["*"]
 }
}

resource "aws_iam_policy" "policy_example" {
 name = "${local.name_prefix}-policy-example"

 ## Option 1: Attach data block policy document
 policy = data.aws_iam_policy_document.policy_example.json

}

resource "aws_iam_role_policy_attachment" "attach_example" {
 role       = aws_iam_role.role_example.name
 policy_arn = aws_iam_policy.policy_example.arn
}

resource "aws_iam_instance_profile" "profile_example" {
 name = "${local.name_prefix}-profile-example"
 role = aws_iam_role.role_example.name
}

##Creating the EC2 Instance
resource "aws_instance" "public" {
  ami                         = "ami-00ca32bbc84273381" # find the AMI ID of Amazon Linux 2023  instance_type               = "t2.micro"
  subnet_id                   = "subnet-04834306679bc0f62"  #Public Subnet ID, e.g. subnet-xxxxxxxxxxx
  instance_type               = "t2.micro"               # ✅ Required argument
  associate_public_ip_address = true
  key_name                    = "shilpa-key-pair" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.profile_example.name

 
  tags = {
    Name = "${local.name_prefix}-ec2"    #Prefix your own name, e.g. jazeel-ec2
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "shilpa-terraform-security-group" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  #vpc_id      = "vpc-037a1fde3abdbc8fc"  #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
  vpc_id      = data.aws_vpc.selected.id  #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
