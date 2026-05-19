#!/bin/sh
exec litellm --config /app/config.yaml --host "${HOST:-::}" --port "${PORT:-4000}" "$@"
