# KServe Raw Deployment: Comprehensive Manual Guide

This guide provides step-by-step instructions to manually deploy KServe in **Raw Deployment** mode on a local Kubernetes cluster, bypassing dependencies on Knative and Istio.

---

## 🛠️ 1. Prerequisites & Tool Setup

Ensure you have the following tools installed:

- **Kubernetes Cluster**: Kind or Minikube.
- **kubectl**: CLI for Kubernetes.
- **Helm**: Package manager for Kubernetes.

### Install GitHub CLI (gh)
If not installed, use Homebrew:
```bash
brew install gh
```

### Authentication
Login to GitHub and Docker Hub:
```bash
# GitHub Login (Follow browser prompts)
gh auth login

# Docker Hub Login
docker login -u <your-username>
```

---

## ⚙️ 2. Environment Preparation

Clone the KServe repository and set the required environment variables. These variables are crucial for the installation script to correctly identify local charts and skip Knative requirements.

```bash
# Set REPO_ROOT to your local kserve-master folder
export REPO_ROOT=$(pwd)/kserve-master
export USE_LOCAL_CHARTS=true
export DEPLOYMENT_MODE=RawDeployment
export LLMISVC=false
export KSERVE_NAMESPACE=kserve
export EMBED_MANIFESTS=false
export KSERVE_VERSION=v0.16.0
```

---

## 🧩 3. Critical Fix: Webhook Deadlock

KServe installation often fails during the initial Helm install because `ClusterServingRuntime` resources are created before the validation webhook is ready, leading to "connection refused" errors.

### Workaround Steps:
1. Open `kserve-master/charts/kserve-resources/templates/webhookconfiguration.yaml`.
2. Locate the `ValidatingWebhookConfiguration` named `clusterservingruntime.serving.kserve.io` (usually starts around line 137).
3. **Delete or comment out** this section entirely.
4. Save the file. 

*Note: You can restore this configuration after the initial installation is successful and the controller is running.*

---

## 🚀 4. Installation

Run the KServe Helm management script from the repository root:

```bash
cd kserve-master
./hack/setup/infra/manage.kserve-helm.sh
```

If the installation fails or you need a clean start:
```bash
REINSTALL=true ./hack/setup/infra/manage.kserve-helm.sh
```

---

## ✅ 5. Verification

### Check Pod Status
Ensure the KServe controller is running in the `kserve` namespace:
```bash
kubectl get pods -n kserve
```

### Verify Serving Runtimes
Confirm that the default runtimes are created:
```bash
kubectl get clusterservingruntimes
```

### Deploy a Sample (Raw Mode)
Deploy a sample `InferenceService` to verify that it creates standard Kubernetes resources instead of Knative Services.

**sklearn-iris.yaml**:
```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-iris
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
```

Apply and check:
```bash
kubectl apply -f sklearn-iris.yaml
kubectl get isvc sklearn-iris
```

**Verify standard K8s resources**:
```bash
kubectl get deployment sklearn-iris-predictor
kubectl get service sklearn-iris-predictor
```

---

## 🧪 6. Testing the InferenceService

Once the `InferenceService` is ready, you can test it by sending a prediction request.

### 1. Prepare Payload
Create a file named `iris-input.json`:
```json
{
  "instances": [
    [6.8, 2.8, 4.8, 1.4],
    [6.0, 3.4, 4.5, 1.6]
  ]
}
```

### 2. Port-Forward the Service
Since the service is a `ClusterIP`, use port-forwarding to access it locally:
```bash
kubectl port-forward svc/sklearn-iris-predictor 8080:80
```

### 3. Send Prediction Request
In a separate terminal, run:
```bash
curl -v -H "Content-Type: application/json" -d @iris-input.json http://localhost:8080/v1/models/sklearn-iris:predict
```

**Expected Output**:
```json
{"predictions":[1,1]}
```

---

## 🛠️ 7. Summary of Modifications

To enable a successful **Raw Deployment** and resolve installation deadlocks, the following modifications were made to the KServe Helm charts:

### Webhook Configuration Workflow
**File**: `charts/kserve-resources/templates/webhookconfiguration.yaml`

- **Issue**: A "chicken-and-egg" deadlock occurs because the Helm chart attempts to create `ClusterServingRuntime` resources during the same installation pass as the KServe Webhook Server. Since the webhook is not yet running/ready, the Kubernetes API server fails the creation of the runtimes when calling the validator.
- **Modification**: The `ValidatingWebhookConfiguration` section for `clusterservingruntime.serving.kserve.io` was removed.
- **Impact**: This allows the installation to proceed without blocked resource creation. The controller manager and webhook pod can then start successfully.

### Runtime Configuration
**File**: `charts/kserve-resources/values.yaml`

- **Modification**: The `version` or `tag` fields were updated (automagically by the script) to match the specified `KSERVE_VERSION` (e.g., `v0.16.0`).
- **Impact**: Ensures the correct image versions are pulled for the controller and associated services.

---

## 🔍 Troubleshooting

- **Connection Refused (Webhook)**: Ensure Step 3 was completed correctly. The webhook must be disabled for the first install.
- **Unbound Variable**: Ensure all variables in Step 2 are exported in your current shell session.
- **Namespace stuck in Terminating**: If `REINSTALL=true` hangs, manually force delete the namespace if necessary using:
  ```bash
  kubectl delete ns kserve --force --grace-period=0
  ```

