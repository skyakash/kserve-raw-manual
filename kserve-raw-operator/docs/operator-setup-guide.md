# KServe Raw Operator Setup Guide

This document provides a step-by-step technical explanation of how the KServe Raw Operator was scaffolded, configured, and deployed to bypass Knative and Istio dependencies.

## Overview
The goal of this project is to provide a "one-click" OLM (Operator Lifecycle Manager) based installation for KServe in **Raw Deployment** mode. This allows model serving on vanilla Kubernetes without the complexity of Knative or Istio.

## Step 1: Cluster Preparation
Before installing the operator, we prepared the cluster with essential dependencies:
- **OLM Installation**: Installed the Operator Lifecycle Manager to handle operator packaging and lifecycles.
- **Cert-Manager**: Installed `cert-manager` (v1.17.0) to manage internal webhooks and certificate injection for KServe.

## Step 2: Operator Scaffolding
We used the `operator-sdk` to bootstrap a **Helm-based operator**.
- **Command**: `operator-sdk init --plugins=helm --domain=kserve.io --group=serving --version=v1alpha1 --kind=KServeRaw`
- **Purpose**: This creates an operator that "watches" a custom resource (`KServeRaw`) and uses a Helm chart to deploy the corresponding KServe components.

## Step 3: Configuring Raw Deployment Mode
To ensure KServe runs in Raw mode, we injected specific overrides into the operator's logic:
- **File**: `watches.yaml`
- **Overrides**:
  - `kserve.controller.deploymentMode: RawDeployment`: Disables Knative.
  - `kserve.controller.gateway.disableIstioVirtualHost: true`: Disables Istio dependencies.
- **Validation Bypass**: Set `disableValidation: true` in `watches.yaml` to prevent OLM's internal OpenAPI validator from conflicting with Helm's manifests.

## Step 4: Resolving OLM Schema Conflicts
A major blocker encountered was the `SchemaError` related to OLM's `PackageManifest`.
- **Symptom**: The operator failed to reconcile because OLM's `packageserver` served an inconsistent OpenAPI schema that crashed the Helm discovery client.
- **Solution**: 
  - Scaled the `packageserver` in the `olm` namespace to 0.
  - Manually applied KServe CRDs from the project's codebase to ensure the API server recognized the resource types.
  - This allowed the operator to "see" the cluster state clearly and complete the installation.

## Step 5: Port Conflict Resolution
The local environment had several ports in use (8080, 8081). We reconfigured the operator to use safer defaults:
- **Metrics Port**: `8086`
- **Health Probe Port**: `8087`

## Step 6: Verification
Once the operator reconciled, we verified the installation:
- **KServe Controller**: Checked that `kserve-controller-manager` is running.
- **Sample Model**: Deployed an `InferenceService` (Iris) and confirmed it created a standard Kubernetes **Deployment** (`sklearn-iris-predictor`), proving Raw mode is active.
- **Inference Test**: Successfully performed a prediction test:
  ```bash
  # Forward port to service
  kubectl port-forward -n kserve svc/sklearn-iris-predictor 8088:80
  
  # Send prediction request
  curl -H "Host: sklearn-iris-kserve.example.com" \
       -H "Content-Type: application/json" \
       http://localhost:8088/v1/models/sklearn-iris:predict \
       -d @iris-input.json
       
  # Result: {"predictions":[1,1]}
  ```

## Step 7: Publishing to Docker Hub
To enable distribution, we published the operator image to Docker Hub.
- **Repository**: `akashneha/kserve-raw-operator:v0.1.0`
- **Commands**:
  ```bash
  docker login -u akashneha
  docker tag kserve-raw-operator:latest akashneha/kserve-raw-operator:v0.1.0
  docker push akashneha/kserve-raw-operator:v0.1.0
  ```
- **Updates**: Modified `config/manager/manager.yaml` and `Makefile` to point to the remote image and set `imagePullPolicy: Always`.

## Running the Operator Locally
To run the operator in your current environment:
```bash
export PATH=$PATH:$(pwd)/../.tools/go/bin
make run
```

## Next Steps
- **Docker Image Build**: Build the operator into a container image.
- **OLM Bundle Creation**: Package the operator for distribution via OLM catalogs.
