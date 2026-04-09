aws_region         = "ap-south-1"
vpc_id             = "vpc-062f3afc84e953ea2"
cluster_name       = "akshay-cluster-v01"
cluster_subnet_ids = ["subnet-05ffdbb0846720ccb", "subnet-00547251cf4622393"]
node_subnet_ids    = ["subnet-05ffdbb0846720ccb", "subnet-00547251cf4622393"]
node_group_name    = "pc-node-group-v01"
instance_types     = ["t3.small"]
desired_size       = 2
min_size           = 1
max_size           = 6
environment        = "dev"
kubernetes_version = "1.28"

# RBAC Configuration - Add your IAM user/role for access
additional_iam_users = [
  {
    userarn  = "arn:aws:iam::123456789012:user/akshay"
    username = "akshay"
    groups   = ["system:masters"]
  }
]

additional_iam_roles = [
  # Add additional roles if needed
]

tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "EKS"
}
