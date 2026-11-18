---
name: officecli-local
description: 使用本机本地编辑版 OfficeCLI 创建、读取、检查和修改 Word、Excel、PowerPoint 文件（.docx、.xlsx、.pptx）。适用于本地 Office 文件操作，不使用同名平台生成服务或账号登录流程。
---

# Office 本地编辑

## 工具边界

使用 `iOfficeAI/OfficeCLI` 的本地文档编辑工具。基础文件读写不需要平台登录、生成额度或安装 Microsoft Office；部分扩展功能可能另有依赖，应以实际帮助为准。

本机已核验的程序是：

```powershell
$officecli = 'C:\Users\PC\AppData\Local\OfficeCLI\officecli.exe'
& $officecli --version
& $officecli --help
```

本地版提供 `create`、`get`、`add`、`set`、`validate` 等命令。不要把只有 `new`、`login`、`whoami` 等平台流程的同名工具当成本地版，也不要为本地编辑安装平台版、运行平台版环境修复脚本或要求用户登录。

其他电脑上先定位实际的本地版程序；若找不到，不擅自下载安装或改用云端服务，说明缺少哪项依赖。

## 操作方式

- 优先使用文档级读取和元素编辑，只有高层命令无法表达目标时才使用原始 XML。
- 属性名称、路径或取值不确定时，先运行 `help`，不要猜测接口。
- 需要解析结果时使用 `--json`，同时检查 `success`、错误信息和警告。
- 使用用户指定的源文件和输出目录。修改重要原件前保留副本，不擅自使用 `--force` 覆盖已有文件。
- 优先使用读取结果中返回的稳定元素路径，并为含方括号的路径加引号。

按当前任务查询实际接口：

```powershell
& $officecli help docx
& $officecli help docx add paragraph
& $officecli help xlsx cell --json
& $officecli help pptx shape --json
```

选择对应的文件类型：`docx`、`xlsx` 或 `pptx`。不要把 Word 的元素路径直接用于 Excel 或 PowerPoint。

## 常用命令

以下尖括号内容是需要按任务替换的参数，不要原样执行。

```text
officecli create <文件> --locale zh-CN --json
officecli view <文件> outline --json
officecli get <文件> <元素路径> --json
officecli query <文件> <选择器> --json
officecli add <文件> <父元素路径> --type <元素类型> --prop <属性=值> --json
officecli set <文件> <元素路径> --prop <属性=值> --json
officecli validate <文件> --json
```

在本机执行时，应通过前述完整程序路径或已核验指向本地版的命令运行。

文档节点通常使用从一开始的路径索引；位置参数和 Excel 行列插入的索引规则可能不同，按该命令的帮助确认。

批量操作使用 `batch` 的结构化数组。每个数组项的 `command` 是单个操作名称，`path`、`parent`、`type`、`props` 等是同级字段，不要把完整命令行塞入 `command`。批量失败后检查逐项结果和是否回滚，不把部分成功当作全部完成。

## 专项指引

复杂任务可从同一个本地程序读取相应专项技能：

```powershell
& $officecli load_skill word
& $officecli load_skill excel
& $officecli load_skill pptx
```

按任务只读取相关的一项。其他场景包括 `academic-paper`、`pitch-deck`、`financial-model`、`data-dashboard`、`morph-ppt`、`morph-ppt-3d`；使用前确认本机版本提供对应技能，不擅自安装不存在的技能。

## 保存与验证

程序可能自动启动文档驻留进程。它自身的读取命令可以看到内存中的最新修改，但外部程序可能仍读到旧的磁盘内容。

- 外部渲染、上传、交付文件或交给其他库读取前，先执行 `save` 或 `close`。
- `save` 保存但保留驻留进程；`close` 保存并释放当前文档。
- 只关闭本次任务使用的文档，不结束其他正在工作的进程。
- 修改后运行 `validate`，并读取关键内容确认实际变更。结构校验不能代替有版式要求时的渲染检查。

```text
officecli save <文件> --json
officecli close <文件> --json
officecli validate <文件> --json
```

## 来源

这是中文本地适配版，并非官方逐字翻译。依据官方仓库 `iOfficeAI/OfficeCLI` 的 `v1.0.161` 标签、`skills/officecli/SKILL.md`，以及本机同版本程序的实际帮助整理。升级程序后应重新核对接口，不自动更新或重新安装同名平台工具。
