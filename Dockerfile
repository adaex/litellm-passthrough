FROM python:3.13-slim

ARG LITELLM_VERSION=1.85.0

# uv installs ~10x faster than pip and avoids pip's dependency-resolver memory blowups.
# We install only `litellm[proxy]` — NOT `litellm[extra-proxy]` — so prisma is not pulled in.
# Skipping prisma alone saves ~10s of startup (prisma.types is a huge generated types module).
RUN pip install --no-cache-dir uv && \
    uv pip install --system --no-cache "litellm[proxy]==${LITELLM_VERSION}"

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true
ENV LITELLM_MODE=PRODUCTION
ENV LITELLM_LOG=WARNING
ENV DISABLE_SCHEMA_UPDATE=true
ENV NO_DOCS=True
ENV NO_REDOC=True
ENV NO_OPENAPI=True
ENV DISABLE_ADMIN_UI=True

# Pre-compile bytecode at build time so first import doesn't pay the .py → .pyc cost.
RUN python -m compileall -q -j 0 /usr/local/lib/python3.13/site-packages /app 2>/dev/null || true

WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
