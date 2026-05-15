#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$SCRIPT_DIR"
PROFILE_MARKER_START="<!-- PORTABLE_KERNEL_PROFILE_START -->"
PROFILE_MARKER_END="<!-- PORTABLE_KERNEL_PROFILE_END -->"

usage() {
  cat <<'EOF'
Usage:
  bash portable-kernel.sh probe [--root PATH] [--json]
  bash portable-kernel.sh bootstrap [--root PATH] [--language VALUE] [--tier minimal|recommended|complete|custom] [--custom-features k=v,...] [--non-interactive] [--trigger first_chat|manual|test]
  bash portable-kernel.sh recover [--root PATH] [--project-root PATH] [--output PATH] [--force] [--list] [artifact_id|relative/path|all]
  bash portable-kernel.sh doctor [--root PATH]
  bash portable-kernel.sh regen [--root PATH]
  bash portable-kernel.sh pack [--root PATH] [--output DIR]
  bash portable-kernel.sh contents [--root PATH]
  bash portable-kernel.sh remember-intent [--root PATH] --summary TEXT

Internal onboarding helpers:
  bash portable-kernel.sh set-language [--root PATH] --language VALUE --source preset|custom|default
  bash portable-kernel.sh set-tier [--root PATH] --tier minimal|recommended|complete|custom
  bash portable-kernel.sh configure-features [--root PATH] --features k=v,...
  bash portable-kernel.sh defer [--root PATH]
EOF
}

emit_info() {
  printf 'INFO: %s\n' "$1"
}

emit_error() {
  printf 'ERROR: %s\n' "$1" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    emit_error "Missing required command: $1"
    exit 1
  }
}

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

extract_marker() {
  local source_file="$1"
  local marker_name="$2"
  local target_file="$3"
  awk -v begin="<!-- BEGIN: ${marker_name} -->" -v end="<!-- END: ${marker_name} -->" '
    $0 == begin { capture = 1; next }
    $0 == end { capture = 0; exit }
    capture { print }
  ' "$source_file" > "$target_file"
}

profile_value() {
  local root="$1"
  local key="$2"
  awk -v begin="$PROFILE_MARKER_START" -v end="$PROFILE_MARKER_END" -v key="$key" '
    $0 == begin { capture = 1; next }
    $0 == end { capture = 0; exit }
    capture && $1 == key ":" {
      $1 = ""
      sub(/^ /, "")
      print
      exit
    }
  ' "$root/GEMINI.md"
}

read_profile() {
  local root="$1"
  local value
  value="$(profile_value "$root" "portable_profile" || true)"
  if [[ -z "$value" ]]; then
    printf 'source_forced_es\n'
  else
    printf '%s\n' "$value"
  fi
}

default_language_for_profile() {
  local profile="$1"
  if [[ "$profile" == "portable_ask_default_en" ]]; then
    printf 'English\n'
  else
    printf 'Español\n'
  fi
}

install_state_path() {
  local root="$1"
  printf '%s/.kernel/install_state.json\n' "$root"
}

detect_platform() {
  local kernel
  kernel="$(uname -s 2>/dev/null || printf unknown)"
  case "$kernel" in
    Darwin)
      printf 'macos\n'
      ;;
    Linux)
      if rg -qi 'microsoft|wsl' /proc/version 2>/dev/null; then
        printf 'linux-wsl\n'
      else
        printf 'linux\n'
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      printf 'windows\n'
      ;;
    *)
      printf 'unknown\n'
      ;;
  esac
}

shell_family_for_platform() {
  local platform="$1"
  case "$platform" in
    windows)
      printf 'powershell\n'
      ;;
    *)
      printf 'bash\n'
      ;;
  esac
}

launcher_for_platform() {
  local platform="$1"
  case "$platform" in
    windows)
      printf 'portable-kernel-windows.ps1\n'
      ;;
    *)
      printf 'portable-kernel.sh\n'
      ;;
  esac
}

normalize_tier() {
  local tier="${1:-recommended}"
  case "$tier" in
    minimal|recommended|complete|custom)
      printf '%s\n' "$tier"
      ;;
    *)
      emit_error "Unknown install tier: $tier"
      exit 1
      ;;
  esac
}

feature_defaults_json() {
  local tier
  tier="$(normalize_tier "${1:-recommended}")"
  case "$tier" in
    minimal)
      cat <<'JSON'
{"live_state":true,"project_state_cache":true,"memory_vault":false,"project_ledgers":false,"core_tests":false,"full_evals":false,"audit_tooling":false,"mcp_templates":false,"advanced_workflows":false,"strict_plan_gate":false,"telemetry_tooling":false}
JSON
      ;;
    complete)
      cat <<'JSON'
{"live_state":true,"project_state_cache":true,"memory_vault":true,"project_ledgers":true,"core_tests":false,"full_evals":false,"audit_tooling":true,"mcp_templates":false,"advanced_workflows":true,"strict_plan_gate":true,"telemetry_tooling":true}
JSON
      ;;
    custom|recommended)
      cat <<'JSON'
{"live_state":true,"project_state_cache":true,"memory_vault":true,"project_ledgers":true,"core_tests":false,"full_evals":false,"audit_tooling":true,"mcp_templates":false,"advanced_workflows":true,"strict_plan_gate":true,"telemetry_tooling":false}
JSON
      ;;
  esac
}

apply_custom_features_filter() {
  local features_csv="$1"
  if [[ -z "$features_csv" ]]; then
    cat
    return 0
  fi
  jq --arg csv "$features_csv" '
    reduce ($csv | split(",")[] | select(length > 0) | split("=")) as $pair (.;
      if ($pair | length) != 2 then
        error("custom feature entries must use key=value")
      else
        .[$pair[0]] = (
          if ($pair[1] == "true" or $pair[1] == "yes" or $pair[1] == "sí" or $pair[1] == "si") then true
          elif ($pair[1] == "false" or $pair[1] == "no") then false
          else error("custom feature values must be true/false")
          end
        )
      end
    )
    | .live_state = true
    | .project_state_cache = true
    | .
  '
}

