resource "aws_security_group" "cluster-group" {
  name        = "eks-security-group"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

#   ingress {
#     description      = "Allow all traffic from within the security group"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["10.0.0.0/16"]  # Adjust this CIDR block to your VPC
#     security_groups  = [aws_security_group.eks_security_group.id]
#   }

  ingress {
    description      = "Allow all inbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}