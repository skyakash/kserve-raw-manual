# Project Setup Log

This document tracks the setup and configuration steps performed for the KServe project.

## 1. Prerequisites Check
We started by verifying the presence of necessary tools in the environment.

### Tools Checked:
- **Git**: Installed (Version 2.50.1)
- **Docker**: Installed (Version 29.2.0)
- **Go**: Present in `.tools`
- **Operator SDK**: Present in `.tools`
- **GitHub CLI (gh)**: Was missing initially.

## 2. Tool Installation
Since `gh` (GitHub CLI) was missing, we installed it using Homebrew.

```bash
brew install gh
```
- **Status**: Installed successfully (Version 2.86.0).

## 3. Authentication

### GitHub Login
Authentication was performed using the GitHub CLI web flow.
```bash
gh auth login --hostname github.com --git-protocol https --web
```
- **User**: `skyakash`
- **Status**: Logged in successfully.

### Docker Hub Login
Authentication was performed using a Personal Access Token (PAT).
```bash
echo "dckr_pat_..." | docker login -u akashneha --password-stdin
```
- **User**: `akashneha`
- **Status**: Logged in successfully.

## Next Steps
- Push project code to the GitHub repository.
- Push Docker images to Docker Hub.
