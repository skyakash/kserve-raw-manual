# KServe Raw Operator: Customer Deployment Guide

This package contains everything needed to deploy the KServe Raw Operator in your air-gapped environment.

## 📦 Package Contents
- `dependencies/`: Kubernetes manifests for OLM and Cert-Manager.
- `manifests/`: Pre-rendered KServe Operator installation file.
- `samples/`: Sample validation model (Iris).
- `scripts/`: Tools for managing Docker images.

## 🚀 Installation Steps

### Step 1: Load and Push Container Images
Before installing the Kubernetes components, you must load the required container images into your local registry.
1.  On a machine with Docker and the provided `tars/` directory, run:
    ```bash
    cd scripts
    chmod +x load_images.sh
    ./load_images.sh <YOUR_PRIVATE_REGISTRY>
    ```

### Step 2: Install Base Dependencies
```bash
# Install OLM
kubectl apply -f dependencies/olm-crds.yaml
kubectl apply -f dependencies/olm-core.yaml

# Install Cert-Manager
kubectl apply -f dependencies/cert-manager.yaml
```

### Step 3: Install KServe Operator
Apply the pre-rendered manifest. 
> [!NOTE]
> If your registry requires authentication, ensure the relevant ImagePullSecrets are configured.

```bash
kubectl apply -f manifests/operator-install.yaml
```

### Step 4: Verification
Deploy the sample model to verify standard Kubernetes scaling is working (Raw mode):
```bash
kubectl apply -f samples/iris-isvc.yaml
```
Check the deployment:
```bash
kubectl get deployments -n kserve
```

## 🛠 Support
If you encounter a `SchemaError` during the initial reconciliation, run:
```bash
kubectl scale deployment -n olm packageserver --replicas=0
```
This will resolve any OpenAPI validation conflicts with the OLM packageserver.
