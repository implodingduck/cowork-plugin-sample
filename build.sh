#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <plugin-dir> [options]

Build a Cowork plugin .zip package from a manifest.json.template.

Arguments:
  plugin-dir              Plugin directory (e.g. market-intelligence)

Options:
  --id <guid>             App ID (default: auto-generated UUID)
  --var KEY=VALUE         Set a template variable (replaces {{KEY}} with VALUE).
                          Can be specified multiple times for different variables.
  --output <path>         Output zip path (default: <plugin-dir>.zip)
  --no-env                Skip loading .env file
  -h, --help              Show this help

Variable precedence (highest to lowest):
  --var flags > environment variables > .env file in plugin directory

Any KEY=VALUE pairs in the .env file or exported environment variables
matching template placeholders ({{KEY}}) will be used automatically.
EOF
  exit 1
}

# --- Parse arguments ---
PLUGIN_DIR=""
APP_ID="${APP_ID:-}"
OUTPUT=""
SKIP_ENV=false

# Associative array for template variables (--var KEY=VALUE)
declare -A CLI_VARS

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)             APP_ID="$2"; shift 2 ;;
    --var)
      if [[ "$2" != *=* ]]; then
        echo "Error: --var requires KEY=VALUE format, got '$2'" >&2
        exit 1
      fi
      key="${2%%=*}"
      value="${2#*=}"
      CLI_VARS["$key"]="$value"
      shift 2
      ;;
    --output)         OUTPUT="$2"; shift 2 ;;
    --no-env)         SKIP_ENV=true; shift ;;
    -h|--help)        usage ;;
    -*)               echo "Error: Unknown option $1" >&2; usage ;;
    *)
      if [[ -z "$PLUGIN_DIR" ]]; then
        PLUGIN_DIR="$1"; shift
      else
        echo "Error: Unexpected argument $1" >&2; usage
      fi
      ;;
  esac
done

if [[ -z "$PLUGIN_DIR" ]]; then
  echo "Error: Plugin directory is required." >&2
  usage
fi

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="${PLUGIN_DIR%/}"

if [[ ! -d "$SCRIPT_DIR/$PLUGIN_DIR" ]]; then
  echo "Error: Directory '$PLUGIN_DIR' not found in $SCRIPT_DIR" >&2
  exit 1
fi

PLUGIN_PATH="$SCRIPT_DIR/$PLUGIN_DIR"
TEMPLATE="$PLUGIN_PATH/manifest.json.template"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: $TEMPLATE not found" >&2
  exit 1
fi

# --- Load .env file (lowest precedence) ---
# Associative array for .env variables
declare -A ENV_VARS

ENV_FILE="$PLUGIN_PATH/.env"
if [[ "$SKIP_ENV" == false && -f "$ENV_FILE" ]]; then
  echo "Loading .env from $PLUGIN_DIR/.env"
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blank lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    # Strip inline comments and surrounding whitespace/quotes
    key="${line%%=*}"
    value="${line#*=}"
    key="$(echo "$key" | xargs)"
    value="$(echo "$value" | xargs)"
    # Remove surrounding quotes from value
    value="${value#\"}" ; value="${value%\"}"
    value="${value#\'}" ; value="${value%\'}"
    ENV_VARS["$key"]="$value"
  done < "$ENV_FILE"
fi

# Generate deterministic UUID v5 from directory name if not provided
if [[ -z "$APP_ID" ]]; then
  # Check .env for APP_ID
  if [[ -n "${ENV_VARS[APP_ID]:-}" ]]; then
    APP_ID="${ENV_VARS[APP_ID]}"
  else
    APP_ID="$(python3 -c "import uuid; print(uuid.uuid5(uuid.NAMESPACE_URL, 'cowork-plugin://$PLUGIN_DIR'))")"
  fi
fi

# Output zip path
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="$SCRIPT_DIR/$PLUGIN_DIR.zip"
fi

# --- Build manifest.json from template ---
echo "Building manifest from template..."
MANIFEST_CONTENT="$(cat "$TEMPLATE")"
MANIFEST_CONTENT="${MANIFEST_CONTENT//\{\{ID\}\}/$APP_ID}"

# Find all placeholders in the template
PLACEHOLDERS="$(echo "$MANIFEST_CONTENT" | grep -oP '\{\{[A-Z_]+\}\}' | sort -u || true)"

# Replace each placeholder using precedence: CLI --var > env var > .env file
for placeholder in $PLACEHOLDERS; do
  # Extract the key name (strip {{ and }})
  key="${placeholder#\{\{}"
  key="${key%\}\}}"

  value=""
  # Highest precedence: CLI --var flags
  if [[ -n "${CLI_VARS[$key]:-}" ]]; then
    value="${CLI_VARS[$key]}"
  # Middle precedence: environment variables
  elif [[ -n "${!key:-}" ]]; then
    value="${!key}"
  # Lowest precedence: .env file
  elif [[ -n "${ENV_VARS[$key]:-}" ]]; then
    value="${ENV_VARS[$key]}"
  fi

  if [[ -n "$value" ]]; then
    MANIFEST_CONTENT="${MANIFEST_CONTENT//\{\{${key}\}\}/$value}"
  fi
done

# Warn about remaining placeholders
REMAINING="$(echo "$MANIFEST_CONTENT" | grep -oP '\{\{[A-Z_]+\}\}' | sort -u || true)"
if [[ -n "$REMAINING" ]]; then
  echo "Warning: Unreplaced placeholders found:"
  echo "$REMAINING"
  echo "Provide values via options or environment variables."
  exit 1
fi

echo "$MANIFEST_CONTENT" > "$PLUGIN_PATH/manifest.json"
echo "  -> $PLUGIN_PATH/manifest.json"

# --- Validate required files ---
for icon in color.png outline.png; do
  if [[ ! -f "$PLUGIN_PATH/$icon" ]]; then
    echo "Warning: $icon not found in $PLUGIN_DIR (required for store submission)"
  fi
done

if [[ ! -d "$PLUGIN_PATH/skills" ]]; then
  echo "Warning: skills/ directory not found in $PLUGIN_DIR"
fi

# --- Create zip package ---
echo "Packaging..."
rm -f "$OUTPUT"
(cd "$PLUGIN_PATH" && zip -r "$OUTPUT" manifest.json color.png outline.png skills/ references/ 2>/dev/null)
echo "  -> $OUTPUT"

echo ""
echo "Done! Package contents:"
unzip -l "$OUTPUT" | tail -n +4 | head -n -2
echo ""
echo "App ID: $APP_ID"
