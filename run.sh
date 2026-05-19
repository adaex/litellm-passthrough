#!/bin/sh
exec litellm --config /app/config.yaml --host "${HOST:-::}" --port "${_BYTEFAAS_RUNTIME_PORT:-${PORT:-4000}}" "$@"
