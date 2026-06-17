#!/bin/bash
set -e
set -u

# ANSI colors
RED="\033[91m"
GREEN="\033[92m"
YELLOW="\033[93m"
BLUE="\033[94m"
CYAN="\033[96m"
BOLD="\033[1m"
RESET="\033[0m"

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "unknown")

# Detect OS
OS_TYPE="$(uname -s 2>/dev/null || echo "Unknown")"
case "$OS_TYPE" in
  Linux*)   OS_LABEL="Linux" ;;
  Darwin*)  OS_LABEL="macOS" ;;
  CYGWIN*|MINGW*|MSYS*) OS_LABEL="Windows/WSL" ;;
  *)        OS_LABEL="Unknown" ;;
esac

# Check python3
if ! command -v python3 &>/dev/null; then
  echo -e "${RED}${BOLD}✗ Error:${RESET}${RED} python3 is not installed or not in PATH.${RESET}"
  echo -e "${YELLOW}  Install Python 3 from https://www.python.org/downloads/${RESET}"
  exit 1
fi

# Check search.py exists
if [ ! -f "$SCRIPT_DIR/search.py" ]; then
  echo -e "${RED}${BOLD}✗ Error:${RESET}${RED} search.py not found in $SCRIPT_DIR${RESET}"
  exit 1
fi

# Require query argument
if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  echo -e "${CYAN}${BOLD}"
  echo "  ╔══════════════════════════════════╗"
  echo "  ║   🔍  CHAWSEEK v${VERSION}             ║"
  echo "  ║      Smart File Search           ║"
  echo "  ╚══════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "${YELLOW}Usage:${RESET}  chawseek <query>"
  echo -e "${YELLOW}Example:${RESET} chawseek \"def main\""
  exit 1
fi

QUERY="$1"

# Print branded header
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║        🔍  CHAWSEEK v${VERSION}                ║"
echo "  ║           Smart File Search              ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  ${BOLD}Query:${RESET}    ${GREEN}${QUERY}${RESET}"
echo -e "  ${BOLD}Location:${RESET} ${BLUE}${HOME}${RESET}"
echo -e "  ${BOLD}OS:${RESET}       ${YELLOW}${OS_LABEL}${RESET}"
echo ""

exec python3 "$SCRIPT_DIR/search.py" "$QUERY" "$HOME"