ensure_install_state() {
  local root="$1"
  local profile="${2:-$(read_profile "$root")}"
  local tier="${3:-recommended}"
  local version
  version="$(profile_value "$root" "portable_version" || true)"
  [[ -n "$version" ]] || version="1"

  mkdir -p "$root/.kernel"
  local state_file
  state_file="$(install_state_path "$root")"
  if [[ -f "$state_file" ]]; then
    return 0
  fi

  local default_language
  default_language="$(default_language_for_profile "$profile")"
  local onboarding_status="completed"
  local language_source="forced"
  local restore_status="restored"

  if [[ "$profile" == "portable_ask_default_en" ]]; then
    onboarding_status="pending_language"
    language_source="default"
    restore_status="not_started"
  fi

  tier="$(normalize_tier "$tier")"
  local platform shell_family launcher features
  platform="$(detect_platform)"
  shell_family="$(shell_family_for_platform "$platform")"
  launcher="$(launcher_for_platform "$platform")"
  features="$(feature_defaults_json "$tier")"

  cat > "$state_file" <<EOF
{
  "portable_profile": "$profile",
  "portable_version": $version,
  "onboarding_status": "$onboarding_status",
  "preferred_chat_language": "$default_language",
  "language_source": "$language_source",
  "install_tier": "$tier",
  "feature_profile": "$tier",
  "features": $features,
  "platform": "$platform",
  "shell_family": "$shell_family",
  "launcher_used": "$launcher",
  "bootstrap_trigger": null,
  "first_user_intent_summary": null,
  "first_user_intent_captured_at": null,
  "restore_status": "$restore_status",
  "last_prompted_at": null
}
EOF
}

update_install_state() {
  local root="$1"
  local jq_filter="$2"
  local state_file
  state_file="$(install_state_path "$root")"
  ensure_install_state "$root"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/portable-install-state.XXXXXX")"
  jq "$jq_filter" "$state_file" > "$tmp"
  mv "$tmp" "$state_file"
}

update_install_state_jq() {
  local root="$1"
  shift
  local state_file
  state_file="$(install_state_path "$root")"
  ensure_install_state "$root"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/portable-install-state.XXXXXX")"
  jq "$@" "$state_file" > "$tmp"
  mv "$tmp" "$state_file"
}

install_state_feature_value() {
  local root="$1"
  local key="$2"
  local state_file
  state_file="$(install_state_path "$root")"
  if [[ -f "$state_file" ]]; then
    jq -r --arg key "$key" '.features[$key] // false' "$state_file" 2>/dev/null || printf 'false\n'
  else
    printf 'false\n'
  fi
}

extract_portable_bundle_archive() {
  local root="$1"
  local tmp_dir
  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/portable-kernel-bundle.XXXXXX")"
  local bundle_tgz="$tmp_dir/bundle.tar.gz"
  local root_bundle="$root/minimum-kernel.bundle.tar.gz"
  local cache_bundle="$root/.portable/minimum-kernel.bundle.tar.gz"
  if [[ -s "$root_bundle" ]]; then
    cp "$root_bundle" "$bundle_tgz"
    mkdir -p "$(dirname "$cache_bundle")"
    cp "$root_bundle" "$cache_bundle"
    printf '%s\n' "$bundle_tgz"
    return 0
  fi
  if [[ -s "$cache_bundle" ]]; then
    cp "$cache_bundle" "$bundle_tgz"
    printf '%s\n' "$bundle_tgz"
    return 0
  fi
  emit_error "Portable bundle not found. Expected minimum-kernel.bundle.tar.gz in root or generated .portable/minimum-kernel.bundle.tar.gz cache."
  rm -rf "$tmp_dir"
  exit 1
}

extract_bundle_manifest_json() {
  local root="$1"
  local bundle_tgz
  bundle_tgz="$(extract_portable_bundle_archive "$root")"
  local tmp_dir
  tmp_dir="$(dirname "$bundle_tgz")"
  tar -xzf "$bundle_tgz" -C "$tmp_dir" ./.portable/bundle_manifest.json >/dev/null 2>&1 || {
    emit_error "Portable bundle manifest is missing"
    rm -rf "$tmp_dir"
    exit 1
  }
  cat "$tmp_dir/.portable/bundle_manifest.json"
  rm -rf "$tmp_dir"
}

