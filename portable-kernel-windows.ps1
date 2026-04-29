param(
  [Parameter(Position = 0)]
  [string]$Command = "help",
  [Parameter(Position = 1)]
  [string]$Subcommand = "",
  [string]$Root = $PSScriptRoot,
  [string]$Language = "",
  [string]$Tier = "",
  [string]$CustomFeatures = "",
  [string]$Features = "",
  [string]$Source = "default",
  [string]$Trigger = "",
  [string]$Summary = "",
  [switch]$Json,
  [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
$PortableBundleMarker = "portable:minimum-kernel.bundle.tar.gz.base64"
$ProfileMarkerStart = "<!-- PORTABLE_KERNEL_PROFILE_START -->"
$ProfileMarkerEnd = "<!-- PORTABLE_KERNEL_PROFILE_END -->"

function Write-Info {
  param([string]$Message)
  Write-Output "INFO: $Message"
}

function Write-ErrorLine {
  param([string]$Message)
  [Console]::Error.WriteLine("ERROR: $Message")
}

function Get-InstallStatePath {
  param([string]$BaseRoot)
  Join-Path (Join-Path $BaseRoot ".kernel") "install_state.json"
}

function Get-PlatformName {
  if ($IsWindows -or $PSVersionTable.PSEdition -eq "Desktop") {
    return "windows"
  }
  if ($IsMacOS) {
    return "macos"
  }
  if ($IsLinux) {
    return "linux"
  }
  return "windows"
}

function Get-ShellFamily {
  param([string]$Platform)
  if ($Platform -eq "windows") {
    return "powershell"
  }
  return "bash"
}

function Get-Launcher {
  param([string]$Platform)
  if ($Platform -eq "windows") {
    return "portable-kernel-windows.ps1"
  }
  return "portable-kernel.sh"
}

function Get-ProfileValue {
  param([string]$BaseRoot, [string]$Key)
  $gemini = Join-Path $BaseRoot "GEMINI.md"
  if (!(Test-Path $gemini)) {
    return ""
  }
  $capture = $false
  foreach ($line in [System.IO.File]::ReadLines($gemini)) {
    if ($line -eq $ProfileMarkerStart) {
      $capture = $true
      continue
    }
    if ($line -eq $ProfileMarkerEnd) {
      break
    }
    if ($capture -and $line -match ("^" + [regex]::Escape($Key) + ":\s*(.*)$")) {
      return $Matches[1].Trim()
    }
  }
  return ""
}

function Get-Profile {
  param([string]$BaseRoot)
  $profile = Get-ProfileValue -BaseRoot $BaseRoot -Key "portable_profile"
  if ([string]::IsNullOrWhiteSpace($profile)) {
    return "source_forced_es"
  }
  return $profile
}

function Get-DefaultLanguage {
  param([string]$Profile)
  if ($Profile -eq "portable_ask_default_en") {
    return "English"
  }
  return "Español"
}

function Normalize-Tier {
  param([string]$InstallTier)
  if ([string]::IsNullOrWhiteSpace($InstallTier)) {
    return "recommended"
  }
  if (@("minimal", "recommended", "complete", "custom") -notcontains $InstallTier) {
    throw "Unknown install tier: $InstallTier"
  }
  return $InstallTier
}

function Get-FeatureDefaults {
  param([string]$InstallTier)
  $tierValue = Normalize-Tier -InstallTier $InstallTier
  $features = [ordered]@{
    live_state = $true
    project_state_cache = $true
    memory_vault = $true
    project_ledgers = $true
    core_tests = $false
    full_evals = $false
    audit_tooling = $true
    mcp_templates = $false
    advanced_workflows = $true
    strict_plan_gate = $true
    telemetry_tooling = $false
  }
  if ($tierValue -eq "minimal") {
    $features.memory_vault = $false
    $features.project_ledgers = $false
    $features.audit_tooling = $false
    $features.mcp_templates = $false
    $features.advanced_workflows = $false
    $features.strict_plan_gate = $false
  }
  if ($tierValue -eq "complete") {
    $features.full_evals = $false
    $features.telemetry_tooling = $true
  }
  return $features
}

function Apply-CustomFeatures {
  param([hashtable]$FeatureMap, [string]$FeatureCsv)
  if ([string]::IsNullOrWhiteSpace($FeatureCsv)) {
    return $FeatureMap
  }
  foreach ($entry in $FeatureCsv.Split(",")) {
    if ([string]::IsNullOrWhiteSpace($entry)) {
      continue
    }
    $parts = $entry.Split("=", 2)
    if ($parts.Count -ne 2) {
      throw "custom feature entries must use key=value"
    }
    $key = $parts[0].Trim()
    $value = $parts[1].Trim().ToLowerInvariant()
    if (@("true", "yes", "si", "sí") -contains $value) {
      $FeatureMap[$key] = $true
    } elseif (@("false", "no") -contains $value) {
      $FeatureMap[$key] = $false
    } else {
      throw "custom feature values must be true/false"
    }
  }
  $FeatureMap.live_state = $true
  $FeatureMap.project_state_cache = $true
  return $FeatureMap
}

function Read-JsonFile {
  param([string]$Path)
  if (!(Test-Path $Path)) {
    return $null
  }
  return Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json
}

function Get-KernelFeatures {
  param([string]$BaseRoot)
  $state = Read-JsonFile -Path (Get-InstallStatePath -BaseRoot $BaseRoot)
  if ($null -ne $state -and $null -ne $state.features) {
    $features = [ordered]@{}
    foreach ($property in $state.features.PSObject.Properties) {
      $features[$property.Name] = $property.Value
    }
    $features.live_state = $true
    $features.project_state_cache = $true
    return $features
  }
  return Get-FeatureDefaults -InstallTier "recommended"
}

function Get-KernelFeatureValue {
  param([string]$BaseRoot, [string]$FeatureName)
  $features = Get-KernelFeatures -BaseRoot $BaseRoot
  if ($features.Contains($FeatureName)) {
    return [bool]$features[$FeatureName]
  }
  return $false
}

function Write-JsonAtomic {
  param([string]$Path, [object]$Value)
  $dir = Split-Path -Parent $Path
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "portable-install-state-$([guid]::NewGuid()).json")
  $Value | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -NoNewline $tmp
  Move-Item -Force $tmp $Path
}

function Ensure-InstallState {
  param([string]$BaseRoot, [string]$Profile, [string]$InstallTier)
  $path = Get-InstallStatePath -BaseRoot $BaseRoot
  if (Test-Path $path) {
    return
  }
  $tierValue = Normalize-Tier -InstallTier $InstallTier
  $platform = Get-PlatformName
  $state = [ordered]@{
    portable_profile = $Profile
    portable_version = 1
    onboarding_status = "completed"
    preferred_chat_language = Get-DefaultLanguage -Profile $Profile
    language_source = "forced"
    install_tier = $tierValue
    feature_profile = $tierValue
    features = Get-FeatureDefaults -InstallTier $tierValue
    platform = $platform
    shell_family = Get-ShellFamily -Platform $platform
    launcher_used = Get-Launcher -Platform $platform
    bootstrap_trigger = $null
    first_user_intent_summary = $null
    first_user_intent_captured_at = $null
    restore_status = "restored"
    last_prompted_at = $null
  }
  if ($Profile -eq "portable_ask_default_en") {
    $state.onboarding_status = "pending_language"
    $state.language_source = "default"
    $state.restore_status = "not_started"
  }
  Write-JsonAtomic -Path $path -Value $state
}

function Extract-Marker {
  param([string]$SourceFile, [string]$MarkerName, [string]$TargetFile)
  $begin = "<!-- BEGIN: $MarkerName -->"
  $end = "<!-- END: $MarkerName -->"
  $capture = $false
  $lines = New-Object System.Collections.Generic.List[string]
  foreach ($line in [System.IO.File]::ReadLines($SourceFile)) {
    if ($line -eq $begin) {
      $capture = $true
      continue
    }
    if ($line -eq $end) {
      break
    }
    if ($capture) {
      [void]$lines.Add($line)
    }
  }
  [System.IO.File]::WriteAllLines($TargetFile, $lines, [System.Text.Encoding]::UTF8)
}

function Get-PortableBundleArchive {
  param([string]$BaseRoot)
  $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "portable-kernel-bundle-$([guid]::NewGuid())"
  New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
  $bundleB64 = Join-Path $tmpDir "bundle.b64"
  $bundleTgz = Join-Path $tmpDir "bundle.tar.gz"
  Extract-Marker -SourceFile (Join-Path $BaseRoot "GEMINI_BLUEPRINTS.md") -MarkerName $PortableBundleMarker -TargetFile $bundleB64
  if ((!(Test-Path $bundleB64)) -or ((Get-Item $bundleB64).Length -eq 0)) {
    throw "Portable bundle marker not found in GEMINI_BLUEPRINTS.md"
  }
  $raw = (Get-Content -Raw -Encoding UTF8 $bundleB64) -replace "\s", ""
  [System.IO.File]::WriteAllBytes($bundleTgz, [Convert]::FromBase64String($raw))
  return $bundleTgz
}

function Expand-PortableBundle {
  param([string]$BaseRoot)
  $bundleTgz = Get-PortableBundleArchive -BaseRoot $BaseRoot
  & tar -xzf $bundleTgz -C $BaseRoot
  if ($LASTEXITCODE -ne 0) {
    throw "tar failed while expanding portable bundle"
  }
  Remove-Item -Recurse -Force (Split-Path -Parent $bundleTgz)
}

function Extract-BundleManifest {
  param([string]$BaseRoot)
  $bundleTgz = Get-PortableBundleArchive -BaseRoot $BaseRoot
  $tmpDir = Split-Path -Parent $bundleTgz
  & tar -xzf $bundleTgz -C $tmpDir "./.portable/bundle_manifest.json" | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Portable bundle manifest is missing"
  }
  $manifest = Get-Content -Raw -Encoding UTF8 (Join-Path $tmpDir ".portable/bundle_manifest.json") | ConvertFrom-Json
  Remove-Item -Recurse -Force $tmpDir
  return $manifest
}

