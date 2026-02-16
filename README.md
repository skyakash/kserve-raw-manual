# KServe Raw Deployment & Operator

This repository provides a streamlined way to deploy and manage **KServe** in **Raw Deployment** mode on vanilla Kubernetes, completely bypassing dependencies on Knative and Istio.

## Project Overview
The project consists of two main components:
1.  **Manual Deployment Guide**: A step-by-step manual process for installing KServe resources.
2.  **KServe Raw Operator**: A custom, Helm-based operator scaffolded with `operator-sdk` that automates the installation and management of KServe in Raw mode.

## 🚀 Key Features
- **Zero Knative/Istio Dependency**: Serve models using standard Kubernetes `Deployments` and `Services`.
- **OLM Based**: Managed via Operator Lifecycle Manager (OLM).
- **Automated Configuration**: Enforces `RawDeployment` mode via operator-level overrides.
- **Scikit-Learn Verified**: Includes a sample Iris model for verification.

## 📋 Prerequisites
- **Kubernetes Cluster** (e.g., Docker Desktop, Minikube, or GKE/EKS)
- **OLM**: Installed in the `olm` namespace.
- **Cert-Manager**: Installed for internal webhook certificate management.

## 🛠 Installation

### 1. Install Dependencies
```bash
# Install OLM
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/crds.yaml
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/olm.yaml

# Install Cert-Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
```

### 2. Deploy the Operator
The operator is published to Docker Hub as `akashneha/kserve-raw-operator:v0.1.0`.

To deploy it:
```bash
cd kserve-raw-operator
make deploy
```

### 3. Deploy KServe
Create a `KServeRaw` resource to trigger the operator:
```yaml
apiVersion: serving.kserve.io/v1alpha1
kind: KServeRaw
metadata:
  name: kserve-raw
  namespace: kserve
spec: {}
```

## ✅ Verification
Deploy the sample Iris model to verify Raw mode:
```bash
kubectl apply -f kserve-raw-operator/config/samples/iris-isvc.yaml
```
Verify that it creates a standard Kubernetes Deployment:
```bash
kubectl get deployments -n kserve
# You should see: sklearn-iris-predictor
```

## 📂 Project Structure
- `kserve-raw-operator/`: The main operator project for standard environments.
- `kserve-raw-operator-ag/`: **Developer Air-Gapped Bundle**. Contains local build tools (Go, Kustomize, Operator-SDK) and a mirroring script for transitioning to an offline registry.
- `kserve-raw-operator-ag-customer/`: **Customer Final Package**. A zero-build bundle with pre-rendered manifests, complete container image tars, and image loading scripts.
- `manual-deployment/`: Manual Helm charts and manifests for debugging.
- `docs/`: Specialized guides (Air-Gap, Setup, and Walkthroughs).

## 🏙️ Air-Gapped Deployment
The repository supports full offline installation for high-security environments:
- **Developer Flow**: Use `kserve-raw-operator-ag` if you need to build/modify the operator offline using the included local Go toolchain.
- **Customer Flow**: Ship the `kserve-raw-operator-bundle-customer.zip` (generated from `kserve-raw-operator-ag-customer`) for pre-rendered, single-command installation.

Refer to **[Air-Gap-Setup-Guide.md](kserve-raw-operator-ag/Air-Gap-Setup-Guide.md)** or **[Customer-Deployment-Guide.md](kserve-raw-operator-ag-customer/Customer-Deployment-Guide.md)** for details.

## ⚠️ Troubleshooting
### OLM SchemaError
On some clusters, OLM's `packageserver` may cause an OpenAPI validation error. If the operator fails to reconcile with a `SchemaError`, scale down the `packageserver`:
```bash
kubectl scale deployment -n olm packageserver --replicas=0
```
Detailed mitigation steps are in [operator-setup-guide.md](kserve-raw-operator/docs/operator-setup-guide.md).

---
**Maintained by**: akashneha
