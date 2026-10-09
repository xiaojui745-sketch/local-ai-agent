# 本地 Ollama CLI 智能体

这是一个运行在 Windows PowerShell 中的本地工具调用智能体。它通过 Ollama 的本机 API 使用 `qwen3:8b`，并能根据问题决定是否调用本地时间和安全计算工具。

## 能做什么

- 多轮中文对话，保留当前会话上下文。
- 根据问题调用 `get_local_time` 查询本机时间。
- 根据问题调用 `calculate` 计算四则运算表达式。
- 不安装 Python 包，不需要云端 API Key；模型请求发往本机 Ollama。

## 前置条件

1. Windows PowerShell 5.1 或更新版本。
2. Ollama 正在运行，且已下载 `qwen3:8b`。
3. 默认 API 地址为 `http://127.0.0.1:11434`。

## 启动

在项目根目录打开 PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\src\agent.ps1
```

输入问题开始对话；输入 `/reset` 清空当前上下文，输入 `/exit` 退出。

可以通过环境变量更换模型或 API 地址：

```powershell
$env:OLLAMA_MODEL = "qwen3:8b"
$env:OLLAMA_BASE_URL = "http://127.0.0.1:11434"
powershell -NoProfile -ExecutionPolicy Bypass -File .\src\agent.ps1
```

## 项目结构

```text
ollama-cli-agent/
├── README.md
├── .gitignore
├── docs/
│   └── progress.md
└── src/
    └── agent.ps1
```

## 智能体工作方式

程序把用户消息、系统提示和工具说明发给 Ollama。模型可以直接回答，也可以返回工具调用。程序只执行白名单中的两个本地工具，再把结果交回模型生成最终答复。计算器只接受数字、括号和 `+ - * / %`，不会执行任意 PowerShell 命令。

## AI 使用说明

本项目使用本地 Ollama 模型 `qwen3:8b` 作为推理服务。代码框架和文档由 Codex 协助生成；工具执行由本地脚本完成。当前版本不调用云端模型，也不联网查询。

## Git 记录

```powershell
git init
git add README.md .gitignore docs src
git commit -m "Build local Ollama CLI agent"
```

配置个人 GitHub 远端后，再推送到自己的仓库。
