# quai-node-unofficial

Unofficial Docker image for running a `go-quai` full node.

## Upstream docs used

- Node config/build reference: [Run A Node](https://docs.qu.ai/guides/client/node)
- Stratum solo mining flags/ports: [Solo Mining (StratumX)](https://docs.qu.ai/guides/client/solo-mining)

## CI/CD workflows

- `ci.yml`: runs on push/PR and performs:
  - Dockerfile lint (`hadolint`)
  - secret scan (`gitleaks`)
  - Trivy filesystem vulnerability scan
  - image build + Trivy image scan
- `publish.yml`: runs on push to `main` and version tags (`v*`) and:
  - builds multi-arch image (`linux/amd64`, `linux/arm64`)
  - pushes to Docker Hub
  - generates SBOM + provenance attestation

## Required GitHub repository settings

Set these in GitHub repo `Settings -> Secrets and variables -> Actions`.

### Secrets

- `DOCKERHUB_TOKEN`: Docker Hub access token (recommended over password)

### Variables

- `DOCKERHUB_USERNAME`: your Docker Hub username

## One-time setup commands

Create and push repo:

```powershell
git init
git add .
git commit -m "Add Docker build, security scanning, and publish workflows"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USER/quai-node-unofficial.git
git push -u origin main
```

Create first release tag (triggers publish workflow):

```powershell
git tag v0.51.1
git push origin v0.51.1
```

## Docker Hub output tags

`publish.yml` pushes:

- `DOCKERHUB_USERNAME/quai-node-unofficial:main` (main branch)
- `DOCKERHUB_USERNAME/quai-node-unofficial:latest` (main branch)
- `DOCKERHUB_USERNAME/quai-node-unofficial:vX.Y.Z` (tagged releases)
- `DOCKERHUB_USERNAME/quai-node-unofficial:sha-<commit>`

## Runtime notes (solo mining)

If you want built-in Stratum endpoints for solo mining, start with:

```bash
go-quai start \
  --node.stratum-enabled \
  --node.stratum-sha-addr "0.0.0.0:3333" \
  --node.stratum-scrypt-addr "0.0.0.0:3334" \
  --node.stratum-kawpow-addr "0.0.0.0:3335" \
  --node.stratum-api-addr "0.0.0.0:3336" \
  --node.stratum-name "my-node"
```

Do not mine until the node is fully synced.