function Seed-TemplatesIfMissing {
  param([string]$BaseRoot)
  foreach ($name in @("PROJECT_HISTORY.md", "ERROR_LOG.md", "AGENTS.md")) {
    $target = Join-Path $BaseRoot $name
    if (!(Test-Path $target)) {
      Extract-Marker -SourceFile (Join-Path $BaseRoot "GEMINI_BLUEPRINTS.md") -MarkerName $name -TargetFile $target
    }
  }
}

function Seed-KnowledgeBaseline {
  param([string]$BaseRoot)
  $vault = Join-Path (Join-Path $BaseRoot ".agent") "knowledge"
  foreach ($dir in @("architecture", "incidents", "ecosystem", "research", "context")) {
    New-Item -ItemType Directory -Force -Path (Join-Path $vault $dir) | Out-Null
  }
  if (Get-KernelFeatureValue -BaseRoot $BaseRoot -FeatureName "telemetry_tooling") {
    New-Item -ItemType Directory -Force -Path (Join-Path $vault "inbox") | Out-Null
  }
  $dna = Join-Path $vault ".project_dna.md"
  if (!(Test-Path $dna)) {
    @"
# Project DNA

- Portable kernel workspace restored from the first-message bootstrap flow.
- Keep this digest short and refresh it only when durable project shape changes.
"@ | Set-Content -Encoding UTF8 $dna
  }
}

