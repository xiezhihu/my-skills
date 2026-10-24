---
name: xiaoni-image2
description: 通过小妮兼容 OpenAI 的图片接口生成图片，支持 gpt-image-2/image2 风格的提示词设计、生成、检查和迭代。当用户要求经由 Xiaoni、小妮、中转站、image2、gpt-image-2 或 xiaoni-model.top 生成、保存、迭代、改善或测试图片时使用。支持使用 PowerShell 将 b64_json 响应保存为 PNG、JPEG 或 WebP 文件。
---

# 小妮 Image2

## 概述

使用此技能经由小妮中转站生成图片，而非 Codex 内置图片工具。接口根地址为 `https://xiaoni-model.top/v1`，图片生成端点为 `/images/generations`，响应中应包含 `data[0].b64_json`；随附脚本会将图片写入本地文件。

不得将 API 密钥写入技能文件、命令历史示例或最终回复。仅从 `~/.codex/auth.json` 读取密钥：优先读取 `OPENAI_API_KEY`，未设置时读取 `api_key`。如果用户曾在对话中粘贴密钥，提醒其尽快轮换该密钥。

本技能不只是 API 包装器。应将用户需求当作创意简报：理解视觉意图，将较弱的提示词改写为可生产使用的提示词；需要时生成草稿、检查结果，并通过有针对性的调整迭代。

## 快速开始

使用随附的 PowerShell 脚本：

```powershell
& "$env:USERPROFILE\.codex\skills\xiaoni-image2\scripts\xiaoni_image2.ps1" `
  -Prompt "一只赛博朋克猫，霓虹背景，高细节插画" `
  -Out "output/imagegen/test.png"
```

默认设置：

- 接口根地址：`https://xiaoni-model.top/v1`
- 端点：`/images/generations`
- 模型：`gpt-image-2`
- 尺寸：`1024x1024`
- 质量：`medium`
- 输出：`output/imagegen/xiaoni-image.png`

## 工作流

1. 将用户请求理解为创意简报：主体、风格、用途、画布、约束和输出路径。
2. 若提示词过于笼统，以克制且合适的视觉细节补强；若已足够详细，只做规范化而不虚构额外要求。
3. 选择生成方式：简单一次性请求使用“直接成品”；重要、模糊、强调美感或与项目相关的请求使用“草稿 -> 色彩/风格 -> 成品”；需要探索时，为不同概念使用不同提示词，而不是只增加 `-N`。
4. 在不输出密钥内容的情况下，确认 `~/.codex/auth.json` 中存在 `OPENAI_API_KEY` 或 `api_key`。随附脚本会按该顺序读取。

```powershell
Test-Path "$env:USERPROFILE\.codex\auth.json"
```

5. 若脚本报告密钥不可用，请用户检查 `~/.codex/auth.json` 中的小妮中转站密钥字段；不要在对话中要求或展示其真实密钥。
6. 使用优化后的提示词和目标输出路径运行 `scripts/xiaoni_image2.ps1`。
7. 尽可能检查已保存的输出：主体、风格、构图、文字准确性、约束遵守情况和明显瑕疵。
8. 每次迭代只做一项有针对性的改动，并在每次重试中重新说明关键约束。
9. 脚本成功后，报告已保存图片路径、最终提示词；在有帮助时可内联展示本地图片。
10. 如果中转站返回 `API_KEY_REQUIRED`，请用户检查 `~/.codex/auth.json` 中的 `OPENAI_API_KEY` 或 `api_key`。
11. 如果中转站返回 `Request body is empty`，不要手写多行 `Invoke-RestMethod` 请求；应使用随附脚本。
12. 如果中转站返回 `Your request was blocked`，可使用英文提示词或减少可选参数重试一次；若仍被拦截，应说明这是中转站侧策略或模型访问限制。

## 提示词设计

除非用户要求在图中出现中文文字，否则优先向 API 发送英文生产级提示词。保留用户提供的风格词、名称、精确文案和约束。除非用户明确要求，不添加徽标、商标、水印、额外角色或叙事道具。

可使用以下紧凑结构组织提示词：

```text
用途：<短标识>
资产类型：<图片将在哪里使用>
核心请求：<用户的核心要求>
场景/背景：<环境>
主体：<主要对象和关键属性>
风格/媒介：<照片 / 插画 / 3D / 概念艺术 / UI 模型图>
构图/取景：<特写 / 广角 / 俯视 / 居中 / 留白>
光线/情绪：<光线、氛围、情绪基调>
配色：<色彩说明>
材质/纹理：<表面细节>
文字（逐字）："<精确文字，如有>"
约束：<必须保留、必须包含的内容>
避免：<水印、额外文字、徽标等负向约束>
```

只保留有帮助的行。对于“赛博朋克风格的狗”这类简短请求，可使用如下提示词：

```text
用途：风格化概念设计
核心请求：一只作为忠实街头伙伴的赛博朋克狗
场景/背景：有霓虹招牌和反光路面的雨后未来小巷
主体：警觉的狗，佩戴低调的铬合金项圈，并有适度的赛博细节
风格/媒介：电影感高细节数字插画
构图/取景：中近景，狗是清晰视觉焦点，轮廓鲜明
光线/情绪：青色与品红色的霓虹轮廓光，有情绪但保持可读性
约束：无文字、无水印、无徽标，避免过度堆砌机械元素
```

### 具体化规则

