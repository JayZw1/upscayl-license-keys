param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("day", "month", "year", "century")]
  [string]$Duration,

  [string]$Key,
  [string]$Note = ""
)

$ErrorActionPreference = "Stop"

function New-RandomLicenseKey {
  param([string]$Duration)

  $bytes = [byte[]]::new(16)
  [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
  $hex = -join ($bytes | ForEach-Object { $_.ToString("X2") })
  $groups = ($hex -split "(.{4})" | Where-Object { $_ })
  return "UPSCAYL-$($Duration.ToUpperInvariant())-$($groups -join '-')"
}

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

function Get-ExpiryIso {
  param(
    [datetime]$Start,
    [string]$Duration
  )

  switch ($Duration) {
    "day" { return $Start.AddDays(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
    "month" { return $Start.AddMonths(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
    "year" { return $Start.AddYears(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
    "century" { return $Start.AddYears(100).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonPath = Join-Path $repoRoot "$Duration.json"

if (-not $Key) {
  $Key = New-RandomLicenseKey -Duration $Duration
}

$createdAt = [datetime]::UtcNow
$keyHash = Get-Sha256 -Text $Key.Trim()
$data = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json

if (-not $data.keys) {
  $data | Add-Member -MemberType NoteProperty -Name keys -Value ([pscustomobject]@{})
}

$record = [ordered]@{
  keyHash = $keyHash
  createdAt = $createdAt.ToString("yyyy-MM-ddTHH:mm:ssZ")
  expiresAt = Get-ExpiryIso -Start $createdAt -Duration $Duration
  duration = $Duration
  active = $true
  note = $Note
}

$data.keys | Add-Member -MemberType NoteProperty -Name $keyHash -Value ([pscustomobject]$record) -Force
$data | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

Write-Output "已生成 $Duration 密钥"
Write-Output "真实密钥: $Key"
Write-Output "到期时间: $($record.expiresAt)"
Write-Output "已写入: $jsonPath"
