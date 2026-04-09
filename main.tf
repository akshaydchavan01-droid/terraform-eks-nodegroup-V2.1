resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

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

resource "aws_eks_node_group" "node_grp" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.node_subnet_ids
  capacity_type   = var.capacity_type
  disk_size       = var.disk_size
  instance_types  = var.instance_types
  version         = var.kubernetes_version

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

# NEW: aws-auth ConfigMap to grant IAM access to Kubernetes RBAC
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      # Node IAM role mapping
      [
        {
          rolearn  = aws_iam_role.worker.arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = ["system:bootstrappers", "system:nodes"]
        }
      ],
      # Additional IAM roles (if needed)
      var.additional_iam_roles
    ))
    
    mapUsers = yamlencode(var.additional_iam_users)
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.node_grp
  ]
}

# NEW: Output for cluster access
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