seed_current_state() {
  local root="$1"
  local json_file="$root/.agent/current_state.json"
  local md_file="$root/.agent/current_state.md"
  [[ -f "$json_file" ]] && return 0
  mkdir -p "$root/.agent"
  local now
  now="$(now_utc)"
  local project_name
  project_name="$(basename "$root")"
  local state_file language tier platform launcher intent_summary next_step
  state_file="$(install_state_path "$root")"
  language="$(jq -r '.preferred_chat_language // "Español"' "$state_file" 2>/dev/null || printf 'Español')"
  tier="$(jq -r '.install_tier // "recommended"' "$state_file" 2>/dev/null || printf 'recommended')"
  platform="$(jq -r '.platform // "unknown"' "$state_file" 2>/dev/null || printf 'unknown')"
  launcher="$(jq -r '.launcher_used // "portable-kernel.sh"' "$state_file" 2>/dev/null || printf 'portable-kernel.sh')"
  intent_summary="$(jq -r '.first_user_intent_summary // empty' "$state_file" 2>/dev/null || true)"
  if [[ -n "$intent_summary" ]]; then
    next_step="Retomar: $intent_summary"
  else
    next_step="Usar el sistema restaurado normalmente o retomar la solicitud original del primer mensaje."
  fi
  local state_json
  state_json="$(jq -cn \
    --arg project "$project_name" \
    --arg now "$now" \
    --arg language "$language" \
    --arg tier "$tier" \
    --arg platform "$platform" \
    --arg launcher "$launcher" \
    --arg intent_summary "$intent_summary" \
    --arg next_step "$next_step" \
    --slurpfile state "$state_file" \
    '{
      schema_version: 1,
      project: $project,
      updated_at: $now,
      objective: "Restaurar y operar el kernel portable minimo en este workspace.",
      last_completed_task: ["Bootstrap inicial del kernel portable ejecutado correctamente."],
      status: "scaffold",
      blockers: [],
      active_files: ["GEMINI.md","MEMORY.md","GEMINI_BLUEPRINTS.md","portable-kernel.sh","portable-kernel-windows.ps1","minimum-kernel.bundle.tar.gz"],
      resume_commands: ["bash portable-kernel.sh doctor","bash portable-kernel.sh regen","bash portable-kernel.sh contents"],
      next_step: $next_step,
      verification_status: "pending",
      freshness_state: "fresh",
      kernel_install: {
        language: $language,
        install_tier: $tier,
        platform: $platform,
        launcher_used: $launcher,
        first_user_intent_summary: (if $intent_summary == "" then null else $intent_summary end),
        features: (($state[0].features // {}) + {live_state: true, project_state_cache: true})
      },
      plan_state: {
        required: false,
        source: "none",
        status: "not_required",
        updated_at: null,
        content_hash: null,
        memory_synced: false,
        next_action: null,
        producer_agent: null,
        receipt_ref: null
      }
    }')"
  local memory_vault core_tests audit_tooling mcp_templates telemetry_tooling
  memory_vault="$(install_state_feature_value "$root" "memory_vault")"
  core_tests="$(install_state_feature_value "$root" "core_tests")"
  audit_tooling="$(install_state_feature_value "$root" "audit_tooling")"
  mcp_templates="$(install_state_feature_value "$root" "mcp_templates")"
  telemetry_tooling="$(install_state_feature_value "$root" "telemetry_tooling")"
  printf '%s\n' "$state_json" > "$json_file"
  cat > "$md_file" <<EOF
# Current State

## Current Objective
- Restaurar y operar el kernel portable mínimo en este workspace.

## Last Completed Task
- Bootstrap inicial del kernel portable ejecutado correctamente.

## Blockers
- Ninguno bloqueante.

## Active Files
- GEMINI.md
- MEMORY.md
- GEMINI_BLUEPRINTS.md
- portable-kernel.sh
- portable-kernel-windows.ps1
- minimum-kernel.bundle.tar.gz

## Resume Commands
- bash portable-kernel.sh doctor
- bash portable-kernel.sh regen
- bash portable-kernel.sh contents

## Active Kernel Features
- platform: $platform
- launcher_used: $launcher
- install_tier: $tier
- language: $language
- memory_vault: $memory_vault
- core_tests: $core_tests
- audit_tooling: $audit_tooling
- mcp_templates: $mcp_templates
- telemetry_tooling: $telemetry_tooling

## Next Step
- $next_step

## Verification Status
- pending

## Freshness
- Generado por portable-kernel.sh bootstrap.
EOF
}

seed_project_state() {
  local root="$1"
  local file="$root/.agent/project_state.json"
  if [[ -f "$root/scripts/render-project-state-cache.sh" && -f "$root/.agent/current_state.json" ]]; then
    bash "$root/scripts/render-project-state-cache.sh" --root "$root" --write >/dev/null && return 0
  fi
  [[ -f "$file" ]] && return 0
  mkdir -p "$root/.agent"
  local now
  now="$(now_utc)"
  local project_name
  project_name="$(basename "$root")"
  cat > "$file" <<EOF
{
  "version": 1,
  "project": "$project_name",
  "updated_at": "$now",
  "current_objective": "Operar el kernel portable mínimo restaurado en este workspace.",
  "current_task": "Bootstrap inicial completado por portable-kernel.sh.",
  "status": "scaffold",
  "blockers": [],
  "active_files": [
    "GEMINI.md",
    "MEMORY.md",
    "GEMINI_BLUEPRINTS.md",
    "portable-kernel.sh",
    "portable-kernel-windows.ps1",
    "minimum-kernel.bundle.tar.gz"
  ],
  "next_steps": [
    "Continuar el onboarding del workspace.",
    "Usar el sistema restaurado normalmente.",
    "Ajustar idioma o restaurar artefactos puntuales si hace falta."
  ],
  "key_commands": [
    "bash portable-kernel.sh doctor",
    "bash portable-kernel.sh regen",
    "bash portable-kernel.sh contents"
  ],
  "notes": [
    "Este workspace fue restaurado desde el kit portable de 6 archivos: 3 canon files + 2 platform launchers + 1 payload bundle."
  ],
  "memory_refs": [],
  "current_session": {
    "objective": "Operar el kernel portable mínimo restaurado en este workspace.",
    "last_completed_task": "Bootstrap inicial completado.",
    "blockers": [],
    "active_files": [
      "GEMINI.md",
      "MEMORY.md",
      "GEMINI_BLUEPRINTS.md",
      "portable-kernel.sh",
      "portable-kernel-windows.ps1",
      "minimum-kernel.bundle.tar.gz"
    ],
    "resume_commands": [
      "bash portable-kernel.sh doctor",
      "bash portable-kernel.sh regen",
      "bash portable-kernel.sh contents"
    ],
    "resume_brief": "Kernel portable restaurado. El siguiente paso es usar el workspace normalmente.",
    "next_step": "Usar el sistema restaurado o ajustar idioma si hace falta.",
    "verification_status": "pending",
    "last_snapshot_at": "$now",
    "freshness_state": "fresh",
    "plan_state": {
      "required": false,
      "source": "none",
      "status": "not_required",
      "updated_at": null,
      "content_hash": null,
      "memory_synced": false,
      "next_action": null,
      "producer_agent": null,
      "receipt_ref": null
    }
  },
  "context_import": {
    "source_type": "native_gemini",
    "source_path": "GEMINI.md",
    "mode": "preserve",
    "last_normalized_at": "$now"
  },
  "agent_onboarding": {
    "project_type": "portable-kernel",
    "ui_project": false,
    "shared_rules": [
      "Use SAFE DELETE; never remove project artifacts with direct rm.",
      "portable-kernel.sh and portable-kernel-windows.ps1 are platform launchers for bootstrap, recovery, doctor, regen, and pack/probe flows."
    ],
    "architecture_summary": [
      "This workspace was restored from the minimal portable Antigravity kernel bundle.",
      "GEMINI.md governs runtime behavior, MEMORY.md governs knowledge, and GEMINI_BLUEPRINTS.md stores recovery material."
    ],
    "quickstart_commands": [
      "bash portable-kernel.sh doctor",
      "bash portable-kernel.sh regen",
      "bash portable-kernel.sh contents"
    ],
    "docs_presence": {
      "gemini": true,
      "project_history": true,
      "error_log": true,
      "design_system": false,
      "project_dna": false,
      "current_state": true
    },
    "agentic_surfaces": [],
    "source_hash": "",
    "render_hash": "",
    "last_rendered_at": "$now"
  }
}
EOF
}

seed_knowledge_baseline() {
  local root="$1"
  local vault="$root/.agent/knowledge"
  mkdir -p \
    "$vault/architecture" \
    "$vault/incidents" \
    "$vault/ecosystem" \
    "$vault/research" \
    "$vault/context"
  if [[ "$(install_state_feature_value "$root" "telemetry_tooling")" == "true" ]]; then
    mkdir -p "$vault/inbox"
  fi
  if [[ ! -f "$vault/.project_dna.md" ]]; then
    cat > "$vault/.project_dna.md" <<'EOF'
# Project DNA

- Portable kernel workspace restored from the first-message bootstrap flow.
- Keep this digest short and refresh it only when durable project shape changes.
EOF
  fi
}

seed_templates_if_missing() {
  local root="$1"
  mkdir -p "$root"
  if [[ ! -f "$root/PROJECT_HISTORY.md" ]]; then
    extract_marker "$root/GEMINI_BLUEPRINTS.md" "PROJECT_HISTORY.md" "$root/PROJECT_HISTORY.md"
  fi
  if [[ ! -f "$root/ERROR_LOG.md" ]]; then
    extract_marker "$root/GEMINI_BLUEPRINTS.md" "ERROR_LOG.md" "$root/ERROR_LOG.md"
  fi
  if [[ ! -f "$root/AGENTS.md" ]]; then
    extract_marker "$root/GEMINI_BLUEPRINTS.md" "AGENTS.md" "$root/AGENTS.md"
  fi
}

command_probe() {
  local root="$DEFAULT_ROOT"
  local json_output=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --json)
        json_output=1
        shift
        ;;
      *)
        emit_error "Unknown probe argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  require_cmd jq
  local platform shell_family launcher state_file install_state_present onboarding_status restore_status portable_files_present portable_root_bundle_present portable_cache_bundle_present portable_bundle_present requires_onboarding safe_to_bootstrap
  platform="$(detect_platform)"
  shell_family="$(shell_family_for_platform "$platform")"
  launcher="$(launcher_for_platform "$platform")"
  state_file="$(install_state_path "$root")"
  install_state_present=false
  onboarding_status="not_started"
  restore_status="not_started"
  if [[ -f "$state_file" ]]; then
    install_state_present=true
    onboarding_status="$(jq -r '.onboarding_status // "not_started"' "$state_file" 2>/dev/null || printf 'not_started')"
    restore_status="$(jq -r '.restore_status // "not_started"' "$state_file" 2>/dev/null || printf 'not_started')"
  fi

  portable_root_bundle_present=false
  portable_cache_bundle_present=false
  portable_bundle_present=false
  [[ -s "$root/minimum-kernel.bundle.tar.gz" ]] && portable_root_bundle_present=true
  [[ -s "$root/.portable/minimum-kernel.bundle.tar.gz" ]] && portable_cache_bundle_present=true
  if [[ "$portable_root_bundle_present" == "true" || "$portable_cache_bundle_present" == "true" ]]; then
    portable_bundle_present=true
  fi

  portable_files_present=false
  if [[ -f "$root/GEMINI.md" && -f "$root/MEMORY.md" && -f "$root/GEMINI_BLUEPRINTS.md" && -f "$root/portable-kernel.sh" && -f "$root/portable-kernel-windows.ps1" && "$portable_bundle_present" == "true" ]]; then
    portable_files_present=true
  fi

  requires_onboarding=true
  if [[ "$onboarding_status" == "completed" || "$onboarding_status" == "restored" ]] && [[ "$restore_status" == "restored" ]]; then
    requires_onboarding=false
  fi
  safe_to_bootstrap="$portable_files_present"

  if (( json_output == 1 )); then
    jq -n \
      --arg platform "$platform" \
      --arg shell_family "$shell_family" \
      --arg root "$root" \
      --arg onboarding_status "$onboarding_status" \
      --arg restore_status "$restore_status" \
      --arg launcher "$launcher" \
      --argjson portable_files_present "$portable_files_present" \
      --argjson portable_root_bundle_present "$portable_root_bundle_present" \
      --argjson portable_cache_bundle_present "$portable_cache_bundle_present" \
      --argjson portable_bundle_present "$portable_bundle_present" \
      --argjson install_state_present "$install_state_present" \
      --argjson requires_onboarding "$requires_onboarding" \
      --argjson safe_to_bootstrap "$safe_to_bootstrap" \
      '{
        schema_version: 1,
        platform: $platform,
        shell_family: $shell_family,
        root: $root,
        portable_files_present: $portable_files_present,
        portable_root_bundle_present: $portable_root_bundle_present,
        portable_cache_bundle_present: $portable_cache_bundle_present,
        portable_bundle_present: $portable_bundle_present,
        install_state_present: $install_state_present,
        onboarding_status: $onboarding_status,
        restore_status: $restore_status,
        recommended_launcher: $launcher,
        requires_onboarding: $requires_onboarding,
        safe_to_bootstrap: $safe_to_bootstrap
      }'
    return 0
  fi

  emit_info "platform=$platform shell_family=$shell_family launcher=$launcher onboarding_status=$onboarding_status restore_status=$restore_status requires_onboarding=$requires_onboarding"
}

