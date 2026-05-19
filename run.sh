#!/bin/sh
exec litellm --config /app/config.yaml --host "${HOST:-0.0.0.0}" --port "${_BYTEFAAS_RUNTIME_PORT:-${PORT:-4000}}" "$@"
