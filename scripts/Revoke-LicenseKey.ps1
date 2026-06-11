param(
  [Parameter(Mandatory = $true)]
  [string]$Key
)

$ErrorActionPreference = "Stop"

function Get-Sha256 {
  param([string]$Text)

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    return (-join ($hash | ForEach-Object { $_.ToString("x2") }))
  }
  finally {
    $sha.Dispose()
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$keyHash = Get-Sha256 -Text $Key.Trim()
$changed = $false

foreach ($duration in @("day", "month", "year", "century")) {
  $jsonPath = Join-Path $repoRoot "$duration.json"
  $data = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json

  if ($data.keys -and $data.keys.PSObject.Properties.Name -contains $keyHash) {
    $data.keys.$keyHash.active = $false
    $data.keys.$keyHash.revokedAt = [datetime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $data | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
    Write-Host "已禁用密钥，文件: $jsonPath"
    $changed = $true
  }
}

if (-not $changed) {
  Write-Host "没有找到这个密钥。"
}
