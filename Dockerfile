ARG LITELLM_VERSION=main-stable
FROM litellm/litellm:${LITELLM_VERSION}

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py

ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true
ENV HOST=0.0.0.0
ENV PORT=4000

CMD ["sh", "-c", "exec litellm --config /app/config.yaml --host $HOST --port $PORT"]
