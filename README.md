# n8n v2.8.3 Render Blueprint

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

This repository provides a Render Blueprint (`render.yaml`) to deploy the official n8n v2.8.3 Docker image (`docker.io/n8nio/n8n:2.8.3`) to Render with a persistent disk.

The service is blueprint-only. It does not build or publish a custom Docker image.

## One-Click Installation

1. Deploy this repository as a Render Blueprint.
2. Use a paid instance plan that supports persistent disks.
3. Set `WEBHOOK_URL` and `N8N_EDITOR_BASE_URL` to the public Render service URL.
4. Set `N8N_ENCRYPTION_KEY` once and keep it stable across redeploys.
5. Deploy the service and confirm `/healthz` is healthy.

## Repository Contents

- `render.yaml`: Render Blueprint configuration for the official n8n image, environment variables, health check, and persistent disk.
- `MANUAL_DEPLOY.md`: Optional manual deployment notes if this file exists in your branch.

## Configuration

The Blueprint configures:

- `runtime: image` with `docker.io/n8nio/n8n:2.8.3`
- `N8N_PORT=5678`
- SQLite persistence at `/home/node/.n8n/database.sqlite`
- Disk persistence at `/home/node/.n8n`
- Bangkok timezone defaults

## Production hardening

- Uses Render's prebuilt-image Blueprint syntax with `runtime: image` and the official `docker.io/n8nio/n8n:2.8.3` image.
- Prompts for `WEBHOOK_URL` and `N8N_EDITOR_BASE_URL` during Blueprint setup so deploy URLs are not hard-coded in git.
- Keeps `N8N_ENCRYPTION_KEY` outside git so encrypted credentials survive redeploys when the same value is reused.
- Keeps execution data smaller by saving errors, pruning old executions, and avoiding successful/manual execution data by default.
- Emits JSON logs to stdout for cleaner Render log search and external log shipping.
- Attaches a persistent disk at `/home/node/.n8n`; increase it before it fills because Render disks can be expanded but not reduced.
