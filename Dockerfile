FROM oven/bun:1-debian

WORKDIR /app

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=8787 \
    ZEN_PROXY_CONFIG=/data/zen-proxy.json

RUN mkdir -p /data && chown bun:bun /data

COPY zen-proxy.mjs models.json agent-preamble.txt agent-tools.json LICENSE ./
COPY public/ ./public/
COPY assets/favicon.png assets/logo-128.png ./assets/

USER bun

VOLUME ["/data"]
EXPOSE 8787

# The health endpoint checks the local process without consuming upstream quota.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["bun", "-e", "const res = await fetch('http://127.0.0.1:' + (process.env.PORT || '8787') + '/health', { method: 'HEAD', signal: AbortSignal.timeout(4000) }); process.exit(res.ok ? 0 : 1)"]

ENTRYPOINT ["bun"]
CMD ["zen-proxy.mjs"]
