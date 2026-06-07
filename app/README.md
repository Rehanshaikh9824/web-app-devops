# 🚀 DevOps Web Application — App Repository

Production-ready Flask web app deployed on **AWS EKS** via **GitHub Actions CI/CD**.

---

## 📁 Repository Structure

```
app-repo/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions pipeline
├── app/
│   ├── main.py                # Flask application
│   └── requirements.txt       # Python dependencies
├── tests/
│   └── test_app.py            # Unit tests
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yml         # Local dev environment
└── README.md
```

---

## 🔧 Local Development

### Prerequisites
- Python 3.11+
- Docker & Docker Compose

### Run Locally
```bash
# Clone the repo
git clone https://github.com/YOUR_ORG/web-app-devops-repo.git
cd devops-app-repo

# Option 1: Python directly
pip install -r app/requirements.txt
python app/main.py

# Option 2: Docker Compose (includes Prometheus + Grafana)
docker compose up --build
```

**Endpoints:**
| Route       | Description               |
|-------------|---------------------------|
| `/`         | Main web UI               |
| `/health`   | Liveness probe            |
| `/ready`    | Readiness probe           |
| `/metrics`  | App metrics (JSON)        |

---

## 🧪 Running Tests

```bash
pip install pytest pytest-cov
pytest tests/ -v --cov=app
```

---

## 🐳 Docker

```bash
# Build image
docker build -t devops-webapp:latest .

# Run container
docker run -p 5000:5000 -e APP_ENV=production devops-webapp:latest

# Push to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

docker tag devops-webapp:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-webapp:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-webapp:latest
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline in `.github/workflows/ci-cd.yml` runs on every push to `main`:

```
Push to main
    │
    ▼
[1] Run Unit Tests (pytest)
    │
    ▼
[2] Build Docker Image
    │
    ▼
[3] Scan Image (Trivy)
    │
    ▼
[4] Push to AWS ECR
    │
    ▼
[5] Deploy to EKS via Helm
    │
    ▼
[6] Verify Rollout
    │
    ▼
[7] Notify Slack
```

### Required GitHub Secrets

| Secret                 | Description                          |
|------------------------|--------------------------------------|
| `AWS_ACCESS_KEY_ID`    | GitHub Actions IAM user key ID       |
| `AWS_SECRET_ACCESS_KEY`| GitHub Actions IAM user secret key   |
| `INFRA_REPO_TOKEN`     | PAT with access to infra repo        |
| `SLACK_WEBHOOK_URL`    | Slack incoming webhook (optional)    |

---

## 📊 Application URLs (after deployment)

- **App URL:** `http://<EKS-LB-DNS>/`
- **Grafana:** `http://<Grafana-LB-DNS>/` (admin / admin123)
- **Prometheus:** Internal ClusterIP — port-forward to access

```bash
# Access Prometheus locally
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# Access Grafana locally
kubectl port-forward svc/grafana 3000:80 -n monitoring
```
