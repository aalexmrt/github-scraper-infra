# Cloud Run Configuration Templates

This directory contains Cloud Run configuration templates used for deployment.

## Files

- `cloudrun.yaml.template` - API service template
- `cloudrun-job.yaml.template` - Worker job template

## Usage

Templates use environment variable substitution via `envsubst`. Variables are set by the deploy script:

- `${PROJECT_ID}` - GCP Project ID
- `${REGION}` - GCP Region (e.g., `us-east1`)
- `${REPOSITORY}` - Artifact Registry repository name (`github-scraper`)
- `${SERVICE}` - Service name (`api`, `commit-worker`, `user-worker`)
- `${VERSION}` - Image version (e.g., `1.2.3`)
- `${IMAGE_TAG}` - Same as `${VERSION}` (for template compatibility)
- `${IMAGE_NAME}` - Service name for job templates
- `${JOB_NAME}` - Job name (for job templates)

## Deployment

Templates are processed by `scripts/deploy/deploy.sh`:

```bash
# For API service
envsubst < cloudrun/cloudrun.yaml.template > cloudrun.yaml
gcloud run services replace cloudrun.yaml

# For worker jobs
envsubst < cloudrun/cloudrun-job.yaml.template > cloudrun-job-${SERVICE}.yaml
gcloud run jobs replace cloudrun-job-${SERVICE}.yaml
```

## Generated Files

Generated YAML files (`cloudrun.yaml`, `cloudrun-job-*.yaml`) are created during deployment and should NOT be committed to git (they're in `.gitignore`).