- 用户提供详细提示词时，保留内容并优化措辞。
- 用户提供模糊提示词时，补充明确的取景、光线、媒介和约束。
- 已知时加入用途：头像、海报、游戏素材、产品模型图、壁纸、幻灯片或应用模型图。
- 图中文字应使用引号逐字指定；文字准确性很重要时，可将不常见单词逐个字母拼写。
- 编辑或参考图类请求须重申不变量：只改指定元素，保持身份、姿势、布局、光线和背景不变。当前小妮脚本使用生成端点，因此真正保留原图的编辑需要使用支持编辑的其他工作流。

### 用途短标识

- `photorealistic-natural`：真实世界的抓拍或编辑摄影。
- `product-mockup`：产品、包装、目录或周边商品。
- `ui-mockup`：应用或网页界面模型图。
- `infographic-diagram`：带标签和箭头的结构化图表。
- `scientific-educational`：课堂或科学讲解图。
- `ads-marketing`：广告活动图片与广告概念。
- `productivity-visual`：幻灯片、图表和商务视觉资料。
- `logo-brand`：徽标和标志探索。
- `illustration-story`：漫画、儿童绘本场景和叙事分镜。
- `stylized-concept`：概念艺术、3D/风格化渲染和游戏美术。
- `historical-scene`：符合时代背景的历史场景。

## 分阶段生成

对于重视质量或审美的请求，可模拟 OpenAI Web 的工作方式：先生成强有力的初稿，评估后以具体要求继续优化。由于当前脚本仅支持生成，每一阶段都是新的生成请求；需通过明确重申所选方向来保持连续性。

### 草稿

使用快速、宽泛的提示词确定主体、构图和氛围。快速探索使用 `-Quality low`；若低质量不够，可使用 `medium`。

```powershell
& "$env:USERPROFILE\.codex\skills\xiaoni-image2\scripts\xiaoni_image2.ps1" `
  -Prompt "<草稿提示词：主体、构图、氛围，不过度堆砌精细细节>" `
  -Quality low `
  -Out "output/imagegen/<名称>-draft.png"
```

草稿提示词模式：

```text
创建一张粗略但清晰可读的 <主体> 概念图。
聚焦构图、轮廓、镜头角度和整体氛围。
保持细节简洁；无文字、无水印。
```

### 色彩与风格

检查草稿后，锁定有效部分，并补充色板、光线、材质和风格。

```text
延续选定方向：<有效部分>。
将配色优化为 <色板>，光线优化为 <光线>，媒介优化为 <风格>。
保持相同主体、取景和情绪，避免 <草稿中的问题>。
```

### 成品润色

使用 `medium`、`high` 或 `auto` 质量生成成品，并增加更清晰的约束和生产用途。

```text
为 <资产类型> 生成最终润色图。
保留：<选定的构图、主体身份、配色>。
改进：<具体瑕疵或薄弱区域>。
添加：<仅用户要求的细节>。
约束：无水印、无额外文字、无徽标、边缘干净、焦点明确。
```

高密度细节、可读文字、产品标签、图表或重要项目交付物使用 `-Quality high`；普通插画和预览使用 `medium`。

## 迭代启发

- 每次重试只改一个维度：构图、配色、主体细节、光线、文字或背景。
- 重复必须在重试中保留的约束。
- 图片发生偏移时，缩短提示词并强调不变量。
- 图片平淡时，增加具体感官细节：材质、天气、镜头/取景、表面纹理和对比。
- 图片杂乱时，要求更简单的轮廓、更少的背景元素和更强的焦点层级。
- 文字错误时，简化画面，并只请求一句简短的引号内文字。
- 除非用户要求保留，否则仅使用命名清晰的文件保存最终交付物。

## 透明背景或抠图请求

通过该小妮生成路径使用 `gpt-image-2` 会返回普通栅格图片。对于需要透明背景的简单不透明主体，可先在纯色抠图背景上生成，再在本地移除背景。

提示词：

```text
将 <主体> 置于完全平坦的纯色 #00ff00 抠图背景上，用于后续移除背景。
背景必须是单一均匀颜色，没有阴影、渐变、纹理、反射、地面或光照变化。
主体需与背景完全分离，边缘清晰，并保留充足边距。
主体中不得使用 #00ff00。
除非明确要求，不要投影、接触阴影、反射、水印或文字。
```

若已安装，可使用以下辅助工具：

```powershell
python "$env:USERPROFILE\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py" --input "<源文件.png>" --out "<成品.png>" --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill
```

对于复杂毛发、烟雾、玻璃、液体、半透明材质或柔和阴影，先说明无法承诺完美透明效果。

## 脚本用法

```powershell
# 基础调用
& "$env:USERPROFILE\.codex\skills\xiaoni-image2\scripts\xiaoni_image2.ps1" -Prompt "..." -Out "output/imagegen/result.png"

# 自定义模型、尺寸和质量
& "$env:USERPROFILE\.codex\skills\xiaoni-image2\scripts\xiaoni_image2.ps1" `
  -Prompt "..." `
  -Model "gpt-image-2" `
  -Size "1024x1024" `
  -Quality "medium" `
  -Out "output/imagegen/result.png"

# 仅检查请求，不发起网络调用
& "$env:USERPROFILE\.codex\skills\xiaoni-image2\scripts\xiaoni_image2.ps1" -Prompt "..." -DryRun
```

## 注意事项

- 优先使用此脚本，而非 Codex 通用 `image_gen.py`，因为此技能已针对小妮图片接口组织了请求和本地保存流程。
- 不要使用 `/v1/images`；应使用接口根地址后的 `/images/generations`。
- 不要粘贴或打印 API 密钥；脚本仅从 `~/.codex/auth.json` 中的 `OPENAI_API_KEY` 或 `api_key` 读取。
- 若接口调用失败，应报告去敏后的错误信息；不得输出密钥内容。
