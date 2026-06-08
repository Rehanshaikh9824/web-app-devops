from flask import Flask, jsonify, render_template_string
import os
import socket
import datetime

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Web App</title>
    <style>
        body { font-family: Arial, sans-serif; background: #0f172a; color: #e2e8f0; display: flex;
               align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
        .card { background: #1e293b; padding: 2rem 3rem; border-radius: 12px;
                box-shadow: 0 4px 24px rgba(0,0,0,0.4); text-align: center; }
        h1 { color: #38bdf8; margin-bottom: 0.5rem; }
        .badge { background: #0ea5e9; color: white; padding: 4px 12px;
                 border-radius: 20px; font-size: 0.85rem; margin: 0.5rem; display: inline-block; }
        .info { margin-top: 1.5rem; background: #0f172a; padding: 1rem;
                border-radius: 8px; font-size: 0.9rem; text-align: left; }
        .info p { margin: 0.4rem 0; }
        .label { color: #94a3b8; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 DevOps Web Application</h1>
        <p>Deployed on Azure AKS via CI/CD Pipeline</p>
        <span class="badge">Docker</span>
        <span class="badge">Kubernetes</span>
        <span class="badge">Terraform</span>
        <span class="badge">GitHub Actions</span>
        <div class="info">
            <p><span class="label">Hostname:</span> {{ hostname }}</p>
            <p><span class="label">Environment:</span> {{ env }}</p>
            <p><span class="label">Version:</span> {{ version }}</p>
            <p><span class="label">Timestamp:</span> {{ timestamp }}</p>
        </div>
    </div>
</body>
</html>
"""

@app.route("/")
def home():
    return render_template_string(HTML_TEMPLATE,
        hostname=socket.gethostname(),
        env=os.environ.get("APP_ENV", "production"),
        version=os.environ.get("APP_VERSION", "1.0.0"),
        timestamp=datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%d %H:%M:%S UTC")
    )

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.datetime.now(datetime.UTC).isoformat()}), 200

@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

@app.route("/metrics")
def metrics():
    return jsonify({
        "hostname": socket.gethostname(),
        "version": os.environ.get("APP_VERSION", "1.0.0"),
        "env": os.environ.get("APP_ENV", "production"),
        "uptime": "ok"
    }), 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