function Seed-CurrentState {
  param([string]$BaseRoot)
  $jsonFile = Join-Path (Join-Path $BaseRoot ".agent") "current_state.json"
  $mdFile = Join-Path (Join-Path $BaseRoot ".agent") "current_state.md"
  if (Test-Path $jsonFile) {
    return
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $jsonFile) | Out-Null
  $state = Read-JsonFile -Path (Get-InstallStatePath -BaseRoot $BaseRoot)
  $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $project = Split-Path -Leaf $BaseRoot
  $intentSummary = ""
  if ($null -ne $state.PSObject.Properties["first_user_intent_summary"] -and $null -ne $state.first_user_intent_summary) {
    $intentSummary = [string]$state.first_user_intent_summary
  }
  $nextStep = "Usar el sistema restaurado normalmente o retomar la solicitud original del primer mensaje."
  if (![string]::IsNullOrWhiteSpace($intentSummary)) {
    $nextStep = "Retomar: $intentSummary"
  }
  $frontmatter = [ordered]@{
    schema_version = 1
    project = $project
    updated_at = $now
    objective = "Restaurar y operar el kernel portable minimo en este workspace."
    last_completed_task = @("Bootstrap inicial del kernel portable ejecutado correctamente.")
    status = "scaffold"
    blockers = @()
    active_files = @("GEMINI.md", "MEMORY.md", "GEMINI_BLUEPRINTS.md", "portable-kernel.sh", "portable-kernel-windows.ps1")
    resume_commands = @("powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 doctor", "powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 contents")
    next_step = $nextStep
    verification_status = "pending"
    freshness_state = "fresh"
    kernel_install = [ordered]@{
      language = $state.preferred_chat_language
      install_tier = $state.install_tier
      platform = $state.platform
      launcher_used = $state.launcher_used
      first_user_intent_summary = $(if ([string]::IsNullOrWhiteSpace($intentSummary)) { $null } else { $intentSummary })
      features = $state.features
    }
    plan_state = [ordered]@{
      required = $false
      source = "none"
      status = "not_required"
      updated_at = $null
      content_hash = $null
      memory_synced = $false
      next_action = $null
      producer_agent = $null
      receipt_ref = $null
    }
  }
  $feature = $state.features
  Write-JsonAtomic -Path $jsonFile -Value $frontmatter
  @"
# Current State

## Current Objective
- Restaurar y operar el kernel portable minimo en este workspace.

## Last Completed Task
- Bootstrap inicial del kernel portable ejecutado correctamente.

## Blockers
- Ninguno bloqueante.

## Active Files
- `GEMINI.md`
- `MEMORY.md`
- `GEMINI_BLUEPRINTS.md`
- `portable-kernel.sh`
- `portable-kernel-windows.ps1`

## Active Kernel Features
- platform: $($state.platform)
- launcher_used: $($state.launcher_used)
- install_tier: $($state.install_tier)
- language: $($state.preferred_chat_language)
- memory_vault: $($feature.memory_vault)
- core_tests: $($feature.core_tests)
- audit_tooling: $($feature.audit_tooling)
- mcp_templates: $($feature.mcp_templates)
- telemetry_tooling: $($feature.telemetry_tooling)

## Next Step
- $nextStep

## Verification Status
- `pending`

## Freshness
- Generado por `portable-kernel-windows.ps1 bootstrap`.
"@ | Set-Content -Encoding UTF8 $mdFile
}

