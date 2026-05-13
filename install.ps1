param(
  [string]$Root = (Get-Location).Path,
  [ValidateSet("minimal", "recommended", "complete", "custom")]
  [string]$Tier = "recommended",
  [string]$Language = "",
  [string]$Repo = "ungrav/antigravity-ultra",
  [string]$Version = "latest",
  [string]$SourceDir = "",
  [switch]$SkipBootstrap
)

$ErrorActionPreference = "Stop"

$PortableFiles = @(
  "GEMINI.md",
  "MEMORY.md",
  "GEMINI_BLUEPRINTS.md",
  "portable-kernel.sh",
  "portable-kernel-windows.ps1",
  "minimum-kernel.bundle.tar.gz"
)

function Info([string]$Message) {
  Write-Host "INFO: $Message"
}

function Fail([string]$Message) {
  Write-Error "ERROR: $Message"
  exit 1
}

function ReleaseUrl([string]$Name) {
  if ($Version -eq "latest") {
    return "https://github.com/$Repo/releases/latest/download/$Name"
  }
  return "https://github.com/$Repo/releases/download/$Version/$Name"
}

function PowerShellExe() {
  $WindowsPowerShell = Get-Command powershell -ErrorAction SilentlyContinue
  if ($null -ne $WindowsPowerShell) {
    return $WindowsPowerShell.Source
  }
  $PowerShellCore = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($null -ne $PowerShellCore) {
    return $PowerShellCore.Source
  }
  Fail "Missing PowerShell executable: powershell or pwsh"
}

$Root = [System.IO.Path]::GetFullPath($Root)
New-Item -ItemType Directory -Force -Path $Root | Out-Null
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("antigravity-ultra-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

try {
  if ($SourceDir -ne "") {
    $SourceDir = [System.IO.Path]::GetFullPath($SourceDir)
    Info "Using local portable source: $SourceDir"
    foreach ($Name in $PortableFiles) {
      $SourcePath = Join-Path $SourceDir $Name
      if (!(Test-Path $SourcePath)) {
        Fail "Missing portable file in source dir: $SourcePath"
      }
      Copy-Item -Force $SourcePath (Join-Path $TempDir $Name)
    }
  } else {
    Info "Installing Antigravity Ultra from GitHub release: $Repo@$Version"
    foreach ($Name in $PortableFiles) {
      $Url = ReleaseUrl $Name
      $OutFile = Join-Path $TempDir $Name
      Info "Downloading $Name"
      Invoke-WebRequest -Uri $Url -OutFile $OutFile
      if (!(Test-Path $OutFile) -or ((Get-Item $OutFile).Length -le 0)) {
        Fail "Downloaded empty portable file: $Name"
      }
    }
  }

  foreach ($Name in $PortableFiles) {
    Copy-Item -Force (Join-Path $TempDir $Name) (Join-Path $Root $Name)
  }

  Info "Installed 6 portable root files into $Root"

  if ($SkipBootstrap) {
    Info "Skipping bootstrap by request."
    exit 0
  }

  $Launcher = Join-Path $Root "portable-kernel-windows.ps1"
  if (!(Test-Path $Launcher)) {
    Fail "Missing Windows launcher: $Launcher"
  }

  $PowerShell = PowerShellExe

  Info "Running portable probe"
  & $PowerShell -ExecutionPolicy Bypass -File $Launcher probe -Root $Root

  $BootstrapArgs = @("bootstrap", "-Root", $Root, "-Tier", $Tier, "-NonInteractive", "-Trigger", "manual")
  if ($Language -ne "") {
    $BootstrapArgs += @("-Language", $Language)
  }

  Info "Running portable bootstrap tier=$Tier"
  & $PowerShell -ExecutionPolicy Bypass -File $Launcher @BootstrapArgs

  Info "Running portable doctor"
  & $PowerShell -ExecutionPolicy Bypass -File $Launcher doctor -Root $Root
  Info "Antigravity Ultra install complete."
} finally {
  Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
}
