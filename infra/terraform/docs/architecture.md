# Architecture Overview

## High-Level Diagram

```
Internet
    │
    ▼
[Route 53 / Domain]
    │
    ▼
[Application Load Balancer]  ←── Public Subnet (AZ-a, AZ-b)
    │
    ▼
[EKS Worker Nodes]           ←── Private Subnet (AZ-a, AZ-b)
    │         │
    │         ▼
    │    [Pods: myapp x2]
    │    [Pods: prometheus]
    │    [Pods: grafana]
    │
    ▼
[AWS Services]
    ├── ECR (Docker images)
    ├── CloudWatch (logs + alarms)
    ├── SNS (email alerts)
    └── S3 (Terraform state)

[Bastion Host] ←── Public Subnet (admin SSH access only)
    │
    └── kubectl access to private EKS nodes
```

## Network Architecture

```
VPC: 10.0.0.0/16
├── Public Subnets
│   ├── 10.0.1.0/24 (us-east-1a) — ALB, NAT GW, Bastion
│   └── 10.0.2.0/24 (us-east-1b) — ALB, NAT GW
└── Private Subnets
    ├── 10.0.3.0/24 (us-east-1a) — EKS Nodes
    └── 10.0.4.0/24 (us-east-1b) — EKS Nodes
```

## CI/CD Flow

```
Developer → git push → GitHub
                           │
                    GitHub Actions
                           │
                    ┌──────┴──────┐
                    │             │
                  Tests        Build
                 (pytest)    (Docker)
                    │             │
                    └──────┬──────┘
                           │
                    Push to ECR
                           │
                    Deploy via Helm
                    (EKS production)
                           │
                    Verify Rollout
                           │
                    Notify Slack
```

## Security Model

- EKS nodes in private subnets (no direct internet access)
- NAT Gateways for outbound internet from nodes
- Bastion host for admin access (SSH restricted by IP)
- IRSA (IAM Roles for Service Accounts) for pod-level AWS access
- ECR image scanning enabled on push
- Trivy vulnerability scanning in CI pipeline
- Pod runs as non-root user
- PodDisruptionBudget ensures availability during updates