function Read-CurrentStateMeta {
  param([string]$BaseRoot)
  $jsonPath = Join-Path (Join-Path $BaseRoot ".agent") "current_state.json"
  $mdPath = Join-Path (Join-Path $BaseRoot ".agent") "current_state.md"
  if (Test-Path $jsonPath) {
    $meta = Read-JsonFile -Path $jsonPath
    if ($null -eq $meta.plan_state) {
      throw "current_state json missing plan_state"
    }
    return $meta
  }
  if (!(Test-Path $mdPath)) {
    throw "Missing .agent/current_state.json"
  }
  $lines = Get-Content -Encoding UTF8 $mdPath
  if ($lines.Count -lt 3 -or $lines[0].Trim() -ne "---") {
    throw "Missing .agent/current_state.json"
  }
  $end = -1
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq "---") {
      $end = $i
      break
    }
  }
  if ($end -lt 0) {
    throw ".agent/current_state.md legacy frontmatter is not closed"
  }
  $json = ($lines[1..($end - 1)] -join "`n")
  $meta = $json | ConvertFrom-Json
  if ($null -eq $meta.plan_state) {
    throw "current_state legacy frontmatter missing plan_state"
  }
  Write-JsonAtomic -Path $jsonPath -Value $meta
  return $meta
}

