data "aws_vpc" "selected" {
 filter {
   name   = "tag:Name"
   values = ["ce11-tf-vpc-*"] # to be replaced with your VPC name
 }
}