write_profile_block() {
  local file="$1"
  local profile="$2"
  local onboarding_mode="$3"
  local default_language="$4"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/portable-gemini-profile.XXXXXX")"
  awk \
    -v begin="$PROFILE_MARKER_START" \
    -v end="$PROFILE_MARKER_END" \
    -v profile="$profile" \
    -v onboarding_mode="$onboarding_mode" \
    -v default_language="$default_language" \
    '
      $0 == begin {
        print begin
        print "portable_profile: " profile
        print "portable_version: 1"
        print "portable_onboarding_mode: " onboarding_mode
        print "portable_default_chat_language: " default_language
        print "portable_install_entrypoint: first-chat agent bootstrap via portable-kernel.sh or portable-kernel-windows.ps1"
        print end
        capture = 1
        next
      }
      $0 == end {
        capture = 0
        next
      }
      !capture { print }
    ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

command_bootstrap() {
  local root="$DEFAULT_ROOT"
  local language=""
  local tier=""
  local custom_features=""
  local non_interactive=0
  local trigger=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --language)
        language="$2"
        shift 2
        ;;
      --tier)
        tier="$2"
        shift 2
        ;;
      --custom-features|--features)
        custom_features="$2"
        shift 2
        ;;
      --non-interactive)
        non_interactive=1
        shift
        ;;
      --trigger|--bootstrap-trigger)
        trigger="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown bootstrap argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  require_cmd jq
  require_cmd tar

  local profile
  profile="$(read_profile "$root")"
  if [[ -z "$tier" ]]; then
    if [[ -f "$(install_state_path "$root")" ]]; then
      tier="$(jq -r '.install_tier // "recommended"' "$(install_state_path "$root")" 2>/dev/null || printf 'recommended')"
    else
      tier="recommended"
    fi
  fi
  tier="$(normalize_tier "$tier")"
  ensure_install_state "$root" "$profile" "$tier"
  local now
  now="$(now_utc)"
  local platform shell_family launcher features
  platform="$(detect_platform)"
  shell_family="$(shell_family_for_platform "$platform")"
  launcher="$(launcher_for_platform "$platform")"
  features="$(feature_defaults_json "$tier" | apply_custom_features_filter "$custom_features")"
  if [[ -z "$language" ]]; then
    language="$(jq -r '.preferred_chat_language // empty' "$(install_state_path "$root")" 2>/dev/null || true)"
  fi
  [[ -n "$language" ]] || language="$(default_language_for_profile "$profile")"
  if [[ -z "$trigger" ]]; then
    if [[ "$profile" == "portable_ask_default_en" || "$non_interactive" == "1" ]]; then
      trigger="first_chat"
    else
      trigger="manual"
    fi
  fi

  update_install_state_jq "$root" \
    --arg profile "$profile" \
    --arg language "$language" \
    --arg tier "$tier" \
    --arg platform "$platform" \
    --arg shell_family "$shell_family" \
    --arg launcher "$launcher" \
    --arg trigger "$trigger" \
    --arg now "$now" \
    --argjson features "$features" \
    '.portable_profile = $profile
     | .portable_version = 1
     | .preferred_chat_language = $language
     | .language_source = (if .language_source == "custom" then "custom" else "preset" end)
     | .install_tier = $tier
     | .feature_profile = $tier
     | .features = ($features + {live_state: true, project_state_cache: true})
     | .platform = $platform
     | .shell_family = $shell_family
     | .launcher_used = $launcher
     | .bootstrap_trigger = $trigger
     | .last_prompted_at = $now'

  local bundle_tgz
  bundle_tgz="$(extract_portable_bundle_archive "$root")"
  local bundle_tmp
  bundle_tmp="$(dirname "$bundle_tgz")"
  tar -xzf "$bundle_tgz" -C "$root"
  rm -rf "$bundle_tmp"

  if [[ -x "$root/scripts/dependency-safety-adapter.sh" ]]; then
    bash "$root/scripts/dependency-safety-adapter.sh" --root "$root" install-guard >/dev/null
  fi

  if [[ "$(install_state_feature_value "$root" "project_ledgers")" == "true" ]]; then
    seed_templates_if_missing "$root"
  fi
  seed_current_state "$root"
  seed_project_state "$root"
  if [[ "$(install_state_feature_value "$root" "memory_vault")" == "true" ]]; then
    seed_knowledge_baseline "$root"
  fi
  mkdir -p "$root/state/traces"
  [[ -f "$root/state/traces/portable-bootstrap.jsonl" ]] || : > "$root/state/traces/portable-bootstrap.jsonl"

  update_install_state_jq "$root" \
    --arg now "$now" \
    '.onboarding_status = "completed"
     | .restore_status = "restored"
     | .last_prompted_at = $now'

  emit_info "Portable kernel restored in $root"
  command_doctor --root "$root"
}

