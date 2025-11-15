# GitHub Scraper Infrastructure

[![Deploy](https://github.com/aalexmrt/github-scraper-infra/workflows/Deploy/badge.svg)](https://github.com/aalexmrt/github-scraper-infra/actions)

> **Note**: This repository handles **deployment only**. Images are built and published
> in the [main repository](https://github.com/aalexmrt/github-scraper) via GitHub Actions.

## 🎯 Overview

This repository contains all deployment configurations, scripts, and documentation for the GitHub Scraper application. It follows industry best practices by separating CI (build) from CD (deploy).

**Key Principles**:
- ✅ **Build in main repo**: Dockerfiles and image building stay with source code
- ✅ **Deploy in infra repo**: Deployment configs and scripts reference published images
- ✅ **Published images**: Images built and stored in registry, deployed on-demand
- ✅ **Git tags**: Single source of truth for versions (tags in main repo)
- ✅ **Automated deployment**: Fully automated deployment from tag to production (with safety nets)

## 🔄 Workflow

1. **Tag created in main repo** → Images built and pushed to registry
2. **Infra repo deploys** → References published images from registry

### Complete Flow

```
Developer creates tag (api-v1.2.3)
    ↓
Main repo: Build workflow triggers
    ↓
Builds Docker image → Pushes to Artifact Registry
    ↓
Automatically triggers infra repo deployment
    ↓
Infra repo: Deploy workflow validates image exists
    ↓
Deploys to Cloud Run → Health checks run
    ↓
Service is live ✅
```

## 🚀 Quick Start

### Deploy a Service

```bash
# Deploy specific service and version
./scripts/deploy/deploy.sh api 1.2.3
./scripts/deploy/deploy.sh commit-worker 1.5.0
./scripts/deploy/deploy.sh user-worker 2.0.1
```

### Manual Deployment via GitHub UI

1. Go to Actions → "Deploy" workflow
2. Click "Run workflow"
3. Select service and enter version
4. Click "Run workflow"

### Automated Deployment

Deployment happens automatically when you create a tag in the main repository:

```bash
# In main repo
git tag api-v1.2.3
git push origin api-v1.2.3

# This automatically:
# 1. Builds image in main repo
# 2. Pushes to Artifact Registry
# 3. Triggers deployment in infra repo
# 4. Deploys to Cloud Run
```

## 📁 Repository Structure

```
github-scraper-infra/
├── .github/workflows/
│   └── deploy.yml                 # Deployment workflow
├── cloudrun/                      # Cloud Run configurations
│   ├── cloudrun.yaml.template     # API service template
│   ├── cloudrun-job.yaml.template # Worker job template
│   └── README.md                  # Template usage guide
├── scripts/                       # Deployment scripts
│   ├── deploy/                    # Deployment scripts
│   ├── debug/                     # Debug utilities
│   ├── secrets/                   # Secret management
│   └── utils/                     # Utility scripts
└── docs/                          # Deployment documentation
    ├── DEPLOYMENT.md              # Main deployment guide
    ├── DEPLOYMENT_PATTERNS.md     # Configuration patterns
    ├── DEPLOYMENT_QUICK_REFERENCE.md
    └── OAUTH_SETUP.md             # OAuth setup guide
```

## 📚 Documentation

- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Comprehensive deployment guide
- **[DEPLOYMENT_QUICK_REFERENCE.md](docs/DEPLOYMENT_QUICK_REFERENCE.md)** - Quick reference for common tasks
- **[DEPLOYMENT_PATTERNS.md](docs/DEPLOYMENT_PATTERNS.md)** - Configuration patterns and best practices
- **[OAUTH_SETUP.md](docs/OAUTH_SETUP.md)** - OAuth setup guide

## 🔧 Available Scripts

### Deployment

- `scripts/deploy/deploy.sh` - Main deployment script (deploys published images)
- `scripts/deploy/setup.sh` - GCP project setup
- `scripts/deploy/setup-cicd.sh` - CI/CD setup
- `scripts/deploy/setup-two-worker-schedulers.sh` - Cloud Scheduler setup

### Debugging

- `scripts/debug/check-scheduler-status.sh` - Check Cloud Scheduler status
- `scripts/debug/check-worker-job-status.sh` - Check worker job status
- `scripts/debug/debug-commit-worker.sh` - Debug commit worker
- `scripts/debug/debug-user-worker.sh` - Debug user worker
- `scripts/debug/view-prod-logs.sh` - View production logs

### Secrets Management

- `scripts/secrets/create-secrets.sh` - Create GCP secrets
- `scripts/secrets/set-oauth-secrets.sh` - Set OAuth secrets
- `scripts/secrets/set-vercel-env.sh` - Set Vercel environment variables

### Utilities

- `scripts/utils/cleanup-prod-jobs.sh` - Cleanup production jobs
- `scripts/utils/trigger-commit-worker.sh` - Manually trigger commit worker

## 🏷️ Version Management

Versions are managed via git tags in the main repository:

- **Tag format**: `<service>-v<version>` (e.g., `api-v1.2.3`)
- **Services**: `api`, `commit-worker`, `user-worker`
- **Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)

### Creating a Release

```bash
# In main repo
git tag api-v1.2.3
git push origin api-v1.2.3

# Deployment happens automatically
```

## 🔄 Rollback

Rollback is instant using published images:

```bash
# Deploy previous version
./scripts/deploy/deploy.sh api 1.2.2

# Or deploy any version that exists in registry
./scripts/deploy/deploy.sh api 1.0.0
```

## 🔐 Secrets

Secrets are managed via GCP Secret Manager and referenced in Cloud Run configurations. See `scripts/secrets/create-secrets.sh` for setup.

## 📝 CI/CD Best Practices

While we use shell scripts for deployment, we maintain GitHub Actions workflows for:
- ✅ Validation and testing
- ✅ Build status badges
- ✅ Automated deployments
- ✅ Audit trail

This demonstrates awareness that shell scripts alone aren't ideal, but are a conscious choice for our current needs.

## 🔗 Related Repositories

- **[Main Repository](https://github.com/aalexmrt/github-scraper)** - Application code and image building
