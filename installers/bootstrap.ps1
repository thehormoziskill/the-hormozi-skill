param(
  [ValidateSet('install', 'update', 'uninstall')]
  [string]$Action = 'install',
  [string]$Repo = $env:THS_REPO_URL
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Repo)) {
  $Repo = 'https://github.com/the-hormozi-skill/the-hormozi-skill.git'
}

$skillName = 'the-hormozi-skill'
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$dest = Join-Path $codexHome "skills\\$skillName"

function Test-CodexExtension {
  $paths = @(
    Join-Path $HOME '.vscode\extensions',
    Join-Path $HOME '.cursor\extensions',
    Join-Path $HOME '.windsurf\extensions',
    Join-Path $env:USERPROFILE '.vscode\extensions',
    Join-Path $env:USERPROFILE '.cursor\extensions',
    Join-Path $env:USERPROFILE '.windsurf\extensions'
  )

  foreach ($path in $paths) {
    if (Test-Path $path) {
      $match = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like '*codex*'
      } | Select-Object -First 1
      if ($match) {
        return $true
      }
    }
  }

  return $false
}

if ($Action -eq 'uninstall') {
  if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
    Write-Output "Removed $dest"
  } else {
    Write-Output "Skill not installed at $dest"
  }
  exit 0
}

if ($env:THS_CONFIRM_EXTENSION -ne '1') {
  if (-not (Test-CodexExtension)) {
    Write-Output 'Codex IDE extension was not auto-detected.'
    Write-Output 'Install the Codex extension in your IDE, then run again.'
    Write-Output 'If already installed in a non-standard path, rerun with THS_CONFIRM_EXTENSION=1.'
    exit 2
  }
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ths-install-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
  Write-Output "Fetching skill from $Repo"
  git clone --depth 1 $Repo (Join-Path $tmp 'repo') | Out-Null

  $source = Join-Path $tmp "repo\\$skillName"
  if (-not (Test-Path (Join-Path $source 'SKILL.md'))) {
    throw "Skill package not found at $source"
  }

  New-Item -ItemType Directory -Force -Path (Join-Path $codexHome 'skills') | Out-Null

  if ($Action -eq 'install' -and (Test-Path $dest)) {
    throw "Skill already exists at $dest. Use -Action update to replace it."
  }

  if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
  }

  Copy-Item -Path $source -Destination $dest -Recurse -Force
  Write-Output "Installed $skillName to $dest"
  Write-Output 'Restart Codex to load the new skill.'
}
finally {
  if (Test-Path $tmp) {
    Remove-Item -Recurse -Force $tmp
  }
}
