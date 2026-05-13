#!/usr/bin/env bash
set -euo pipefail

REPO="${ANTIGRAVITY_ULTRA_REPO:-ungrav/antigravity-ultra}"
VERSION="${ANTIGRAVITY_ULTRA_VERSION:-latest}"
ROOT="${ANTIGRAVITY_ULTRA_ROOT:-$PWD}"
TIER="${ANTIGRAVITY_ULTRA_TIER:-recommended}"
LANGUAGE="${ANTIGRAVITY_ULTRA_LANGUAGE:-}"
SOURCE_DIR="${ANTIGRAVITY_ULTRA_SOURCE_DIR:-}"
SKIP_BOOTSTRAP=0

PORTABLE_FILES=(
  "GEMINI.md"
  "MEMORY.md"
  "GEMINI_BLUEPRINTS.md"
  "portable-kernel.sh"
  "portable-kernel-windows.ps1"
  "minimum-kernel.bundle.tar.gz"
)

usage() {
  cat <<'EOF'
Usage:
  install.sh [--root PATH] [--tier minimal|recommended|complete|custom] [--language VALUE]
  install.sh [--root PATH] [--version latest|TAG] [--repo OWNER/REPO]
  install.sh --source-dir PATH [--root PATH]

Environment:
  ANTIGRAVITY_ULTRA_ROOT       Target project directory. Defaults to current directory.
  ANTIGRAVITY_ULTRA_TIER       Install tier. Defaults to recommended.
  ANTIGRAVITY_ULTRA_LANGUAGE   Chat language passed to bootstrap.
  ANTIGRAVITY_ULTRA_REPO       GitHub repo. Defaults to ungrav/antigravity-ultra.
  ANTIGRAVITY_ULTRA_VERSION    Release tag or latest. Defaults to latest.
  ANTIGRAVITY_ULTRA_SOURCE_DIR Local source directory for tests/offline installs.
EOF
}

info() {
  printf 'INFO: %s\n' "$1"
}

error() {
  printf 'ERROR: %s\n' "$1" >&2
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    error "Missing required command: $1"
    exit 1
  }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT="$2"
      shift 2
      ;;
    --tier)
      TIER="$2"
      shift 2
      ;;
    --language)
      LANGUAGE="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --source-dir)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --skip-bootstrap)
      SKIP_BOOTSTRAP=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

case "$TIER" in
  minimal|recommended|complete|custom) ;;
  *)
    error "Unknown install tier: $TIER"
    exit 1
    ;;
esac

ROOT="$(mkdir -p "$ROOT" && cd "$ROOT" && pwd -P)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/antigravity-ultra-install.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

copy_from_source_dir() {
  local source_dir="$1"
  source_dir="$(cd "$source_dir" && pwd -P)"
  for name in "${PORTABLE_FILES[@]}"; do
    [[ -s "$source_dir/$name" ]] || {
      error "Missing portable file in source dir: $source_dir/$name"
      exit 1
    }
    cp "$source_dir/$name" "$TMP_DIR/$name"
  done
}

release_url_for() {
  local name="$1"
  if [[ "$VERSION" == "latest" ]]; then
    printf 'https://github.com/%s/releases/latest/download/%s\n' "$REPO" "$name"
  else
    printf 'https://github.com/%s/releases/download/%s/%s\n' "$REPO" "$VERSION" "$name"
  fi
}

download_release_files() {
  local downloader=""
  if command -v curl >/dev/null 2>&1; then
    downloader="curl"
  elif command -v wget >/dev/null 2>&1; then
    downloader="wget"
  else
    error "Missing required command: curl or wget"
    exit 1
  fi

  for name in "${PORTABLE_FILES[@]}"; do
    local url
    url="$(release_url_for "$name")"
    info "Downloading $name"
    if [[ "$downloader" == "curl" ]]; then
      curl -fsSL --retry 3 --retry-all-errors --retry-delay 1 --connect-timeout 20 "$url" -o "$TMP_DIR/$name"
    else
      wget -q --tries=3 --timeout=20 "$url" -O "$TMP_DIR/$name"
    fi
    [[ -s "$TMP_DIR/$name" ]] || {
      error "Downloaded empty portable file: $name"
      exit 1
    }
  done
}

if [[ -n "$SOURCE_DIR" ]]; then
  info "Using local portable source: $SOURCE_DIR"
  copy_from_source_dir "$SOURCE_DIR"
else
  info "Installing Antigravity Ultra from GitHub release: $REPO@$VERSION"
  download_release_files
fi

for name in "${PORTABLE_FILES[@]}"; do
  cp "$TMP_DIR/$name" "$ROOT/$name"
done
chmod +x "$ROOT/portable-kernel.sh"

info "Installed 6 portable root files into $ROOT"

if (( SKIP_BOOTSTRAP == 1 )); then
  info "Skipping bootstrap by request."
  exit 0
fi

require_cmd bash
info "Running portable probe"
bash "$ROOT/portable-kernel.sh" probe --root "$ROOT"

bootstrap_args=(bootstrap --root "$ROOT" --tier "$TIER" --non-interactive --trigger manual)
if [[ -n "$LANGUAGE" ]]; then
  bootstrap_args+=(--language "$LANGUAGE")
fi

info "Running portable bootstrap tier=$TIER"
bash "$ROOT/portable-kernel.sh" "${bootstrap_args[@]}"

info "Running portable doctor"
bash "$ROOT/portable-kernel.sh" doctor --root "$ROOT"
info "Antigravity Ultra install complete."
