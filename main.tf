resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version   # Recommended: "1.29"

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.cluster_security_group_ids
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

# ✅ FIXED NODE GROUP
resource "aws_eks_node_group" "node_grp" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.node_subnet_ids

  capacity_type  = var.capacity_type
  disk_size      = var.disk_size
  instance_types = var.instance_types

  # ✅ IMPORTANT: Let AWS manage AMI
  ami_type = "AL2023_x86_64_STANDARD"

  labels = {
    env = var.environment
  }

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = merge(
    var.tags,
    {
      Name = var.node_group_name
    }
  )
}
# ✅ Outputs
output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS cluster endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
  description = "Base64 encoded certificate data"
}

output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "configure_kubectl" {
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}"
  description = "Command to configure kubectl"
}
