# quai-node-unofficial

Unofficial Docker image for running a `go-quai` full node.

## Upstream docs used

- Node config/build reference: [Run A Node](https://docs.qu.ai/guides/client/node)
- Stratum solo mining flags/ports: [Solo Mining (StratumX)](https://docs.qu.ai/guides/client/solo-mining)

## CI/CD workflows

- `ci.yml`: runs on pull requests (and manually) and performs:
  - Dockerfile lint (`hadolint`)
  - secret scan (`gitleaks`)
  - Trivy filesystem vulnerability scan
  - image build + Trivy image scan (blocking for OS packages only)
- `publish.yml`: runs on push to `main` and version tags (`v*`) and:
  - runs `lint-and-security` first
  - runs one gated `push-image` job after lint/scan passes (single build+push path)
  - builds and pushes multi-arch image (`linux/amd64`, `linux/arm64`) to Docker Hub
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

Every successful publish to `main` pushes **multiple tags**; Docker Hub keeps all of them (older tags are not removed):

| Tag | Purpose |
|-----|---------|
| `latest` | Most recent `main` build (moves forward) |
| `main` | Same as `latest` for branch pulls |
| `vX.Y.Z` | go-quai version from `go.mod` (e.g. `v0.55.0`; updates if that version is rebuilt) |
| `vX.Y.Z-sha-<commit>` | **Immutable** — one tag per commit, safe to pin long-term |
| `sha-<commit>` | **Immutable** — short git SHA |
| `<git-tag>` | When you push a repo `v*` git tag |

**Pin a specific build:** use `v0.55.0-sha-86ab9d5` or `sha-86ab9d5`.

**Pin a go-quai release line:** use `v0.55.0` (tracks the newest image built for that upstream version).

Example:

```text
j123ss/quai-node-unofficial:v0.55.0-sha-86ab9d5
j123ss/quai-node-unofficial:sha-86ab9d5
```

`v0.51.1` on [GitHub Tags](https://github.com/JoeStratton/quai-node-unofficial/tags) is from an older manual release; new version tags are created automatically when go-quai is upgraded in `go.mod`.

## GitHub releases and tags

When go-quai is upgraded in `go.mod`, the first successful publish to `main` creates a GitHub tag and release named after the go-quai version (for example `v0.55.0`). The release notes only state that go-quai was upgraded — not pipeline or repo commit history.

| GitHub tag / release | Docker tag | Purpose |
|--------------------|------------|---------|
| `vX.Y.Z` | `vX.Y.Z` | Created once per go-quai version in `go.mod` |

Pushing a repo `v*` git tag still triggers publish and creates a matching GitHub release if one does not exist.

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

