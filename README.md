# quai-node-unofficial

Unofficial Docker image for running a [go-quai](https://github.com/dominant-strategies/go-quai) full node.

**Image:** `j123ss/quai-node-unofficial` on Docker Hub

## Pull an image

```bash
# Latest main build
docker pull j123ss/quai-node-unofficial:latest

# Pin to a go-quai version (updates when that version is rebuilt on main)
docker pull j123ss/quai-node-unofficial:v0.55.0

# Pin to an exact build
docker pull j123ss/quai-node-unofficial:v0.55.0-sha-86ab9d5
```

The go-quai version is set in `go.mod`. Dependabot opens PRs when a new upstream release is available.

## Tags

Every successful publish to `main` pushes these Docker Hub tags:

| Tag | Purpose |
|-----|---------|
| `latest`, `main` | Most recent `main` build |
| `vX.Y.Z` | go-quai version from `go.mod` (rolling for that version) |
| `vX.Y.Z-sha-<commit>` | Immutable — pin a specific build |
| `sha-<commit>` | Immutable — short git commit |

## GitHub releases

When go-quai is upgraded in `go.mod`, the first successful publish creates a GitHub release named `vX.Y.Z` (for example `v0.55.0`). Release notes only say that go-quai was upgraded.

## Upstream docs

- [Run a node](https://docs.qu.ai/guides/client/node)
- [Solo mining (StratumX)](https://docs.qu.ai/guides/client/solo-mining)

## CI/CD

| Workflow | When | What it does |
|----------|------|--------------|
| `ci.yml` | Pull requests | Lint, secret scan, build image, Trivy + Dockle scan |
| `publish.yml` | Push to `main` or `v*` tags | Same checks, then build and push multi-arch image (`linux/amd64`, `linux/arm64`) with SBOM and provenance |

### Required GitHub settings

**Secrets:** `DOCKERHUB_TOKEN`

**Variables:** `DOCKERHUB_USERNAME`

## Solo mining

Built-in Stratum endpoints (do not mine until the node is fully synced):

```bash
go-quai start \
  --node.stratum-enabled \
  --node.stratum-sha-addr "0.0.0.0:3333" \
  --node.stratum-scrypt-addr "0.0.0.0:3334" \
  --node.stratum-kawpow-addr "0.0.0.0:3335" \
  --node.stratum-api-addr "0.0.0.0:3336" \
  --node.stratum-name "my-node"
```
