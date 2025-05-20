#!/bin/bash

set -e

# === CONFIG ===
BACKEND_NAME="my-backend"
FRONTEND_NAME="frontend-app"
REGISTRY_TAG="docker.io/library"

# === AUTO-INCREMENT BACKEND IMAGE TAG ===
TAG_FILE=".backend_image_tag"
if [ -f "$TAG_FILE" ]; then
  BACKEND_IMAGE_TAG=$(cat $TAG_FILE)
  BACKEND_IMAGE_TAG=$((BACKEND_IMAGE_TAG + 1))
else
  BACKEND_IMAGE_TAG=1
fi
echo $BACKEND_IMAGE_TAG > $TAG_FILE

echo "🚀 Starting Deployment..."

# === CLEANUP OLD CONTAINERS ===
echo "🧹 Stopping and removing old Podman containers (if any)..."
podman stop backend frontend my-backend registry 2>/dev/null || true
podman rm backend frontend my-backend registry 2>/dev/null || true

# === OPTIONAL: CLEAN UNUSED IMAGES ===
echo "🧼 Cleaning up unused images..."
podman image prune -f || true

# === BUILD IMAGES ===
echo "🔨 Building backend image from ./backend"
cd backend
mvn clean package
cd ..
podman build --no-cache -t ${BACKEND_NAME}:v${BACKEND_IMAGE_TAG} ./backend

echo "🔨 Building frontend image from ./frontend"
podman build -t ${FRONTEND_NAME} ./frontend

# === TAG FOR MINIKUBE ===
echo "🏷️ Tagging images for Minikube..."
podman tag ${BACKEND_NAME}:v${BACKEND_IMAGE_TAG} ${REGISTRY_TAG}/${BACKEND_NAME}:v${BACKEND_IMAGE_TAG}
podman tag ${FRONTEND_NAME} ${REGISTRY_TAG}/${FRONTEND_NAME}:latest

# === LOAD IMAGES INTO MINIKUBE ===
echo "📦 Loading images into Minikube..."
minikube image load ${REGISTRY_TAG}/${BACKEND_NAME}:v${BACKEND_IMAGE_TAG}
minikube image load ${REGISTRY_TAG}/${FRONTEND_NAME}:latest

# === ENABLE INGRESS ===
echo "🔧 Ensuring Ingress controller is enabled..."
minikube addons enable ingress || true

# === APPLY KUBERNETES MANIFESTS ===
echo "📄 Applying Kubernetes deployments..."
sed "s|image: docker.io/library/my-backend:.*|image: docker.io/library/my-backend:v${BACKEND_IMAGE_TAG}|" k8s/backend-deployment.yaml > k8s/backend-deployment.yaml.tmp
kubectl apply -f k8s/backend-deployment.yaml.tmp
echo "🔄 Waiting for rollout..."
kubectl rollout restart deployment/my-backend
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/ingress.yaml
rm k8s/backend-deployment.yaml.tmp

echo "🔍 Verifying backend health after 20 seconds..."
for i in {20..1}; do
  echo "⏳ Waiting for $i seconds..."
  sleep 1
done
curl --fail http://myapp.local/api/health || echo "❌ Backend health check failed"

# === FINAL MESSAGE ===
echo ""
echo "✅ All components deployed successfully!"
echo "📌 If not done already, add this line to your /etc/hosts file:"
echo ""
echo "   127.0.0.1 myapp.local"
echo ""
echo "🌐 Open your browser and navigate to: http://myapp.local"
