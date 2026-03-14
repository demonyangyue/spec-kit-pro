#!/bin/bash
# Specify CLI upgrade hook for Claude / Cursor / Qoder and similar AI assistants.
# When user input starts with /speckit: or /specify:, checks whether a newer release
# exists at https://github.com/demonyangyue/spec-kit-pro and, if so, runs
#   uv tool install specify-cli --force --from "git+https://github.com/demonyangyue/spec-kit-pro.git@<tag>"
# Requires: specify (or parseable version output), curl, uv in PATH.
# Robustness: on any failure (network, parse, uv missing, etc.) this script exits 0
# so that the normal /speckit.* or /specify.* command is never blocked.

WORKSPACE_DIR_KEY="cwd"
GITHUB_API_URL="https://api.github.com/repos/demonyangyue/spec-kit-pro/releases/latest"

stdin=""
prompt=""
workspace_dir=""
current_version=""
latest_version=""
tag_name=""

# Read stdin once
stdin=$(cat 2>/dev/null) || true

# Extract prompt (robust: empty if unset)
prompt=$(echo "$stdin" | grep -o '"prompt":"[^"]*"' 2>/dev/null | sed 's/"prompt":"\(.*\)"/\1/' 2>/dev/null) || true

# Only run when prompt starts with /speckit: or /specify: (or /speckit/ or /specify/)
if [[ -z "$prompt" ]]; then
  exit 0
fi
if [[ ! "$prompt" =~ ^/speckit[:/] ]] && [[ ! "$prompt" =~ ^/specify[:/] ]]; then
  exit 0
fi

# Extract workspace directory
workspace_dir=$(echo "$stdin" | grep -o "\"$WORKSPACE_DIR_KEY\":\"[^\"]*\"" 2>/dev/null | sed "s/\"$WORKSPACE_DIR_KEY\":\"\(.*\)\"/\1/" 2>/dev/null) || true

# Get current version: try "specify version" first (first semver in output), then pip show
if [[ -n "$workspace_dir" ]] && [[ -d "$workspace_dir" ]]; then
  current_version=$(cd "$workspace_dir" && specify version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' 2>/dev/null | head -n1) || true
fi
if [[ -z "$current_version" ]]; then
  current_version=$(pip show specify-cli 2>/dev/null | awk '/^Version:/ { print $2 }' 2>/dev/null) || true
fi
if [[ -z "$current_version" ]] || [[ ! "$current_version" =~ ^[0-9]+\.[0-9]+ ]]; then
  exit 0
fi

# Normalize: strip any trailing suffix for comparison (e.g. 0.1.5.dev0 -> 0.1.5)
current_version=$(echo "$current_version" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/') || true
if [[ -z "$current_version" ]]; then
  exit 0
fi

# Fetch latest release from GitHub (fail silently on network/API errors)
api_json=$(curl -sSf -L --max-time 10 "$GITHUB_API_URL" 2>/dev/null) || true
if [[ -z "$api_json" ]]; then
  exit 0
fi

tag_name=$(echo "$api_json" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' 2>/dev/null | sed -E 's/"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/' 2>/dev/null) || true
if [[ -z "$tag_name" ]]; then
  exit 0
fi

# Strip leading 'v' from tag (e.g. v0.3.0 -> 0.3.0)
latest_version=$(echo "$tag_name" | sed -E 's/^v([0-9].*)/\1/' 2>/dev/null) || true
if [[ -z "$latest_version" ]] || [[ ! "$latest_version" =~ ^[0-9]+\.[0-9]+ ]]; then
  exit 0
fi

latest_version=$(echo "$latest_version" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/') || true

# Compare: only upgrade if latest > current (using sort -V)
sorted=$(printf '%s\n' "$current_version" "$latest_version" | sort -V 2>/dev/null) || true
if [[ -z "$sorted" ]]; then
  exit 0
fi
greater=$(echo "$sorted" | tail -n1)
if [[ "$greater" != "$latest_version" ]] || [[ "$latest_version" == "$current_version" ]]; then
  exit 0
fi

# Ensure we have a tag for install (prefer v-prefixed for git)
install_tag="$tag_name"
if [[ "$install_tag" != v* ]] && [[ "$install_tag" =~ ^[0-9] ]]; then
  install_tag="v$install_tag"
fi

# Run upgrade; do not propagate failure (robustness: exit 0 anyway)
if command -v uv >/dev/null 2>&1; then
  uv tool install specify-cli --force --from "git+https://github.com/demonyangyue/spec-kit-pro.git@${install_tag}" >&2 2>/dev/null || true
else
  echo "Spec Kit: uv not found; to upgrade run: uv tool install specify-cli --force --from git+https://github.com/demonyangyue/spec-kit-pro.git" >&2
fi

exit 0
