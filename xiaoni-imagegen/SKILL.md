---
name: xiaoni-imagegen
description: Use when a user asks Codex to generate images, edit images from local references, call gpt-image-2, run asynchronous image generation, resume an image task, or use image APIs. 
---

# Xiaoni ImageGen

使用当前codex配置的apiKey通过固定的媒体站异步接口生成或编辑图片。

## 配置发现（先做，避免手动试错）

解析优先级：

1. Base URL：优先 https://media.xiaoni-apikey.top，其次使用`~/.codex/config.toml` 的 `base_url`。
2. API key：`~/.codex/auth.json` 中的 `OPENAI_API_KEY` 或 `api_key`。

### `generate`

```text
generate
  (--prompt TEXT | --prompt-file FILE)
  [--model gpt-image-2]
  [--size 1024x1024]
  [--quality low|medium|high|auto]
  [--output-format png]
  [--n 1..10]
  [--out-dir DIR]
  [--name PREFIX]
  [--api-key-env ENV_NAME]
  [--timeout SECONDS]
  [--max-retries COUNT]
```

调用：

```text
POST ${BASE_URL}/v1/images/generations/async
Content-Type: application/json
```

请求体只发送接口支持的字段：`model`、`prompt`、`size`、`quality`、`output_format`、`n`。

### `edit`

```text
edit
  (--prompt TEXT | --prompt-file FILE)
  --image FILE [--image FILE ...]
  [--mask FILE]
  [与 generate 相同的模型、输出和轮询参数]
```

调用：

```text
POST ${BASE_URL}/v1/images/edits/async
Content-Type: multipart/form-data
```

规则：

- 图片按 `--image` 出现顺序上传
- 图片字段使用 `image[]`
- 单张输入图片最大 20 MB
- mask 最大 4 MB
- 至少一张输入图片

### `poll`

```text
poll
  --task-id TASK_ID
  [--out-dir DIR]
  [--name PREFIX]
  [--api-key-env ENV_NAME]
  [--timeout SECONDS]
  [--max-retries COUNT]
```

用创建任务时的同一个 Key 查询：

```text
GET ${BASE_URL}/v1/images/tasks/{task_id}
```
