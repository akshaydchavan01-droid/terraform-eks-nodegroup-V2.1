aws_region         = "ap-south-1"
vpc_id             = "vpc-0d09ee699cc84cc8f"
cluster_name       = "akshay-cluster-v01"
cluster_subnet_ids = ["subnet-0378c45c056a86558", "subnet-0563897eb2258addb"]
node_subnet_ids    = ["subnet-0378c45c056a86558", "subnet-0563897eb2258addb"]
node_group_name    = "pc-node-group-v01"
instance_types     = ["t3.small"]
desired_size       = 2
min_size           = 1
max_size           = 4
environment        = "dev"
kubernetes_version = "1.35"

# RBAC Configuration - Add your IAM user/role for access
additional_iam_users = [
  {
    userarn  = "arn:aws:iam::637423619587:user/devops-admin"
    username = "devops-admin"
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