command_set_language() {
  local root="$DEFAULT_ROOT"
  local language=""
  local source=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --language)
        language="$2"
        shift 2
        ;;
      --source)
        source="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown set-language argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  [[ -n "$source" ]] || source="default"
  local normalized_language="$language"
  if [[ -z "$normalized_language" ]]; then
    normalized_language="English"
    source="default"
  fi

  ensure_install_state "$root" "portable_ask_default_en"
  local now
  now="$(now_utc)"
  update_install_state_jq "$root" \
    --arg language "$normalized_language" \
    --arg source "$source" \
    --arg now "$now" \
    '.portable_profile = "portable_ask_default_en"
     | .portable_version = 1
     | .preferred_chat_language = $language
     | .language_source = $source
     | .last_prompted_at = $now
     | .onboarding_status = (if .restore_status == "restored" then "completed" else "pending_restore" end)'
  emit_info "Preferred chat language persisted as $normalized_language"
}

command_set_tier() {
  local root="$DEFAULT_ROOT"
  local tier=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --tier)
        tier="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown set-tier argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  tier="$(normalize_tier "$tier")"
  require_cmd jq
  ensure_install_state "$root" "portable_ask_default_en" "$tier"
  local features now
  features="$(feature_defaults_json "$tier")"
  now="$(now_utc)"
  update_install_state_jq "$root" \
    --arg tier "$tier" \
    --arg now "$now" \
    --argjson features "$features" \
    '.install_tier = $tier
     | .feature_profile = $tier
     | .features = ($features + {live_state: true, project_state_cache: true})
     | .last_prompted_at = $now'
  emit_info "Portable install tier persisted as $tier"
}

command_configure_features() {
  local root="$DEFAULT_ROOT"
  local features_csv=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --features|--custom-features)
        features_csv="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown configure-features argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  [[ -n "$features_csv" ]] || {
    emit_error "configure-features requires --features k=v,..."
    exit 1
  }
  require_cmd jq
  ensure_install_state "$root" "portable_ask_default_en" "custom"
  local current_features now
  current_features="$(jq -c '.features // {}' "$(install_state_path "$root")" | apply_custom_features_filter "$features_csv")"
  now="$(now_utc)"
  update_install_state_jq "$root" \
    --arg now "$now" \
    --argjson features "$current_features" \
    '.install_tier = "custom"
     | .feature_profile = "custom"
     | .features = ($features + {live_state: true, project_state_cache: true})
     | .last_prompted_at = $now'
  emit_info "Portable feature flags updated"
}

