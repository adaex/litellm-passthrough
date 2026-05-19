# litellm-passthrough

A zero-state LLM gateway powered by [LiteLLM](https://github.com/BerriAI/litellm). One `docker run` command gives you a universal OpenAI-compatible proxy that stores **no credentials** — all upstream routing is passed per-request via HTTP headers.

## Quick Start

```bash
docker run -d --name litellm-passthrough \
  -p 4000:4000 \
  adaex/litellm-passthrough:latest
```

## Usage

Pass upstream information via headers on every request:

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-litellm-passthrough" \
  -H "X-Upstream-Url: https://api.openai.com/v1" \
  -H "X-Upstream-Authorization: Bearer sk-your-openai-key" \
  -H "X-Upstream-Model: gpt-4o" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Headers

| Header | Required | Description |
|--------|----------|-------------|
| `X-Upstream-Url` | Yes | Upstream OpenAI-compatible endpoint URL |
| `X-Upstream-Authorization` | Yes | Auth header for upstream (e.g. `Bearer sk-xxx`) |
| `X-Upstream-Model` | No | Override model name sent to upstream |
| `X-Upstream-Models` | No | Model mapping: `client=upstream,client2=upstream2` |

`X-Upstream-Models` takes priority over `X-Upstream-Model`. Format: comma-separated `clientModel=upstreamModel` pairs.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LITELLM_MASTER_KEY` | `sk-litellm-passthrough` | Proxy authentication key |
| `PORT` | `4000` | Listen port |
| `HOST` | `0.0.0.0` | Listen address |

## How It Works

1. A single wildcard model rule accepts any model name
2. A pre-call hook reads `X-Upstream-*` headers from each request
3. The hook injects upstream URL, API key, and model into LiteLLM's request pipeline
4. LiteLLM forwards the request to the specified upstream and streams back the response

The server is completely stateless — one deployment can serve any number of clients hitting any number of upstream providers simultaneously.

## Build from Source

```bash
git clone https://github.com/adaex/litellm-passthrough.git
cd litellm-passthrough
docker build -t litellm-passthrough .
docker run -d --name litellm-passthrough -p 4000:4000 litellm-passthrough
```

## License

MIT
