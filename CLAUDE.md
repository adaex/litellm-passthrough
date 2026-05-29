# litellm-passthrough

零状态 LLM 网关：基于 LiteLLM proxy，所有上游凭证通过 `X-Upstream-*` header 逐请求传入，服务端不存任何状态。

## 镜像

- Base: `python:3.13-slim` + uv 装 `litellm[proxy]`
- 不再 base on `litellm/litellm` 官方镜像 —— 太重（1.2GB），且强制把 prisma 挂在 import 路径上拖慢启动 ~10s
- `litellm[proxy]` 自 1.86 起也不再硬依赖 prisma —— 锁版本时不要回退到 ≤1.85，否则 prisma 会回来（容器到 ready 从 ~7s 退化到 ~22s，镜像从 ~644MB 涨到 ~1.2GB）
- 启动到 ready ~7s，镜像 ~644MB

## 关键配置

| 项 | 值 / 说明 |
|----|----------|
| `custom_llm_provider` | `custom_openai`，**不能用** `openai`（会让 `/v1/messages` 走 Responses API 流式失败） |
| `configurable_clientside_auth_params` | `[api_base, api_key]`，让 hook 能覆盖 |
| `LITELLM_LOCAL_MODEL_COST_MAP=true` | 跳过启动时拉 GitHub 上的 cost map |
| `NO_DOCS / NO_REDOC / NO_OPENAPI` | 关 swagger 三件套 |
| `DISABLE_ADMIN_UI=true` | 关 admin SSO 入口（`/ui` 静态资源 mount 改不掉，无害） |
| `LITELLM_MASTER_KEY` | 默认 `sk-litellm-passthrough` 烘焙在镜像里。**生产必须覆盖**或加网络隔离 |
| `HOST` | 默认 `0.0.0.0`。`::` 在禁用 IPv6 的容器 netns 上会假死 — 看 README 的 Listen address 章节 |

## hooks.py

- 必填：`X-Upstream-Url` + `X-Upstream-Authorization`，缺失直接 `HTTPException(400)`
- 可选：`X-Upstream-Model`（单覆盖）、`X-Upstream-Models`（`a=b,c=d` 映射，优先级高）

## 本地验证

```bash
docker build --build-arg LITELLM_VERSION=1.86.2 -t lp .
docker run -d --name lp -p 4000:4000 lp

# 端到端（替换 JWT 和 upstream URL）
curl http://127.0.0.1:4000/v1/messages \
  -H "Authorization: Bearer sk-litellm-passthrough" \
  -H "X-Upstream-Url: <upstream-endpoint>" \
  -H "X-Upstream-Authorization: Bearer <token>" \
  -H "X-Upstream-Model: <upstream-model-name>" \
  -d '{"model":"claude-opus-4-6","max_tokens":20,"messages":[{"role":"user","content":"ping"}]}'
```

## CI

`.github/workflows/docker.yml` 每天 03:17 UTC 从 PyPI 拉最新 `litellm` 版本 build。tag 策略：`{version}` → `{version}-1` → `{version}-2`。