command_defer() {
  local root="$DEFAULT_ROOT"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown defer argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  ensure_install_state "$root" "portable_ask_default_en"
  local now
  now="$(now_utc)"
  update_install_state "$root" ".portable_profile = \"portable_ask_default_en\" | .onboarding_status = \"deferred\" | .restore_status = \"deferred\" | .last_prompted_at = \"$now\""
  emit_info "Portable onboarding deferred for $root"
}

command_remember_intent() {
  local root="$DEFAULT_ROOT"
  local summary=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --summary)
        summary="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown remember-intent argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  [[ -n "$summary" ]] || {
    emit_error "remember-intent requires --summary"
    exit 1
  }
  if (( ${#summary} > 240 )); then
    emit_error "remember-intent summary must be 240 characters or fewer"
    exit 1
  fi
  require_cmd jq
  ensure_install_state "$root" "portable_ask_default_en"
  local now
  now="$(now_utc)"
  update_install_state_jq "$root" \
    --arg summary "$summary" \
    --arg now "$now" \
    '.first_user_intent_summary = $summary
     | .first_user_intent_captured_at = $now
     | .last_prompted_at = $now'
  emit_info "First-message intent summary persisted"
}

command_contents() {
  local root="$DEFAULT_ROOT"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown contents argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  require_cmd jq
  local manifest_json
  manifest_json="$(extract_bundle_manifest_json "$root")"
  jq -r '
    "Portable kernel install contents:",
    "",
    "First-message bootstrap:",
    "- Copy the 6 root files, open Antigravity, and send any first message. The agent must run probe, persist a compact original-intent summary with remember-intent, guide language/profile selection, execute the platform launcher, run doctor, and then resume the persisted request.",
    "- macOS/Linux launcher: portable-kernel.sh",
    "- Windows launcher: portable-kernel-windows.ps1",
    "",
    "Install profiles:",
    "- recommended: default for most users; memory, audits, and advanced workflows enabled; MCP and tests are user-local/source-only.",
    "- minimal: live state and cache only; memory vault, ledgers, MCP templates, tests, and telemetry off.",
    "- complete: full runtime tooling enabled; MCP and tests remain source-repo/user-local only.",
    "- custom: explicit feature flags selected by the user in chat.",
    "",
    "Categories:",
    (.categories[] | "- \(.category): \(.count) artifact(s)"),
    "",
    "Security notes:",
    "- No MCP runtime template is included.",
    "- Tests/evals are source-repo only and are not installed by the portable bundle.",
    "",
    "Artifacts:",
    (.artifacts
      | sort_by(.category, .path)
      | group_by(.category)[]
      | ""
      , ("[" + .[0].category + "]")
      , (.[] | "- " + .path))
  ' <<< "$manifest_json"
}

command_recover() {
  local root="$DEFAULT_ROOT"
  local project_root=""
  local output_path=""
  local force=0
  local list_only=0
  local target=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --project-root)
        project_root="$2"
        shift 2
        ;;
      --output)
        output_path="$2"
        shift 2
        ;;
      --force)
        force=1
        shift
        ;;
      --list)
        list_only=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        if [[ -z "$target" ]]; then
          target="$1"
          shift
        else
          emit_error "Unexpected recover argument: $1"
          exit 1
        fi
        ;;
    esac
  done

  if (( list_only == 1 )); then
    command_contents --root "$root"
    exit 0
  fi

  if [[ -z "$target" || "$target" == "all" ]]; then
    local bundle_tgz
    bundle_tgz="$(extract_portable_bundle_archive "$root")"
    local bundle_tmp
    bundle_tmp="$(dirname "$bundle_tgz")"
    tar -xzf "$bundle_tgz" -C "$root"
    rm -rf "$bundle_tmp"
    echo "BUNDLE_RESTORED:$root"
    exit 0
  fi

  if [[ "$target" == system:* ]]; then
    emit_error "Unsupported artifact namespace: $target"
    emit_error "Share GEMINI.md, MEMORY.md, GEMINI_BLUEPRINTS.md, portable-kernel.sh, portable-kernel-windows.ps1, and minimum-kernel.bundle.tar.gz separately."
    exit 1
  fi

  if [[ "$target" == "template:implementation_plan.md" ]]; then
    emit_error "Legacy template disabled: implementation plans stay in the producing host/session and only mirror plan_state + memory."
    exit 1
  fi

  if [[ "$target" == workflow:* || "$target" == template:* || "$target" == skill:* ]]; then
    require_cmd jq
    local manifest="$root/blueprints/manifest.json"
    [[ -f "$manifest" ]] || {
      emit_error "Missing blueprint manifest: $manifest"
      exit 1
    }
    local entry
    entry="$(jq -er --arg id "$target" '.artifacts[$id]' "$manifest")"
    local marker_name expected_sha restore_scope default_restore_path canonical_path
    marker_name="$(printf '%s' "$entry" | jq -r '.marker_name')"
    canonical_path="$(printf '%s' "$entry" | jq -r '.canonical_path')"
    expected_sha="$(printf '%s' "$entry" | jq -r '.sha256')"
    restore_scope="$(printf '%s' "$entry" | jq -r '.restore_scope')"
    default_restore_path="$(printf '%s' "$entry" | jq -r '.default_restore_path')"

    if [[ -z "$output_path" ]]; then
      case "$restore_scope" in
        gemini_root)
          output_path="$root/$default_restore_path"
          ;;
        project_root)
          if [[ -z "$project_root" ]]; then
            emit_error "Artifact $target requires --project-root or --output."
            exit 1
          fi
          output_path="$project_root/$default_restore_path"
          ;;
        explicit_output_only)
          emit_error "Artifact $target requires --output."
          exit 1
          ;;
        *)
          emit_error "Unsupported restore scope: $restore_scope"
          exit 1
          ;;
      esac
    fi

    local tmp_extract
    tmp_extract="$(mktemp "${TMPDIR:-/tmp}/portable-blueprint-artifact.XXXXXX")"
    trap 'rm -f "$tmp_extract"' RETURN
    extract_marker "$root/GEMINI_BLUEPRINTS.md" "$marker_name" "$tmp_extract"
    if [[ ! -s "$tmp_extract" && "$canonical_path" != "GEMINI_BLUEPRINTS.md" ]]; then
      local bundle_tgz
      bundle_tgz="$(extract_portable_bundle_archive "$root")"
      local bundle_tmp
      bundle_tmp="$(dirname "$bundle_tgz")"
      tar -xzf "$bundle_tgz" -C "$bundle_tmp" "./$canonical_path" >/dev/null 2>&1 || true
      if [[ -f "$bundle_tmp/$canonical_path" ]]; then
        cp "$bundle_tmp/$canonical_path" "$tmp_extract"
      fi
      rm -rf "$bundle_tmp"
    fi
    [[ -s "$tmp_extract" ]] || {
      emit_error "Failed to extract artifact $target from BLUEPRINTS marker or portable bundle."
      exit 1
    }
    local actual_sha
    actual_sha="$(shasum -a 256 "$tmp_extract" | awk '{print $1}')"
    if [[ "$actual_sha" != "$expected_sha" ]]; then
      emit_error "Hash mismatch while restoring $target. Expected $expected_sha, got $actual_sha."
      exit 1
    fi

    mkdir -p "$(dirname "$output_path")"
    if [[ -f "$output_path" ]]; then
      local current_sha
      current_sha="$(shasum -a 256 "$output_path" | awk '{print $1}')"
      if [[ "$current_sha" == "$expected_sha" ]]; then
        echo "ARTIFACT_ALREADY_MATCHES:$target:$output_path"
        exit 0
      fi
      if (( force != 1 )); then
        emit_error "Target exists with different content: $output_path. Re-run with --force to overwrite."
        exit 1
      fi
    fi
    cp "$tmp_extract" "$output_path"
    echo "ARTIFACT_RESTORED:$target:$output_path"
    exit 0
  fi

  local manifest_json
  manifest_json="$(extract_bundle_manifest_json "$root")"
  if ! jq -e --arg path "$target" '.artifacts | any(.path == $path)' >/dev/null <<< "$manifest_json"; then
    emit_error "Portable bundle does not contain: $target"
    exit 1
  fi

  local bundle_tgz
  bundle_tgz="$(extract_portable_bundle_archive "$root")"
  local bundle_tmp
  bundle_tmp="$(dirname "$bundle_tgz")"

  if [[ -z "$output_path" ]]; then
    output_path="$root/$target"
  fi
  mkdir -p "$(dirname "$output_path")"

  tar -xzf "$bundle_tgz" -C "$bundle_tmp" "./$target"
  local extracted="$bundle_tmp/$target"
  [[ -f "$extracted" ]] || {
    emit_error "Failed to extract $target from the portable bundle"
    rm -rf "$bundle_tmp"
    exit 1
  }

  if [[ -f "$output_path" ]]; then
    local current_sha new_sha
    current_sha="$(shasum -a 256 "$output_path" | awk '{print $1}')"
    new_sha="$(shasum -a 256 "$extracted" | awk '{print $1}')"
    if [[ "$current_sha" == "$new_sha" ]]; then
      echo "ARTIFACT_ALREADY_MATCHES:$target:$output_path"
      rm -rf "$bundle_tmp"
      exit 0
    fi
    if (( force != 1 )); then
      emit_error "Target exists with different content: $output_path. Re-run with --force to overwrite."
      rm -rf "$bundle_tmp"
      exit 1
    fi
  fi

  cp "$extracted" "$output_path"
  rm -rf "$bundle_tmp"
  echo "BUNDLE_ARTIFACT_RESTORED:$target:$output_path"
}

