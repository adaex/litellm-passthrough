ARG LITELLM_VERSION=main-stable
FROM litellm/litellm:${LITELLM_VERSION}

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py
COPY custom_routes.py /app/custom_routes.py
COPY run.sh /app/run.sh

ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true
ENV LITELLM_MODE=PRODUCTION
ENV LITELLM_LOG=ERROR
ENV DISABLE_SCHEMA_UPDATE=true
ENV LITELLM_WORKER_STARTUP_HOOKS=custom_routes:register_routes

ENTRYPOINT ["/app/run.sh"]
