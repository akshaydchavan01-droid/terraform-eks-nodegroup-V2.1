terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # NEW: Add Kubernetes provider for aws-auth ConfigMap
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }

  backend "s3" {
    bucket         = "our-terraform-tfstate-file-bucket-6150"
    key            = "Server-terraform"
    region         = "ap-south-1"
    dynamodb_table = "my-dynamo-db-practice-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# NEW: Kubernetes provider configuration
provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# NEW: Get authentication token for Kubernetes provider
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
}