function Write-ProjectStateFromCurrent {
  param([string]$BaseRoot)
  $meta = Read-CurrentStateMeta -BaseRoot $BaseRoot
  $file = Join-Path (Join-Path $BaseRoot ".agent") "project_state.json"
  $lastTask = if ($meta.last_completed_task.Count -gt 0) { $meta.last_completed_task[0] } else { $meta.objective }
  $state = [ordered]@{
    version = 1
    generated_from = ".agent/current_state.json"
    generated_by = "portable-kernel-windows.ps1"
    do_not_edit = $true
    project = $meta.project
    updated_at = $meta.updated_at
    current_objective = $meta.objective
    current_task = $lastTask
    status = $meta.status
    blockers = $meta.blockers
    active_files = $meta.active_files
    next_steps = @($meta.next_step)
    key_commands = $meta.resume_commands
    notes = @()
    memory_refs = @()
    current_session = [ordered]@{
      objective = $meta.objective
      last_completed_task = ($meta.last_completed_task -join "; ")
      blockers = $meta.blockers
      active_files = $meta.active_files
      resume_commands = $meta.resume_commands
      resume_brief = "$lastTask Siguiente paso: $($meta.next_step)"
      next_step = $meta.next_step
      verification_status = $meta.verification_status
      last_snapshot_at = $meta.updated_at
      freshness_state = $meta.freshness_state
      plan_state = $meta.plan_state
    }
  }
  if ($null -ne $meta.kernel_install) {
    $state.kernel_install = $meta.kernel_install
    $state.current_session.kernel_install = $meta.kernel_install
  }
  Write-JsonAtomic -Path $file -Value $state
}

function Seed-ProjectState {
  param([string]$BaseRoot)
  $file = Join-Path (Join-Path $BaseRoot ".agent") "project_state.json"
  $current = Join-Path (Join-Path $BaseRoot ".agent") "current_state.json"
  if (Test-Path $current) {
    Write-ProjectStateFromCurrent -BaseRoot $BaseRoot
    return
  }
  if (Test-Path $file) {
    return
  }
  $state = Read-JsonFile -Path (Get-InstallStatePath -BaseRoot $BaseRoot)
  $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $project = Split-Path -Leaf $BaseRoot
  $projectState = [ordered]@{
    version = 1
    project = $project
    updated_at = $now
    current_objective = "Operar el kernel portable restaurado en este workspace."
    current_task = "Bootstrap inicial completado por portable-kernel-windows.ps1."
    status = "scaffold"
    blockers = @()
    active_files = @("GEMINI.md", "MEMORY.md", "GEMINI_BLUEPRINTS.md", "portable-kernel.sh", "portable-kernel-windows.ps1")
    next_steps = @("Retomar la solicitud original del primer mensaje.")
    key_commands = @("powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 doctor")
    notes = @("Cache regenerable creado durante bootstrap portable de Windows.")
    memory_refs = @()
    kernel_install = [ordered]@{
      language = $state.preferred_chat_language
      install_tier = $state.install_tier
      platform = $state.platform
      launcher_used = $state.launcher_used
      features = $state.features
    }
    current_session = [ordered]@{
      objective = "Operar el kernel portable restaurado en este workspace."
      last_completed_task = "Bootstrap inicial completado."
      blockers = @()
      active_files = @("GEMINI.md", "MEMORY.md", "GEMINI_BLUEPRINTS.md", "portable-kernel.sh", "portable-kernel-windows.ps1")
      resume_commands = @("powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 doctor")
      resume_brief = "Kernel portable restaurado. El siguiente paso es retomar la solicitud original."
      next_step = "Retomar la solicitud original del primer mensaje."
      verification_status = "pending"
      last_snapshot_at = $now
      freshness_state = "fresh"
      kernel_install = [ordered]@{
        language = $state.preferred_chat_language
        install_tier = $state.install_tier
        platform = $state.platform
        launcher_used = $state.launcher_used
        features = $state.features
      }
      plan_state = [ordered]@{
        required = $false
        source = "none"
        status = "not_required"
        updated_at = $null
        content_hash = $null
        memory_synced = $false
        next_action = $null
        producer_agent = $null
        receipt_ref = $null
      }
    }
  }
  Write-JsonAtomic -Path $file -Value $projectState
}

function Command-Probe {
  $platform = Get-PlatformName
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  $installStatePresent = $null -ne $state
  $onboarding = "not_started"
  $restore = "not_started"
  if ($installStatePresent) {
    $onboarding = $state.onboarding_status
    $restore = $state.restore_status
  }
  $portableFilesPresent = (Test-Path (Join-Path $Root "GEMINI.md")) -and
    (Test-Path (Join-Path $Root "MEMORY.md")) -and
    (Test-Path (Join-Path $Root "GEMINI_BLUEPRINTS.md")) -and
    (Test-Path (Join-Path $Root "portable-kernel.sh")) -and
    (Test-Path (Join-Path $Root "portable-kernel-windows.ps1"))
  $requires = !(($onboarding -in @("completed", "restored")) -and $restore -eq "restored")
  $probe = [ordered]@{
    schema_version = 1
    platform = $platform
    shell_family = Get-ShellFamily -Platform $platform
    root = $Root
    portable_files_present = [bool]$portableFilesPresent
    install_state_present = [bool]$installStatePresent
    onboarding_status = $onboarding
    restore_status = $restore
    recommended_launcher = Get-Launcher -Platform $platform
    requires_onboarding = [bool]$requires
    safe_to_bootstrap = [bool]$portableFilesPresent
  }
  if ($Json) {
    $probe | ConvertTo-Json -Depth 10
  } else {
    Write-Info "platform=$($probe.platform) launcher=$($probe.recommended_launcher) requires_onboarding=$($probe.requires_onboarding)"
  }
}

