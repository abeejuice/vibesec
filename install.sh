#!/bin/bash
# vibesec installer
# Usage: bash <(curl -s https://raw.githubusercontent.com/abeejuice/vibesec/main/install.sh)

REPO_URL="https://raw.githubusercontent.com/abeejuice/vibesec/main"
AGENT_PATH=".claude/agents/security.md"

echo ""
echo "🛡️  vibesec — Security Agent for Medical AI Builders"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create .claude/agents directory if it doesn't exist
mkdir -p .claude/agents

# Download the agent
echo "→ Installing vibesec agent..."
if curl -s --fail "${REPO_URL}/${AGENT_PATH}" -o "${AGENT_PATH}"; then
  echo "✓ Agent installed at ${AGENT_PATH}"
else
  echo "✗ Download failed. Check your internet connection or the repo URL."
  echo "  Manual install: copy .claude/agents/security.md into your project."
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ vibesec installed successfully."
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Type /vibesec to run a full security audit"
echo "  3. Open docs/vibe-coder-security-guide.html for the full interactive guide"
echo ""
echo "vibesec will also auto-trigger when you work on:"
echo "  auth · API keys · database queries · file uploads · health data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
