#!/bin/sh
exec litellm --config /app/config.yaml --host "${HOST:-0.0.0.0}" --port "${PORT:-4000}" "$@"
