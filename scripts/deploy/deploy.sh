#!/bin/bash
set -e

# Service and version come from arguments
SERVICE=$1  # e.g., "api", "commit-worker", "user-worker"
VERSION=$2  # e.g., "1.2.3"

if [ -z "$SERVICE" ] || [ -z "$VERSION" ]; then
  echo "❌ Error: Service and version required"
  echo "Usage: ./deploy.sh <service> <version>"
  echo "Example: ./deploy.sh api 1.2.3"
  echo "Example: ./deploy.sh commit-worker 1.2.3"
  echo ""
  echo "Valid services: api, commit-worker, user-worker"
  exit 1
fi

# Validate service name
VALID_SERVICES=("api" "commit-worker" "user-worker")
if [[ ! " ${VALID_SERVICES[@]} " =~ " ${SERVICE} " ]]; then
  echo "❌ Error: Invalid service name: ${SERVICE}"
  echo "Valid services: ${VALID_SERVICES[*]}"
  exit 1
fi

# Validate version format (semantic versioning)
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  echo "❌ Error: Invalid version format. Use semantic versioning: 1.2.3"
  exit 1
fi

PROJECT_ID="${PROJECT_ID:-YOUR_GCP_PROJECT_ID}"
REGION="${REGION:-us-east1}"
REPOSITORY="${REPOSITORY:-github-scraper}"

# Validate that PROJECT_ID is set to a real value (not placeholder)
if [ "$PROJECT_ID" = "YOUR_GCP_PROJECT_ID" ]; then
  echo "❌ Error: PROJECT_ID is not set!"
  echo "   Please set it as an environment variable:"
  echo "   export PROJECT_ID=\"your-actual-project-id\""
  echo "   Or run: PROJECT_ID=\"your-actual-project-id\" ./deploy.sh ${SERVICE} ${VERSION}"
  exit 1
fi

# Verify image exists in registry before deploying
echo "🔍 Verifying image exists in registry..."
if ! gcloud artifacts docker images describe \
  ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${SERVICE}:${VERSION} \
  --project=${PROJECT_ID} &>/dev/null; then
  echo "❌ Error: Image ${SERVICE}:${VERSION} not found in registry"
  echo "   Build it first in github-scraper repo:"
  echo "   git tag ${SERVICE}-v${VERSION} && git push origin ${SERVICE}-v${VERSION}"
  exit 1
fi
echo "✅ Found ${SERVICE}:${VERSION}"

# Deploy specific service using published image
export PROJECT_ID REGION REPOSITORY SERVICE VERSION
export IMAGE_TAG=${VERSION}  # Templates use IMAGE_TAG variable
export IMAGE_NAME=${SERVICE}  # For job templates
export JOB_NAME=${SERVICE}  # For job templates

# Deploy based on service type
case $SERVICE in
  api)
    echo "🚀 Deploying API service..."
    envsubst < cloudrun/cloudrun.yaml.template > cloudrun.yaml
    gcloud run services replace cloudrun.yaml --project=${PROJECT_ID} --region=${REGION}

    # Health check for API service
    echo "🔍 Waiting for service to be ready..."
    sleep 15  # Wait for Cloud Run to update

    # Get service URL
    SERVICE_URL=$(gcloud run services describe api \
      --project=${PROJECT_ID} \
      --region=${REGION} \
      --format='value(status.url)')

    echo "🔍 Running health check on ${SERVICE_URL}/health..."
    if curl -f -s "${SERVICE_URL}/health" > /dev/null; then
      echo "✅ Health check passed - Service is responding"
    else
      echo "⚠️  Warning: Health check failed - Service may not be ready yet"
      echo "   Check logs: gcloud logging read 'resource.type=cloud_run_revision AND resource.labels.service_name=api' --limit=50 --project=${PROJECT_ID}"
      # Don't fail deployment - service might need more time to start
      # Manual verification recommended
    fi
    ;;
  commit-worker|user-worker)
    echo "🚀 Deploying ${SERVICE} job..."
    # JOB_NAME and IMAGE_NAME already exported above
    envsubst < cloudrun/cloudrun-job.yaml.template > cloudrun-job-${SERVICE}.yaml
    gcloud run jobs replace cloudrun-job-${SERVICE}.yaml --project=${PROJECT_ID} --region=${REGION}
    echo "✅ Job configuration updated - Will run on next scheduled execution"
    ;;
esac

echo "✅ Deployed ${SERVICE}:${VERSION}"
