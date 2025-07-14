param (
    [switch]$DebugMode,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$remainingArgs
)

if ($DebugMode) {
    $DebugPreference = 'Continue'
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$DOCKER_IMG = "idachev/claude-code:latest"

if (-not $env:CLAUDE_CODE_HOME) {
    $env:CLAUDE_CODE_HOME = $env:USERPROFILE
}

$ClaudeDir = Join-Path $env:CLAUDE_CODE_HOME ".claude"
if (-not (Test-Path $ClaudeDir)) {
    New-Item -Path $ClaudeDir -ItemType Directory -Force | Out-Null
    Write-Host "Created $ClaudeDir directory"
}

$ClaudeConfigFile = Join-Path $env:CLAUDE_CODE_HOME ".claude.json"
if (-not (Test-Path $ClaudeConfigFile)) {
    "" | Out-File -FilePath $ClaudeConfigFile -Encoding utf8 -Force
    Write-Host "Created $ClaudeConfigFile with empty JSON object"
}

$CURRENT_DIR = (Get-Location).Path
$CURRENT_DIR_BASENAME = Split-Path -Leaf $CURRENT_DIR

$DOCKER_NAME = "claude-code"

Write-Host "Pulling latest Docker image: $DOCKER_IMG"
& docker pull $DOCKER_IMG
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to pull Docker image"
    exit 1
}

try {
    & docker run -it --rm `
        --name $DOCKER_NAME `
        -v "${CURRENT_DIR}:/workspace/${CURRENT_DIR_BASENAME}" `
        -v "${ClaudeDir}:/home/node/.claude" `
        -v "${ClaudeConfigFile}:/home/node/.claude.json" `
        --entrypoint /bin/zsh `
        $DOCKER_IMG `
        -c "cd /workspace/${CURRENT_DIR_BASENAME} && claude $remainingArgs && zsh"
} catch {
    Write-Error "Error running Docker: $_"
    exit 1
}