command_doctor() {
  local root="$DEFAULT_ROOT"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown doctor argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  local profile
  profile="$(read_profile "$root")"
  if [[ "$profile" == "source_forced_es" && -f "$root/scripts/gemini-doctor.sh" ]]; then
    PORTABLE_KERNEL_INTERNAL_CALL=1 bash "$root/scripts/gemini-doctor.sh" "$root"
    exit $?
  fi

  require_cmd jq
  require_cmd rg
  local errors=0
  for file in "$root/GEMINI.md" "$root/MEMORY.md" "$root/GEMINI_BLUEPRINTS.md" "$root/portable-kernel.sh" "$root/portable-kernel-windows.ps1"; do
    [[ -f "$file" ]] || {
      emit_error "Missing required portable file: $file"
      errors=$((errors + 1))
    }
  done

  if ! rg -F -q "$PROFILE_MARKER_START" "$root/GEMINI.md"; then
    emit_error "GEMINI.md is missing the portable profile block"
    errors=$((errors + 1))
  fi

  local root_bundle cache_bundle
  root_bundle="$root/minimum-kernel.bundle.tar.gz"
  cache_bundle="$root/.portable/minimum-kernel.bundle.tar.gz"
  if [[ ! -s "$root_bundle" && ! -s "$cache_bundle" ]]; then
    emit_error "Portable minimum bundle is missing (minimum-kernel.bundle.tar.gz or generated .portable/minimum-kernel.bundle.tar.gz cache)"
    errors=$((errors + 1))
  fi

  local state_file
  state_file="$(install_state_path "$root")"
  if [[ -f "$state_file" ]]; then
    jq -e '
      (.portable_profile | type == "string") and
      (.portable_version | type == "number") and
      (.onboarding_status | type == "string") and
      ((.onboarding_status == "pending_language") or (.onboarding_status == "pending_restore") or (.onboarding_status == "restored") or (.onboarding_status == "completed") or (.onboarding_status == "deferred")) and
      (.preferred_chat_language | type == "string") and
      (.language_source | type == "string") and
      ((.language_source == "forced") or (.language_source == "preset") or (.language_source == "custom") or (.language_source == "default")) and
      (.install_tier | type == "string") and
      ((.install_tier == "minimal") or (.install_tier == "recommended") or (.install_tier == "complete") or (.install_tier == "custom")) and
      (.features | type == "object") and
      (.features.live_state == true) and
      (.features.project_state_cache == true) and
      (.platform | type == "string") and
      (.launcher_used | type == "string") and
      (.restore_status | type == "string") and
      ((.restore_status == "not_started") or (.restore_status == "restored") or (.restore_status == "deferred")) and
      ((.last_prompted_at == null) or (.last_prompted_at | type == "string"))
    ' "$state_file" >/dev/null || {
      emit_error "Invalid .kernel/install_state.json contract"
      errors=$((errors + 1))
    }
  fi

  if [[ -f "$state_file" ]] && jq -e '.restore_status == "restored"' "$state_file" >/dev/null 2>&1; then
    for dir in "$root/scripts" "$root/config" "$root/state" "$root/rules" "$root/.agent"; do
      [[ -d "$dir" ]] || {
        emit_error "Missing restored directory: $dir"
        errors=$((errors + 1))
      }
    done
    if jq -e '.features.advanced_workflows == true' "$state_file" >/dev/null 2>&1; then
      for dir in "$root/workflows"; do
        [[ -d "$dir" ]] || {
          emit_error "Missing restored directory: $dir"
          errors=$((errors + 1))
        }
      done
    fi
    for forbidden in \
      "$root/antigravity/mcp_config.json" \
      "$root/evals" \
      "$root/skills-lock.json" \
      "$root/skills-manifest.json" \
      "$root/reports/skills-curation-report.json" \
      "$root/scripts/run-core-evals.sh" \
      "$root/scripts/run-lean-evals.sh" \
      "$root/scripts/gemini-doctor.sh" \
      "$root/scripts/doctor" \
      "$root/scripts/__pycache__"
    do
      [[ ! -e "$forbidden" ]] || {
        emit_error "Portable restore included source-only artifact: $forbidden"
        errors=$((errors + 1))
      }
    done
    if find "$root/scripts" -maxdepth 1 -type f \( -name 'check-*' -o -name 'evaluate-*' \) | grep -q .; then
      emit_error "Portable restore included source-only check/evaluate scripts."
      errors=$((errors + 1))
    fi
    for file in "$root/.agent/current_state.json" "$root/.agent/current_state.md" "$root/.agent/project_state.json"; do
      [[ -f "$file" ]] || {
        emit_error "Missing restored file: $file"
        errors=$((errors + 1))
      }
    done
    if jq -e '.features.project_ledgers == true' "$state_file" >/dev/null 2>&1; then
      for file in "$root/PROJECT_HISTORY.md" "$root/ERROR_LOG.md" "$root/AGENTS.md"; do
        [[ -f "$file" ]] || {
          emit_error "Missing restored file: $file"
          errors=$((errors + 1))
        }
      done
    fi
    if jq -e '.features.memory_vault == true' "$state_file" >/dev/null 2>&1; then
      [[ -d "$root/.agent/knowledge" ]] || {
        emit_error "Missing restored memory vault: $root/.agent/knowledge"
        errors=$((errors + 1))
      }
      [[ -f "$root/.agent/knowledge/.project_dna.md" ]] || {
        emit_error "Missing restored Project DNA: $root/.agent/knowledge/.project_dna.md"
        errors=$((errors + 1))
      }
    fi
    if [[ -x "$root/scripts/dependency-safety-adapter.sh" ]]; then
      if ! bash "$root/scripts/dependency-safety-adapter.sh" --root "$root" doctor --json >/dev/null 2>&1; then
        emit_error "Dependency safety adapter is not healthy; run scripts/dependency-safety-adapter.sh --root \"$root\" install-guard"
        errors=$((errors + 1))
      fi
    else
      emit_error "Missing dependency safety adapter in restored portable runtime"
      errors=$((errors + 1))
    fi
  fi

  if (( errors > 0 )); then
    printf 'SUMMARY: %s error(s)\n' "$errors"
    exit 1
  fi

  printf 'SUMMARY: 0 error(s)\n'
}

