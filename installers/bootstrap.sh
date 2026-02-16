#!/usr/bin/env bash
set -euo pipefail

ACTION="install"
REPO_URL="${THS_REPO_URL:-https://github.com/thehormoziskill/the-hormozi-skill.git}"
SKILL_NAME="the-hormozi-skill"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DEST="$CODEX_HOME/skills/$SKILL_NAME"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      ACTION="${2:-install}"
      shift 2
      ;;
    --repo)
      REPO_URL="${2:-$REPO_URL}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ "$ACTION" != "install" && "$ACTION" != "update" && "$ACTION" != "uninstall" ]]; then
  echo "Invalid --action. Use install, update, or uninstall."
  exit 1
fi

detect_codex_extension() {
  local found="0"
  local dirs=(
    "$HOME/.vscode/extensions"
    "$HOME/.cursor/extensions"
    "$HOME/.windsurf/extensions"
  )

  for d in "${dirs[@]}"; do
    if [[ -d "$d" ]] && find "$d" -maxdepth 1 -type d -iname '*codex*' | grep -q .; then
      found="1"
      break
    fi
  done

  echo "$found"
}

if [[ "$ACTION" == "uninstall" ]]; then
  if [[ -d "$DEST" ]]; then
    rm -rf "$DEST"
    echo "Removed $DEST"
  else
    echo "Skill not installed at $DEST"
  fi
  exit 0
fi

if [[ "${THS_CONFIRM_EXTENSION:-0}" != "1" ]]; then
  has_extension="$(detect_codex_extension)"
  if [[ "$has_extension" != "1" ]]; then
    echo "Codex IDE extension was not auto-detected."
    echo "Install the Codex extension in your IDE, then run again."
    echo "If already installed in a non-standard path, rerun with THS_CONFIRM_EXTENSION=1."
    exit 2
  fi
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "Fetching skill from $REPO_URL"
git clone --depth 1 "$REPO_URL" "$tmp_dir/repo" >/dev/null 2>&1

source_dir="$tmp_dir/repo/$SKILL_NAME"
if [[ ! -f "$source_dir/SKILL.md" ]]; then
  echo "Skill package not found at $source_dir"
  exit 1
fi

mkdir -p "$CODEX_HOME/skills"

if [[ "$ACTION" == "install" && -d "$DEST" ]]; then
  echo "Skill already exists at $DEST"
  echo "Use --action update to replace it."
  exit 1
fi

if [[ -d "$DEST" ]]; then
  rm -rf "$DEST"
fi

cp -R "$source_dir" "$DEST"
echo "Installed $SKILL_NAME to $DEST"
echo "Restart Codex to load the new skill."
