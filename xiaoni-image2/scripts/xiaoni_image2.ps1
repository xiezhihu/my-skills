param(
    [Parameter(Mandatory = $true)]
    [string]$Prompt,

    [string]$Out = "output/imagegen/xiaoni-image.png",
    [string]$Model = "gpt-image-2",
    [string]$Size = "1024x1024",
    [ValidateSet("low", "medium", "high", "auto")]
    [string]$Quality = "medium",
    [string]$BaseUrl = "https://xiaoni-model.top/v1",
    [int]$N = 1,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Resolve-XiaoniApiKey {
    $authPath = Join-Path -Path $HOME -ChildPath ".codex\auth.json"
    if (-not (Test-Path -LiteralPath $authPath)) {
        return [pscustomobject]@{ Source = $null; Value = $null }
    }

    try {
        $auth = Get-Content -Raw -LiteralPath $authPath | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "无法解析 API 密钥配置文件：$authPath"
    }

    foreach ($field in @("OPENAI_API_KEY", "api_key")) {
        $property = $auth.PSObject.Properties[$field]
        if ($property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [pscustomobject]@{
                Source = "$authPath 的 $field 字段"
                Value = [string]$property.Value
            }
        }
    }

    return [pscustomobject]@{ Source = $null; Value = $null }
}

$apiKey = Resolve-XiaoniApiKey
if (-not $apiKey.Value) {
    throw "未在 $HOME\.codex\auth.json 中找到 OPENAI_API_KEY 或 api_key。"
}

$outPath = [System.IO.Path]::GetFullPath($Out)
if ((Test-Path -LiteralPath $outPath) -and -not $Force) {
    throw "输出文件已存在：$outPath。请传入 -Force 覆盖，或使用其他 -Out 路径。"
}

$bodyObject = [ordered]@{
    model = $Model
    prompt = $Prompt
    size = $Size
    quality = $Quality
    n = $N
}
$body = $bodyObject | ConvertTo-Json -Depth 10
$endpoint = ($BaseUrl.TrimEnd('/')) + "/images/generations"

if ($DryRun) {
    [pscustomobject]@{
        endpoint = $endpoint
        output = $outPath
        body = $bodyObject
        api_key_present = $true
        api_key_source = $apiKey.Source
    } | ConvertTo-Json -Depth 10
    exit 0
}

$headers = @{
    "Authorization" = "Bearer $($apiKey.Value)"
    "Content-Type" = "application/json"
}

try {
    $res = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $body
} catch {
    $status = $null
    $detail = $null
    if ($_.Exception.Response) {
        try { $status = [int]$_.Exception.Response.StatusCode } catch {}
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $detail = $reader.ReadToEnd()
        } catch {}
    }
    if ($detail) {
        $statusText = if ($null -ne $status) { " with HTTP $status" } else { "" }
        throw ("小妮图片请求失败" + $statusText + "：" + $detail)
    }
    throw
}

if (-not $res.data -or -not $res.data[0].b64_json) {
    $json = $res | ConvertTo-Json -Depth 10
    throw "响应中未包含 data[0].b64_json。原始响应：$json"
}

$dir = Split-Path -Parent $outPath
if ($dir) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

[System.IO.File]::WriteAllBytes($outPath, [System.Convert]::FromBase64String($res.data[0].b64_json))

[pscustomobject]@{
    path = $outPath
    model = $Model
    size = $Size
    quality = $Quality
    background = $res.background
    output_format = $res.output_format
    created = $res.created
    bytes = (Get-Item -LiteralPath $outPath).Length
} | ConvertTo-Json -Depth 10


