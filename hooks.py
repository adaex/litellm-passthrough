from typing import Optional, Union
from litellm.integrations.custom_logger import CustomLogger


def _parse_models_map(raw: str) -> dict:
    out = {}
    for pair in raw.split(","):
        if "=" not in pair:
            continue
        k, v = pair.split("=", 1)
        k, v = k.strip(), v.strip()
        if k and v:
            out[k] = v
    return out


class DynamicUpstreamHook(CustomLogger):
    async def async_pre_call_hook(
        self,
        user_api_key_dict,
        cache,
        data: dict,
        call_type,
    ) -> Optional[Union[Exception, str, dict]]:
        proxy_req = data.get("proxy_server_request") or {}
        headers = proxy_req.get("headers") or {}
        headers_lc = {k.lower(): v for k, v in headers.items()}

        upstream_url = headers_lc.get("x-upstream-url")
        upstream_auth = headers_lc.get("x-upstream-authorization")
        upstream_models = headers_lc.get("x-upstream-models")
        upstream_model = headers_lc.get("x-upstream-model")

        if upstream_url:
            data["api_base"] = upstream_url

        if upstream_auth:
            data["api_key"] = (
                upstream_auth[len("Bearer "):]
                if upstream_auth.lower().startswith("bearer ")
                else upstream_auth
            )

        if upstream_models:
            mapped = _parse_models_map(upstream_models).get(data.get("model"))
            if mapped:
                data["model"] = mapped
        elif upstream_model:
            data["model"] = upstream_model

        return data


dynamic_upstream_hook = DynamicUpstreamHook()
