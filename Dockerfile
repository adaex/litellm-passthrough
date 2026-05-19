FROM litellm/litellm:main-stable

COPY config.yaml /app/config.yaml
COPY hooks.py /app/hooks.py

ENV LITELLM_MASTER_KEY=sk-litellm-passthrough
ENV LITELLM_LOCAL_MODEL_COST_MAP=true

CMD ["--config", "/app/config.yaml", "--host", "0.0.0.0", "--port", "4000"]
