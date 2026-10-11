param(
    [string]$Model = $env:OLLAMA_MODEL,
    [string]$BaseUrl = $env:OLLAMA_BASE_URL
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = 'qwen3:8b'
}
if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = 'http://127.0.0.1:11434'
}
$ChatEndpoint = $BaseUrl.TrimEnd('/') + '/api/chat'

function Test-OllamaApi {
    try {
        $null = Invoke-RestMethod -Uri ($BaseUrl.TrimEnd('/') + '/api/tags') -TimeoutSec 2
        return $true
    }
    catch {
        return $false
    }
}

function Start-OllamaServerIfNeeded {
    if (Test-OllamaApi) {
        return $true
    }

    $ollamaExe = 'C:\Users\Hi\AppData\Local\Programs\Ollama\ollama.exe'
    if (-not (Test-Path -LiteralPath $ollamaExe)) {
        Write-Host "找不到 Ollama 程序：$ollamaExe" -ForegroundColor Red
        return $false
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $ollamaExe
    $startInfo.Arguments = 'serve'
    $startInfo.WorkingDirectory = Split-Path -Parent $ollamaExe
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.EnvironmentVariables['OLLAMA_MODELS'] = 'D:\OllamaModels'

    try {
        [void][System.Diagnostics.Process]::Start($startInfo)
    }
    catch {
        Write-Host "启动 Ollama 失败：$($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        if (Test-OllamaApi) {
            return $true
        }
        Start-Sleep -Seconds 1
    }

    Write-Host '等待 Ollama API 超时。请先打开桌面上的 Ollama，再重新启动智能体。' -ForegroundColor Red
    return $false
}

$ToolDefinitions = @(
    @{
        type = 'function'
        'function' = @{
            name = 'get_local_time'
            description = '读取这台电脑当前的本地日期、时间和时区。'
            parameters = @{
                type = 'object'
                properties = @{}
            }
        }
    },
    @{
        type = 'function'
        'function' = @{
            name = 'calculate'
            description = '计算只包含数字、括号和加减乘除或取余运算的数学表达式。'
            parameters = @{
                type = 'object'
                required = @('expression')
                properties = @{
                    expression = @{
                        type = 'string'
                        description = '例如：(18 + 6) * 2'
                    }
                }
            }
        }
    }
)

$SystemMessage = @{
    role = 'system'
    content = '你是运行在用户电脑上的中文本地智能体。需要精确计算时调用 calculate；询问当前本地时间时调用 get_local_time。收到工具结果后，用简洁中文回答。不要声称调用了未提供的工具。'
}

function Invoke-AgentTool {
    param(
        [Parameter(Mandatory = $true)]$ToolCall
    )

    $name = [string]$ToolCall.function.name
    $arguments = $ToolCall.function.arguments

    switch ($name) {
        'get_local_time' {
            return [DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz')
        }
        'calculate' {
            $expression = [string]$arguments.expression
            if ([string]::IsNullOrWhiteSpace($expression) -or $expression.Length -gt 100) {
                throw '表达式为空或过长。'
            }
            if ($expression -notmatch '^[0-9\s+\-*/().%]+$') {
                throw '只允许数字、空格、括号和 + - * / % 运算符。'
            }

            $table = New-Object System.Data.DataTable
            $value = $table.Compute($expression, '')
            return [string]$value
        }
        default {
            throw "拒绝执行未登记的工具：$name"
        }
    }
}

function Invoke-ModelTurn {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[object]]$Messages
    )

    $payload = @{
        model = $Model
        messages = @($Messages.ToArray())
        tools = $ToolDefinitions
        stream = $false
    }
    $json = ConvertTo-Json -InputObject $payload -Depth 20 -Compress
    $response = Invoke-RestMethod -Uri $ChatEndpoint -Method Post -ContentType 'application/json; charset=utf-8' -Body $json -TimeoutSec 180
    return $response.message
}

function New-Conversation {
    $messages = New-Object 'System.Collections.Generic.List[object]'
    $messages.Add($SystemMessage)
    return ,$messages
}

if (-not (Start-OllamaServerIfNeeded)) { exit 1 }
$messages = New-Conversation
Write-Host "本地 Ollama 智能体已启动：模型 $Model" -ForegroundColor Cyan
Write-Host '输入 /reset 清空上下文，输入 /exit 退出。' -ForegroundColor DarkGray

while ($true) {
    $inputText = Read-Host '你'
    if ([string]::IsNullOrWhiteSpace($inputText)) {
        continue
    }
    if ($inputText -eq '/exit') {
        break
    }
    if ($inputText -eq '/reset') {
        $messages = New-Conversation
        Write-Host '已清空对话上下文。' -ForegroundColor DarkGray
        continue
    }

    if ($inputText -match '现在几点|当前时间|现在时间|今天几号|今天日期') {
        Write-Host ('智能体（本机时间）：' + [DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz')) -ForegroundColor Green
        continue
    }
    if ($inputText -match '^\s*(?:请)?(?:帮我)?(?:计算|算一下|算)\s*[:：]?\s*(.+?)\s*[。?？]?\s*$') {
        $expression = $Matches[1].Trim()
        Write-Host '[调用工具] calculate（本地）' -ForegroundColor Yellow
        try {
            $toolCall = @{ 'function' = @{ name = 'calculate'; arguments = @{ expression = $expression } } }
            $result = Invoke-AgentTool -ToolCall $toolCall
            Write-Host "计算结果：$result" -ForegroundColor Green
        }
        catch {
            Write-Host "计算失败：$($_.Exception.Message)" -ForegroundColor Red
        }
        continue
    }
    $messages.Add(@{ role = 'user'; content = $inputText })
    try {
        $finished = $false
        for ($step = 0; $step -lt 6; $step++) {
            $assistantMessage = Invoke-ModelTurn -Messages $messages
            $messages.Add($assistantMessage)
            $toolCalls = @($assistantMessage.tool_calls)

            if ($toolCalls.Count -eq 0) {
                if (-not [string]::IsNullOrWhiteSpace([string]$assistantMessage.content)) {
                    Write-Host "智能体：$($assistantMessage.content)" -ForegroundColor Green
                }
                $finished = $true
                break
            }

            foreach ($toolCall in $toolCalls) {
                $toolName = [string]$toolCall.function.name
                Write-Host "[调用工具] $toolName" -ForegroundColor Yellow
                try {
                    $toolResult = Invoke-AgentTool -ToolCall $toolCall
                }
                catch {
                    $toolResult = "工具执行失败：$($_.Exception.Message)"
                }
                $messages.Add(@{
                    role = 'tool'
                    tool_name = $toolName
                    content = [string]$toolResult
                })
            }
        }

        if (-not $finished) {
            Write-Host '本轮工具调用次数达到上限，请缩小问题范围后重试。' -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "请求失败：$($_.Exception.Message)" -ForegroundColor Red
        Write-Host '请确认 Ollama 正在运行，并且模型已下载。' -ForegroundColor DarkGray
    }
}

