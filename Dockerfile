FROM golang:1.26.2-bookworm AS builder

ARG GO_QUAI_VERSION=v0.52.0

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends git make g++ ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone https://github.com/dominant-strategies/go-quai.git . \
    && git checkout "${GO_QUAI_VERSION}" \
    && make go-quai

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="quai-node-unofficial" \
      org.opencontainers.image.description="Unofficial go-quai node image with optional built-in Stratum solo mining support" \
      org.opencontainers.image.documentation="https://docs.qu.ai/guides/client/node" \
      org.opencontainers.image.url="https://docs.qu.ai/guides/client/solo-mining"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mkdir -p /root/.local/share/go-quai /root/.config/go-quai

COPY --from=builder /src/build/bin/go-quai /usr/local/bin/go-quai
COPY --from=builder /src/VERSION /app/VERSION
COPY --from=builder /src/params /app/params

EXPOSE 4001/tcp 3333/tcp 3334/tcp 3335/tcp 3336/tcp

ENTRYPOINT ["go-quai"]
CMD ["start"]
