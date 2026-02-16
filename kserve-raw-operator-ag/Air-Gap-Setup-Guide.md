# KServe Raw Operator: Air-Gapped Setup Guide

This guide describes how to install the KServe Raw Operator in an environment without internet access. This bundle is self-contained and includes all manifests, tools, and scripts needed for offline deployment.

## 📦 Bundle Contents
- `bin/`: Pre-downloaded binaries for `kustomize`, `operator-sdk`, `helm-operator`, and `opm`.
- `dependencies/`: Local Kubernetes manifests for OLM and Cert-Manager.
- `.tools/`: Local Go toolchain for building the operator.
- `mirror_images.sh`: Script to help you migrate Docker images to your private registry.
- `image_list.txt`: A list of all Docker images required for a full KServe Raw deployment.

## 🚀 Setup Instructions

### Step 1: Mirror Docker Images (On a machine WITH internet)
You must first pull the required images and push them to your internal private registry.
1.  Copy `image_list.txt` and `mirror_images.sh` to a machine with internet and Docker access.
2.  Run the mirroring script:
    ```bash
    chmod +x mirror_images.sh
    ./mirror_images.sh <YOUR_PRIVATE_REGISTRY>
    # Example: ./mirror_images.sh registry.local:5000
    ```

### Step 2: Install Dependencies (In Air-Gapped environment)
Install OLM and Cert-Manager using the local manifests:
```bash
# Install OLM
kubectl apply -f dependencies/olm-crds.yaml
kubectl apply -f dependencies/olm-core.yaml

# Install Cert-Manager
kubectl apply -f dependencies/cert-manager.yaml
```

### Step 3: Deploy the Operator
The operator is configured to use your private registry. Update the `IMG` variable in the `Makefile` or pass it during deployment:

```bash
cd kserve-raw-operator-ag
make deploy IMG=<YOUR_PRIVATE_REGISTRY>/kserve-raw-operator:v0.1.0
```

### Step 4: Deploy KServe
The operator will deploy KServe using the images you mirrored in Step 1. Since KServe uses many images (agent, router, storage-initializer, etc.), you should update the operator's default configuration or use and modify the `KServeRaw` specification if needed to override image registries (the operator is pre-configured to point to standard names, so provided your private registry uses the same paths like `/kserve/agent`, it will work).

## 🛠 Troubleshooting
### Binaries & Architecture
The binaries in `bin/` were downloaded for **darwin/arm64**. If your air-gapped environment uses a different architecture (e.g., **linux/amd64**), you must replace the binaries in `bin/` with the correct versions before transferring the bundle.

### OLM SchemaError
If you encounter a `SchemaError` during reconciliation, scale down the OLM packageserver as described in the main guide:
```bash
kubectl scale deployment -n olm packageserver --replicas=0
```
