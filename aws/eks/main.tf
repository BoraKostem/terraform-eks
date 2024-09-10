module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  create_iam_role   = false
  iam_role_arn = aws_iam_role.eks-role.arn
  cluster_security_group_id = aws_security_group.cluster-group.id

  authentication_mode = "API_AND_CONFIG_MAP"

  cluster_enabled_log_types = []
  create_cloudwatch_log_group = false

  cluster_name    = "eks-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    node1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}