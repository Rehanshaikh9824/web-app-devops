terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Remote state in S3 — create this bucket before first apply
  backend "s3" {
    bucket         = "devops-project-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  project_name = "devops-webapp"
  cluster_name = "devops-eks-cluster"
  environment  = "production"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

# ── VPC ───────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  project_name         = local.project_name
  cluster_name         = local.cluster_name
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  tags                 = local.common_tags
}

# ── IAM ───────────────────────────────────────────────────────────────────────
module "iam" {
  source       = "../../modules/iam"
  project_name = local.project_name
  tags         = local.common_tags
}

# ── Security Groups ───────────────────────────────────────────────────────────
module "security" {
  source            = "../../modules/security"
  project_name      = local.project_name
  vpc_id            = module.vpc.vpc_id
  admin_cidr_blocks = [var.admin_ip_cidr]
  tags              = local.common_tags
}

# ── ECR Repository ────────────────────────────────────────────────────────────
module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "devops-webapp"
  tags            = local.common_tags
}

# ── EKS Cluster ───────────────────────────────────────────────────────────────
module "eks" {
  source = "../../modules/eks"

  cluster_name              = local.cluster_name
  kubernetes_version        = "1.29"
  cluster_role_arn          = module.iam.cluster_role_arn
  node_role_arn             = module.iam.node_role_arn
  cluster_security_group_id = module.security.eks_cluster_sg_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  aws_region                = var.aws_region
  environment               = local.environment
  instance_types            = ["t3.medium"]
  desired_nodes             = 2
  min_nodes                 = 1
  max_nodes                 = 4
  tags                      = local.common_tags
}

# ── Bastion Host ──────────────────────────────────────────────────────────────
module "bastion" {
  source           = "../../modules/bastion"
  project_name     = local.project_name
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id    = module.security.bastion_sg_id
  ssh_public_key   = var.ssh_public_key
  cluster_name     = local.cluster_name
  aws_region       = var.aws_region
  tags             = local.common_tags
}

# ── Monitoring ────────────────────────────────────────────────────────────────
module "monitoring" {
  source       = "../../modules/monitoring"
  project_name = local.project_name
  cluster_name = local.cluster_name
  aws_region   = var.aws_region
  alert_email  = var.alert_email
  tags         = local.common_tags
}
