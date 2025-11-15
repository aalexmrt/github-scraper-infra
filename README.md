# GitHub Scraper Infrastructure

> **Note**: This repository handles **deployment only**. Images are built and published
> in the [main repository](https://github.com/YOUR_USERNAME/github-scraper) via GitHub Actions.

[![Deploy](https://github.com/YOUR_USERNAME/github-scraper-infra/workflows/Deploy/badge.svg)](https://github.com/YOUR_USERNAME/github-scraper-infra/actions)

## Workflow

1. Tag created in main repo → Images built and pushed to registry
2. Infra repo deploys → References published images from registry

## Quick Start

# Deploy a service
./scripts/deploy/deploy.sh api 1.0.0## Documentation

See `docs/` directory for detailed deployment guides.
