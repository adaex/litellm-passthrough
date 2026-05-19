ARG LITELLM_VERSION=main-stable
FROM litellm/litellm:${LITELLM_VERSION}

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py
COPY run.sh /app/run.sh

ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true

ENTRYPOINT ["/app/run.sh"]
