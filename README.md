# MY-DEVOPS 🔧🚀

This project demonstrates a **production-ready DevOps pipeline** using:

- 🐳 **Podman** for containerization
- ☸️ **Kubernetes** (via Minikube) for orchestration
- 🛠️ **NGINX Ingress** for unified routing
- 🔥 **Spring Boot** backend (`/api/hello`)
- 🌐 **Static HTML frontend** served via NGINX
- 🖥️ **Bash automation** via `deploy.sh`

---

## 📁 Project Structure

```
MY-DEVOPS/
├── backend/                   # Spring Boot backend
├── frontend/                  # Static frontend (HTML + JS)
├── k8s/                       # Kubernetes manifests
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   └── ingress.yaml
├── deploy.sh                  # One-click deploy script
└── README.md                  # You're here!
```

---

## 🚀 Quick Start

### 🔧 Prerequisites

- [Podman](https://podman.io/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- `kubectl` CLI
- macOS/Linux

---

### ✅ 1. Setup `/etc/hosts`

Ensure the following is added to your hosts file:
```bash
127.0.0.1 myapp.local
```

On macOS/Linux:
```bash
sudo nano /etc/hosts
```

---

### ✅ 2. Run the Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

This script will:
- Clean up old containers
- Build backend and frontend images
- Tag and load images into Minikube
- Enable NGINX Ingress
- Apply all K8s manifests

---

### ✅ 3. Access the Application

Visit:
```
http://myapp.local
```

You’ll see:
- The frontend served via NGINX
- The backend message fetched from `/api/hello` (no CORS issues)

---

## 🛠️ Troubleshooting

| Issue | Fix |
|-------|-----|
| ❌ `CORS error` | Now resolved using unified domain via Ingress |
| ❌ Port already in use (Podman) | Run `podman ps -a` → `podman stop` & `rm` |
| ❌ Images not found in Minikube | Use `podman tag` with `docker.io/library/...` and `minikube image load` |
| ❌ Cannot access `http://myapp.local` | Make sure `/etc/hosts` is updated |

---

## 📌 Notes

- All services use **`ClusterIP`**, and routing is handled through **Ingress**.
- Podman avoids using Docker daemon and works rootlessly.
- Designed for local development, easily extendable to CI/CD later.

---

## 📃 License

This project is open for educational, testing, and DevOps learning use.

---

## 🤝 Contributions

Want to add:
- GitHub Actions?
- Helm charts?
- Terraform infrastructure?

Feel free to fork and PR!

---

podman rmi -f my-backend
podman rmi -f docker.io/library/my-backend:latest

kubectl set image deployment/my-backend my-backend=docker.io/library/my-backend:latest --record

