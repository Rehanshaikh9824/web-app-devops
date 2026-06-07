output "vpc_id"              { value = module.vpc.vpc_id }
output "eks_cluster_name"    { value = module.eks.cluster_name }
output "eks_cluster_endpoint"{ value = module.eks.cluster_endpoint }
output "ecr_repository_url"  { value = module.ecr.repository_url }
output "bastion_public_ip"   { value = module.bastion.bastion_public_ip }
output "sns_topic_arn"       { value = module.monitoring.sns_topic_arn }

output "next_steps" {
  value = <<-EOT
    ✅ Infrastructure deployed!

    1. Update kubeconfig:
       aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}

    2. Verify nodes:
       kubectl get nodes

    3. Push Docker image to ECR:
       ${module.ecr.repository_url}

    4. Deploy with Helm (from infra-repo root):
       helm upgrade --install myapp ./helm/myapp --namespace production --create-namespace
  EOT
}