function Command-Bootstrap {
  $profile = Get-Profile -BaseRoot $Root
  $tierValue = if ([string]::IsNullOrWhiteSpace($Tier)) { "recommended" } else { Normalize-Tier -InstallTier $Tier }
  Ensure-InstallState -BaseRoot $Root -Profile $profile -InstallTier $tierValue
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  $featureCsv = if ([string]::IsNullOrWhiteSpace($CustomFeatures)) { $Features } else { $CustomFeatures }
  $featureDefaults = Get-FeatureDefaults -InstallTier $tierValue
  $featureMap = Apply-CustomFeatures -FeatureMap $featureDefaults -FeatureCsv $featureCsv
  $platform = Get-PlatformName
  $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  if ([string]::IsNullOrWhiteSpace($Language)) {
    $Language = $state.preferred_chat_language
  }
  if ([string]::IsNullOrWhiteSpace($Language)) {
    $Language = Get-DefaultLanguage -Profile $profile
  }
  if ([string]::IsNullOrWhiteSpace($Trigger)) {
    $Trigger = "first_chat"
  }
  $state.portable_profile = $profile
  $state.portable_version = 1
  $state.preferred_chat_language = $Language
  $state.language_source = if ($state.language_source -eq "custom") { "custom" } else { "preset" }
  $state.install_tier = $tierValue
  $state.feature_profile = $tierValue
  $state.features = $featureMap
  $state.platform = $platform
  $state.shell_family = Get-ShellFamily -Platform $platform
  $state.launcher_used = Get-Launcher -Platform $platform
  $state.bootstrap_trigger = $Trigger
  $state.last_prompted_at = $now
  Write-JsonAtomic -Path $statePath -Value $state

  Expand-PortableBundle -BaseRoot $Root
  if ($featureMap.project_ledgers) {
    Seed-TemplatesIfMissing -BaseRoot $Root
  }
  Seed-CurrentState -BaseRoot $Root
  Seed-ProjectState -BaseRoot $Root
  if ($featureMap.memory_vault) {
    Seed-KnowledgeBaseline -BaseRoot $Root
  }
  New-Item -ItemType Directory -Force -Path (Join-Path (Join-Path $Root "state") "traces") | Out-Null
  $trace = Join-Path (Join-Path (Join-Path $Root "state") "traces") "portable-bootstrap.jsonl"
  if (!(Test-Path $trace)) {
    New-Item -ItemType File -Path $trace | Out-Null
  }
  $state = Read-JsonFile -Path $statePath
  $state.onboarding_status = "completed"
  $state.restore_status = "restored"
  $state.last_prompted_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Write-JsonAtomic -Path $statePath -Value $state
  Write-Info "Portable kernel restored in $Root"
  Command-Doctor
}

function Command-SetLanguage {
  $profile = "portable_ask_default_en"
  Ensure-InstallState -BaseRoot $Root -Profile $profile -InstallTier "recommended"
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  if ([string]::IsNullOrWhiteSpace($Language)) {
    $Language = "English"
    $Source = "default"
  }
  $state.portable_profile = $profile
  $state.preferred_chat_language = $Language
  $state.language_source = $Source
  $state.onboarding_status = if ($state.restore_status -eq "restored") { "completed" } else { "pending_restore" }
  $state.last_prompted_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Write-JsonAtomic -Path $statePath -Value $state
  Write-Info "Preferred chat language persisted as $Language"
}

