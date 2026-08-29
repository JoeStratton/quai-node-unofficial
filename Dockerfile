FROM golang:1.27rc2-bookworm AS builder

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends git make g++ ca-certificates binutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY go.mod go.sum ./

RUN GO_QUAI_VERSION="$(awk '$1 == "require" && $2 == "github.com/dominant-strategies/go-quai" { print $3; exit }' go.mod)" \
    && git clone --depth 1 --branch "${GO_QUAI_VERSION}" \
         https://github.com/dominant-strategies/go-quai.git src

WORKDIR /build/src

RUN make go-quai \
    && strip --strip-unneeded build/bin/go-quai

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="quai-node-unofficial" \
      org.opencontainers.image.description="Unofficial go-quai node image with optional built-in Stratum solo mining support" \
      org.opencontainers.image.documentation="https://docs.qu.ai/guides/client/node" \
      org.opencontainers.image.url="https://docs.qu.ai/guides/client/solo-mining"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 65532 quai \
    && useradd --uid 65532 --gid quai --no-log-init --create-home --home-dir /home/quai --shell /usr/sbin/nologin quai \
    && mkdir -p /home/quai/.local/share/go-quai /home/quai/.config/go-quai \
    && chown -R quai:quai /home/quai

WORKDIR /app

COPY --from=builder /build/src/build/bin/go-quai /usr/local/bin/go-quai
COPY --from=builder /build/src/VERSION /app/VERSION
COPY --from=builder /build/src/params /app/params

RUN chown quai:quai /usr/local/bin/go-quai \
    && chown -R quai:quai /app

USER 65532

EXPOSE 4001/tcp 3333/tcp 3334/tcp 3335/tcp 3336/tcp

ENTRYPOINT ["go-quai"]
CMD ["start"]
