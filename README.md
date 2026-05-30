# cowork-plugin-sample

Sample plugins for [Microsoft 365 Copilot Cowork](https://learn.microsoft.com/en-us/microsoft-365/copilot/cowork/cowork-plugin-development#build-a-plugin-from-scratch).

## Plugins

| Plugin | Description |
|--------|-------------|
| `market-intelligence` | Skills-only plugin for market trends and economic insights |
| `investment-advisor-tools` | Skills + MCP connectors for Yahoo Finance data, Foundry agent integration, and PowerPoint generation |

### investment-advisor-tools

This plugin bundles three skills and two MCP server connectors:

**Skills:**

| Skill | Description | Connector |
|-------|-------------|-----------|
| `stock-lookup` | Looks up stock information (price, volume, market cap, trends) | `yahoo-finance-api` |
| `investment-advisor-copilot` | Delegates to a Foundry agent for portfolio analysis and macro/markets strategy | `foundry-mcp` |
| `powerpoint-template` | Generates PowerPoint presentations using a bundled master slide template (`assets/template3.pptx`) | — |

**Agent Connectors:**

| Connector | Auth Type | Description |
|-----------|-----------|-------------|
| `yahoo-finance-api` | None (or via APIM) | Yahoo Finance MCP server for stock data |
| `foundry-mcp` | OAuthPluginVault | Foundry agent MCP server for investment advisory |

### market-intelligence

A skills-only plugin (no connectors) providing market trends and economic insights.

## Building a Plugin Package

Use `build.sh` to generate `manifest.json` from a template and package everything into a `.zip` ready for sideloading.

### Prerequisites

- `zip` CLI tool
- `python3` (for auto-generating app IDs)

### Usage

```bash
./build.sh <plugin-dir> [options]
```

### Options

| Option | Description |
|--------|-------------|
| `--id <guid>` | App ID (default: auto-generated UUID) |
| `--var KEY=VALUE` | Set a template variable (replaces `{{KEY}}` with `VALUE`). Repeatable. |
| `--output <path>` | Output zip path (default: `<plugin-dir>.zip`) |
| `--no-env` | Skip loading the `.env` file |

### Variable Precedence

Values are resolved in this order (highest to lowest):

1. **`--var` flags**
2. **Environment variables** matching the placeholder name
3. **`.env` file** in the plugin directory

Any `{{KEY}}` placeholder in the template is automatically matched against all three sources.

### Using a `.env` File

Place a `.env` file in the plugin directory to avoid passing secrets on the command line:

```bash
# investment-advisor-tools/.env
YAHOO_MCP_SERVER_URL=https://your-yahoo-mcp.example.com/mcp
FOUNDRY_MCP_SERVER_URL=https://your-foundry-mcp.example.com/mcp
FOUNDRY_AUTH_REFERENCE_ID=your-oauth-registration-id
APP_ID=a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

Then simply run:

```bash
./build.sh investment-advisor-tools
```

> **Note:** `.env` files are git-ignored by default.

### Examples

**Skills-only plugin (no connector):**

```bash
./build.sh market-intelligence
```

**Plugin with multiple MCP connectors:**

```bash
./build.sh investment-advisor-tools \
  --var YAHOO_MCP_SERVER_URL="https://your-yahoo-mcp.example.com/mcp" \
  --var FOUNDRY_MCP_SERVER_URL="https://your-foundry-mcp.example.com/mcp" \
  --var FOUNDRY_AUTH_REFERENCE_ID="your-oauth-registration-id"
```

**Using environment variables:**

```bash
export YAHOO_MCP_SERVER_URL="https://your-yahoo-mcp.example.com/mcp"
export FOUNDRY_MCP_SERVER_URL="https://your-foundry-mcp.example.com/mcp"
export FOUNDRY_AUTH_REFERENCE_ID="your-oauth-registration-id"
./build.sh investment-advisor-tools
```

The script will error if any `{{PLACEHOLDER}}` values remain unreplaced in the generated manifest.

### Output

The script produces a `.zip` in the repo root containing:

```
<plugin-dir>.zip
├── manifest.json
├── color.png
├── outline.png
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── references/        # MCP tool descriptions (JSON)
│       └── assets/            # Static resources (templates, etc.)
└── references/                # (if present at plugin root)
```

### Testing

Sideload the `.zip` for testing:

1. Open **M365 Admin Center** > **All Agents** > **...** > **Add agent** > **Upload custom app**
2. Upload the generated `.zip` package
3. Open Cowork > **Sources & Skills** — your skills should appear