function Command-SetTier {
  $tierValue = Normalize-Tier -InstallTier $Tier
  Ensure-InstallState -BaseRoot $Root -Profile "portable_ask_default_en" -InstallTier $tierValue
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  $state.install_tier = $tierValue
  $state.feature_profile = $tierValue
  $state.features = Get-FeatureDefaults -InstallTier $tierValue
  $state.last_prompted_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Write-JsonAtomic -Path $statePath -Value $state
  Write-Info "Portable install tier persisted as $tierValue"
}

function Command-ConfigureFeatures {
  $featureCsv = if ([string]::IsNullOrWhiteSpace($Features)) { $CustomFeatures } else { $Features }
  if ([string]::IsNullOrWhiteSpace($featureCsv)) {
    throw "configure-features requires -Features k=v,..."
  }
  Ensure-InstallState -BaseRoot $Root -Profile "portable_ask_default_en" -InstallTier "custom"
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  $featureMap = @{}
  foreach ($property in $state.features.PSObject.Properties) {
    $featureMap[$property.Name] = $property.Value
  }
  $state.install_tier = "custom"
  $state.feature_profile = "custom"
  $state.features = Apply-CustomFeatures -FeatureMap $featureMap -FeatureCsv $featureCsv
  $state.last_prompted_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Write-JsonAtomic -Path $statePath -Value $state
  Write-Info "Portable feature flags updated"
}

function Command-RememberIntent {
  if ([string]::IsNullOrWhiteSpace($Summary)) {
    throw "remember-intent requires -Summary"
  }
  if ($Summary.Length -gt 240) {
    throw "remember-intent summary must be 240 characters or fewer"
  }
  Ensure-InstallState -BaseRoot $Root -Profile "portable_ask_default_en" -InstallTier "recommended"
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $state | Add-Member -NotePropertyName "first_user_intent_summary" -NotePropertyValue $Summary -Force
  $state | Add-Member -NotePropertyName "first_user_intent_captured_at" -NotePropertyValue $now -Force
  $state.last_prompted_at = $now
  Write-JsonAtomic -Path $statePath -Value $state
  Write-Info "First-message intent summary persisted"
}

function Command-Contents {
  $manifest = Extract-BundleManifest -BaseRoot $Root
  Write-Output "Portable kernel install contents:"
  Write-Output ""
  Write-Output "First-message bootstrap:"
  Write-Output "- Copy the 5 root files, open Antigravity, send any first message, persist a compact intent summary with remember-intent, then bootstrap."
  Write-Output "- Windows launcher: portable-kernel-windows.ps1"
  Write-Output "- macOS/Linux launcher: portable-kernel.sh"
  Write-Output ""
  Write-Output "Install profiles:"
  Write-Output "- recommended: memory, audits, and advanced workflows enabled; MCP and tests are user-local/source-only."
  Write-Output "- minimal: live state and cache only; memory vault, ledgers, MCP templates, tests, and telemetry off."
  Write-Output "- complete: full runtime tooling enabled; MCP and tests remain source-repo/user-local only."
  Write-Output "- custom"
  Write-Output ""
  Write-Output "Security notes:"
  Write-Output "- No MCP runtime template is included."
  Write-Output "- Tests/evals are source-repo only and are not installed by the portable bundle."
  Write-Output ""
  Write-Output "Categories:"
  foreach ($category in $manifest.categories) {
    Write-Output "- $($category.category): $($category.count) artifact(s)"
  }
}

