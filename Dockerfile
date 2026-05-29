FROM python:3.13-slim

ARG LITELLM_VERSION=1.86.2

# uv installs ~10x faster than pip and avoids pip's dependency-resolver memory blowups.
# litellm[proxy] >=1.86 no longer pulls in prisma — that alone is ~10s of startup
# and ~500MB of image we don't need (we run zero-state, no DB).
RUN pip install --no-cache-dir uv && \
    uv pip install --system --no-cache "litellm[proxy]==${LITELLM_VERSION}"

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true
ENV LITELLM_MODE=PRODUCTION
ENV LITELLM_LOG=WARNING
ENV NO_DOCS=true
ENV NO_REDOC=true
ENV NO_OPENAPI=true
ENV DISABLE_ADMIN_UI=true

# Pre-compile bytecode at build time so first import doesn't pay the .py → .pyc cost.
# Resolve site-packages via sysconfig so this stays correct across python/base-image bumps.
RUN SITE=$(python -c 'import sysconfig;print(sysconfig.get_paths()["purelib"])') && \
    python -m compileall -q -j 0 "$SITE" /app 2>/dev/null || true

WORKDIR /app
ENTRYPOINT ["/app/run.sh"]
