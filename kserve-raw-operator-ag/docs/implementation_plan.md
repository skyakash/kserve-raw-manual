# Custom KServe Raw Deployment Operator Plan

This plan outlines the creation of a custom Helm-based operator to manage KServe in "Raw Deployment" mode.

## User Review Required

> [!IMPORTANT]
> This operator will wrap the KServe Helm charts. It will be initialized in the `kserve-raw-operator` directory.
#- [x] Configure Helm charts and overrides <!-- id: 24 -->
- [x] Debug and Fix reconcile issues (OLM SchemaError) <!-- id: 27 -->
- [x] Create CRD and Sample CR <!-- id: 25 -->
- [x] Verify deployment with Sample ISVC <!-- id: 18 -->
- [x] Build Operator Image Locally <!-- id: 26 -->
- [/] Publish Operator Image to Docker Hub <!-- id: 28 -->
- [x] Create Operator Guide in `kserve-raw-operator` <!-- id: 19 -->
- [x] Organize files in `kserve-raw-operator` <!-- id: 20 -->
> We will need to decide if this operator should also manage Cert-Manager or if we keep Cert-Manager as a pre-requisite step. My recommendation is to keep Cert-Manager as a dependency that the operator guide instructs to install first, as operators typically manage their own functional area.

## Proposed Changes

### Operator Publication [NEW]
- Tag the local `kserve-raw-operator:latest` image for Docker Hub.
- Push the image to the user's Docker Hub account.
- Update `config/manager/manager.yaml` and patches to use the Docker Hub image instead of the local one.

### [Operator Development]

#### [NEW] [Operator Scaffold](file:///Users/akashdeo/kserve-raw-manual/kserve-raw-operator/)
Initialize the operator using `operator-sdk init --plugins helm`.

#### [MODIFY] [watches.yaml](file:///Users/akashdeo/kserve-raw-manual/kserve-raw-operator/watches.yaml)
Configure the operator to watch the `KServeRaw` CRD and apply the Helm chart with specific `RawDeployment` overrides.

#### [NEW] [Sample CR](file:///Users/akashdeo/kserve-raw-manual/kserve-raw-operator/config/samples/serving_v1alpha1_kserveraw.yaml)
Create a sample Custom Resource to trigger the deployment.

### [Documentation]

#### [NEW] [operator_development_guide.md](file:///Users/akashdeo/kserve-raw-manual/kserve-raw-operator/operator_development_guide.md)
Document how to build, deploy, and use this custom operator.

## Verification Plan

### Automated Tests
- Build and deploy the operator to the cluster.
- Apply the `KServeRaw` CR.
- Verify KServe controller and resources are created in raw mode.

### Manual Verification
- Verify `kubectl get isvc` works with the operator-managed installation.