function Command-Doctor {
  $errors = 0
  foreach ($name in @("GEMINI.md", "MEMORY.md", "GEMINI_BLUEPRINTS.md", "portable-kernel.sh", "portable-kernel-windows.ps1")) {
    if (!(Test-Path (Join-Path $Root $name))) {
      Write-ErrorLine "Missing required portable file: $name"
      $errors += 1
    }
  }
  $statePath = Get-InstallStatePath -BaseRoot $Root
  $state = Read-JsonFile -Path $statePath
  if ($null -ne $state -and $state.restore_status -eq "restored") {
    foreach ($name in @(".agent/current_state.json", ".agent/current_state.md", ".agent/project_state.json")) {
      if (!(Test-Path (Join-Path $Root $name))) {
        Write-ErrorLine "Missing restored file: $name"
        $errors += 1
      }
    }
    if ($state.features.project_ledgers) {
      foreach ($name in @("PROJECT_HISTORY.md", "ERROR_LOG.md", "AGENTS.md")) {
        if (!(Test-Path (Join-Path $Root $name))) {
          Write-ErrorLine "Missing restored file: $name"
          $errors += 1
        }
      }
    }
    if ($state.features.memory_vault) {
      if (!(Test-Path (Join-Path $Root ".agent/knowledge/.project_dna.md"))) {
        Write-ErrorLine "Missing restored Project DNA"
        $errors += 1
      }
    }
    foreach ($name in @("antigravity/mcp_config.json", "evals", "skills-lock.json", "skills-manifest.json", "reports/skills-curation-report.json", "scripts/run-core-evals.sh", "scripts/gemini-doctor.sh", "scripts/__pycache__")) {
      if (Test-Path (Join-Path $Root $name)) {
        Write-ErrorLine "Portable restore included source-only artifact: $name"
        $errors += 1
      }
    }
    $sourceOnlyScripts = Get-ChildItem -Path (Join-Path $Root "scripts") -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "check-*" -or $_.Name -like "evaluate-*" }
    if ($sourceOnlyScripts.Count -gt 0) {
      Write-ErrorLine "Portable restore included source-only check/evaluate scripts."
      $errors += 1
    }
  }
  if ($errors -gt 0) {
    Write-Output "SUMMARY: $errors error(s)"
    exit 1
  }
  Write-Output "SUMMARY: 0 error(s)"
}

function Command-Regen {
  Write-Info "PowerShell regen is a portable no-op. Source regeneration is performed by the canonical maintainer workspace."
}

function Command-FeatureEnabled {
  if ([string]::IsNullOrWhiteSpace($Subcommand)) {
    throw "feature-enabled requires a feature name"
  }
  $enabled = Get-KernelFeatureValue -BaseRoot $Root -FeatureName $Subcommand
  if ($Json) {
    [ordered]@{
      schema_version = 1
      root = $Root
      feature = $Subcommand
      enabled = [bool]$enabled
    } | ConvertTo-Json -Depth 5
  } else {
    if ($enabled) {
      Write-Output "true"
    } else {
      Write-Output "false"
    }
  }
  if (-not $enabled) {
    exit 1
  }
}

function Command-StateCtl {
  if ([string]::IsNullOrWhiteSpace($Subcommand)) {
    throw "statectl requires check or regen-cache"
  }
  if ($Subcommand -eq "regen-cache") {
    Write-ProjectStateFromCurrent -BaseRoot $Root
    Write-Output "STATECTL_CACHE_REGENERATED"
    return
  }
  if ($Subcommand -eq "check" -or $Subcommand -eq "assert-sync") {
    $meta = Read-CurrentStateMeta -BaseRoot $Root
    $cachePath = Join-Path (Join-Path $Root ".agent") "project_state.json"
    $cache = Read-JsonFile -Path $cachePath
    if ($null -eq $cache) {
      throw "Missing .agent/project_state.json"
    }
    if ($cache.current_objective -ne $meta.objective) {
      throw ".agent/project_state.json drifted from .agent/current_state.json"
    }
    if ($cache.current_session.plan_state.status -ne $meta.plan_state.status) {
      throw ".agent/project_state.json plan_state drifted from .agent/current_state.json"
    }
    if ($cache.do_not_edit -ne $true) {
      throw ".agent/project_state.json missing do_not_edit cache marker"
    }
    Write-Output "STATECTL_OK"
    return
  }
  throw "Unsupported statectl subcommand: $Subcommand"
}

switch ($Command) {
  "probe" { Command-Probe }
  "bootstrap" { Command-Bootstrap }
  "doctor" { Command-Doctor }
  "contents" { Command-Contents }
  "feature-enabled" { Command-FeatureEnabled }
  "statectl" { Command-StateCtl }
  "set-language" { Command-SetLanguage }
  "set-tier" { Command-SetTier }
  "configure-features" { Command-ConfigureFeatures }
  "remember-intent" { Command-RememberIntent }
  "regen" { Command-Regen }
  "help" {
    Write-Output "Usage:"
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 probe -Json"
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Language Español -Tier recommended -NonInteractive"
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 remember-intent -Summary `"Crear app de tareas`""
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 feature-enabled memory_vault"
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 statectl check"
    Write-Output "  powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 doctor"
  }
  default {
    throw "Unknown command: $Command"
  }
}
