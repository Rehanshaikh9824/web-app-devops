# 🏗️ DevOps Infrastructure Repository

AWS infrastructure for the DevOps Web App — managed with **Terraform**, deployed on **EKS**, monitored with **Prometheus + Grafana**.

---

## 📁 Repository Structure

```
infra-repo/
├── terraform/
│   ├── modules/
│   │   ├── vpc/               # VPC, subnets, NAT gateways
│   │   ├── eks/               # EKS cluster + node group
│   │   ├── ecr/               # ECR repository + lifecycle
│   │   ├── iam/               # IAM roles and policies
│   │   ├── security/          # Security groups
│   │   ├── bastion/           # EC2 jump server
│   │   └── monitoring/        # CloudWatch + SNS alerts
│   └── environments/
│       └── prod/
│           ├── main.tf        # Root module — calls all submodules
│           ├── variables.tf
│           ├── outputs.tf
│           └── terraform.tfvars.example
├── helm/
│   └── myapp/                 # Helm chart for the web app
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── hpa.yaml
│           └── serviceaccount.yaml
├── k8s/
│   ├── namespaces.yaml        # production + monitoring namespaces
│   └── monitoring.yaml        # Prometheus + Grafana stack
└── docs/
    └── architecture.md
```

---

## 🔧 Prerequisites

```bash
# Install tools
brew install terraform awscli kubectl helm  # macOS
# or use apt/yum on Linux

# Verify versions
terraform --version   # >= 1.6
aws --version
kubectl version --client
helm version
```

---

## 🚀 Deployment Guide

### Step 1 — Bootstrap Terraform Remote State

```bash
# Create S3 bucket for state
aws s3 mb s3://devops-project-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket devops-project-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name devops-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2 — Deploy Infrastructure

```bash
cd terraform/environments/prod

# Copy and fill in your values
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Init, plan, apply
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 3 — Configure kubectl

```bash
aws eks update-kubeconfig \
  --name devops-eks-cluster \
  --region us-east-1

# Verify cluster access
kubectl get nodes
kubectl get namespaces
```

### Step 4 — Deploy Monitoring Stack

```bash
kubectl apply -f k8s/namespaces.yaml
kubectl apply -f k8s/monitoring.yaml

# Wait for pods to be ready
kubectl get pods -n monitoring -w
```

### Step 5 — Deploy Application with Helm

```bash
# Update image in values.yaml first, then:
helm upgrade --install myapp helm/myapp \
  --namespace production \
  --create-namespace \
  --set image.repository=<YOUR_ECR_URI>/devops-webapp \
  --set image.tag=latest \
  --wait

# Check deployment
kubectl get pods -n production
kubectl get svc -n production
```

---

## 📊 Monitoring Access

```bash
# Grafana (get external IP)
kubectl get svc grafana -n monitoring

# Prometheus (port-forward)
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# App logs
kubectl logs -l app=myapp -n production --tail=100 -f
```

**Grafana Login:** admin / admin123 (change immediately!)

**Recommended Grafana Dashboards to import:**
- Kubernetes Cluster Overview: `315`
- Node Exporter Full: `1860`
- Flask Application Metrics: `11159`

---

## 🔐 AWS Infrastructure Overview

| Resource         | Details                                    |
|------------------|--------------------------------------------|
| VPC              | 10.0.0.0/16, 2 AZs                        |
| Public Subnets   | 10.0.1.0/24, 10.0.2.0/24                  |
| Private Subnets  | 10.0.3.0/24, 10.0.4.0/24                  |
| NAT Gateways     | 1 per AZ (HA)                             |
| EKS Version      | 1.29                                       |
| Node Type        | t3.medium (auto-scales 1–4)               |
| ECR              | devops-webapp (image scan on push)        |
| Bastion          | t3.micro in public subnet                 |
| Monitoring       | CloudWatch + SNS email alerts             |

---

## 🧹 Teardown

```bash
# Remove app
helm uninstall myapp -n production

# Remove monitoring
kubectl delete -f k8s/monitoring.yaml

# Destroy infrastructure
cd terraform/environments/prod
terraform destroy
```
