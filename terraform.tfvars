aws_region         = "ap-south-1"
vpc_id             = "vpc-09eb7603712eb1ff8"
cluster_name       = "akshay-cluster-v01"
cluster_subnet_ids = ["subnet-0532fb9cd78e3d75f", "subnet-0ec94393235cb3f26"]
node_subnet_ids    = ["subnet-0532fb9cd78e3d75f", "subnet-0ec94393235cb3f26"]
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
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/YOUR_IAM_USER"  # Replace with your IAM user ARN
    username = "YOUR_IAM_USER"
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