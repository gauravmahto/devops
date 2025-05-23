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

## 🆙 Upgrading to Helm: Migration & Troubleshooting Guide

This section documents the process of migrating from raw Kubernetes YAML manifests to a robust, production-ready Helm chart for both the backend (Spring Boot/Postgres) and frontend, as well as key troubleshooting steps and solutions.

### Migration Steps

1. **Initial State:**
   - All deployments and services were managed via YAML files in the `k8s/` directory.
   - Backend, frontend, and Postgres were deployed using `kubectl apply -f ...`.

2. **Helm Chart Creation:**
   - Created `backend/Chart.yaml`, `values.yaml`, and `templates/` for backend Helm chart.
   - Parameterized image, resources, and DB connection info in `values.yaml`.
   - Converted backend deployment and service YAMLs to Helm templates.
   - Added `.helmignore` to exclude large files (e.g., JARs) from Helm packaging.

3. **Postgres as a Helm Subchart:**
   - Created a `charts/postgres` subchart for Postgres, templating deployment, service, and secret.
   - Added Postgres as a dependency in `backend/Chart.yaml` and updated with `helm dependency update`.
   - Parameterized DB credentials and service names for flexibility.

4. **Frontend & Ingress Migration:**
   - Converted frontend deployment and service to Helm templates.
   - Migrated Ingress to Helm, parameterizing backend and frontend service names.

5. **Service Name Consistency:**
   - Fixed Ingress to route `/api/(.*)` to the correct backend service name (`my-backend`), matching the Helm chart output.
   - Removed legacy service names (e.g., `my-backend-service`) from Ingress and values.

6. **Cleanup of Old Resources:**
   - Deleted old deployments and services (`kubectl delete deployment my-backend`, `kubectl delete svc my-backend`) to avoid immutable field errors during Helm upgrades.
   - Ensured no orphaned ReplicaSets or Services remained before redeploying.

7. **Helm Upgrade & Validation:**
   - Ran `helm upgrade --install my-backend ./backend` to deploy the full stack.
   - Verified all pods (`my-backend`, `frontend-app`, `postgres`) were running and healthy.
   - Checked logs (`kubectl logs deployment/my-backend`) to confirm backend startup and DB connectivity.
   - Used `kubectl describe ingress my-app-ingress` to ensure correct routing.

8. **Troubleshooting 503 Errors:**
   - Identified 503 errors were due to Ingress routing to a non-existent service name.
   - Fixed Ingress template to use the correct backend service name.
   - Redeployed and confirmed frontend could reach backend API successfully.

### Key Commands

```sh
# Remove old resources to avoid Helm conflicts
kubectl delete deployment my-backend
kubectl delete svc my-backend

# Update Helm dependencies (ignore large files)
helm dependency update ./backend

# Deploy or upgrade with Helm
helm upgrade --install my-backend ./backend

# Check pod and service status
kubectl get pods
kubectl get svc

# Check logs and ingress
kubectl logs deployment/my-backend
kubectl describe ingress my-app-ingress
```

### Best Practices Learned

- Always ensure service names in Ingress match those created by Helm.
- Use `.helmignore` to avoid packaging large build artifacts.
- Clean up old K8s resources before switching to Helm to avoid immutable field errors.
- Parameterize all environment variables and connection info in `values.yaml` for flexibility.
- Use subcharts for dependencies like Postgres for modularity and reuse.

---

podman rmi -f my-backend
podman rmi -f docker.io/library/my-backend:latest

kubectl set image deployment/my-backend my-backend=docker.io/library/my-backend:latest --record