command_regen() {
  local root="$DEFAULT_ROOT"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown regen argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [[ -f "$root/scripts/build-blueprints.sh" ]]; then
    PORTABLE_KERNEL_INTERNAL_CALL=1 bash "$root/scripts/build-blueprints.sh" "$root"
    return $?
  fi

  emit_error "build-blueprints.sh is not available in $root"
  exit 1
}

command_pack() {
  local root="$DEFAULT_ROOT"
  local output_dir=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --root)
        root="$2"
        shift 2
        ;;
      --output)
        output_dir="$2"
        shift 2
        ;;
      *)
        emit_error "Unknown pack argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  [[ -n "$output_dir" ]] || output_dir="$root/dist/portable-kernel-kit"
  mkdir -p "$output_dir"

  command_regen --root "$root" >/dev/null

  cp "$root/GEMINI.md" "$output_dir/GEMINI.md"
  cp "$root/MEMORY.md" "$output_dir/MEMORY.md"
  cp "$root/GEMINI_BLUEPRINTS.md" "$output_dir/GEMINI_BLUEPRINTS.md"
  cp "$root/portable-kernel.sh" "$output_dir/portable-kernel.sh"
  cp "$root/portable-kernel-windows.ps1" "$output_dir/portable-kernel-windows.ps1"
  cp "$root/minimum-kernel.bundle.tar.gz" "$output_dir/minimum-kernel.bundle.tar.gz"
  rm -rf "$output_dir/.portable"

  write_profile_block "$output_dir/GEMINI.md" "portable_ask_default_en" "ask_on_first_run" "English"
  emit_info "Portable kit exported to $output_dir"
}

main() {
  local command="${1:-}"
  if [[ -z "$command" ]]; then
    usage
    exit 1
  fi
  shift || true

  case "$command" in
    probe)
      command_probe "$@"
      ;;
    bootstrap)
      command_bootstrap "$@"
      ;;
    recover)
      command_recover "$@"
      ;;
    doctor)
      command_doctor "$@"
      ;;
    regen)
      command_regen "$@"
      ;;
    pack)
      command_pack "$@"
      ;;
    contents)
      command_contents "$@"
      ;;
    remember-intent)
      command_remember_intent "$@"
      ;;
    set-language)
      command_set_language "$@"
      ;;
    set-tier)
      command_set_tier "$@"
      ;;
    configure-features)
      command_configure_features "$@"
      ;;
    defer)
      command_defer "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      emit_error "Unknown command: $command"
      usage
      exit 1
      ;;
  esac
}

main "$@"
