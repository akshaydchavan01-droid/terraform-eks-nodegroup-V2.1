aws_region         = "ap-south-1"
vpc_id             = "vpc-0862211fae4a6daf4"
cluster_name       = "akshay-cluster-v01"
cluster_subnet_ids = ["subnet-01287583dac06eae7", "subnet-0a77e63e5fc311562"]
node_subnet_ids    = ["subnet-01287583dac06eae7", "subnet-0a77e63e5fc311562"]
node_group_name    = "pc-node-group-v01"
instance_types     = ["t3.small"]
desired_size       = 2
min_size           = 1
max_size           = 4
environment        = "dev"
kubernetes_version = "1.32"

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
