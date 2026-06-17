#!/bin/bash
set -e

# ANSI colors
RED="\033[91m"
GREEN="\033[92m"
YELLOW="\033[93m"
CYAN="\033[96m"
BOLD="\033[1m"
RESET="\033[0m"

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     🔍  CHAWSEEK v1.0 — Installer       ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"

# Detect OS
OS_TYPE="$(uname -s 2>/dev/null || echo "Unknown")"
case "$OS_TYPE" in
  Linux*)   OS_LABEL="Linux" ;;
  Darwin*)  OS_LABEL="macOS" ;;
  CYGWIN*|MINGW*|MSYS*) OS_LABEL="Windows/WSL" ;;
  *)        OS_LABEL="Unknown" ;;
esac

echo -e "  ${BOLD}Detected OS:${RESET} ${YELLOW}${OS_LABEL}${RESET}"

# Check python3
echo -e "\n  ${BOLD}Checking python3...${RESET}"
if ! command -v python3 &>/dev/null; then
  echo -e "  ${RED}✗ python3 not found. Please install Python 3 first.${RESET}"
  exit 1
fi
PY_VER="$(python3 --version 2>&1)"
echo -e "  ${GREEN}✅ ${PY_VER}${RESET}"

# Check / install pdftotext
echo -e "\n  ${BOLD}Checking pdftotext (for PDF search)...${RESET}"
if ! command -v pdftotext &>/dev/null; then
  echo -e "  ${YELLOW}⚠️  pdftotext not found. Installing poppler...${RESET}"
  case "$OS_TYPE" in
    Darwin*)
      if command -v brew &>/dev/null; then
        brew install poppler
      else
        echo -e "  ${YELLOW}  Homebrew not found. Install it from https://brew.sh then run: brew install poppler${RESET}"
      fi
      ;;
    Linux*|CYGWIN*|MINGW*|MSYS*)
      sudo apt-get install -y poppler-utils
      ;;
    *)
      echo -e "  ${YELLOW}  Cannot auto-install poppler on $OS_LABEL. PDF search will be skipped.${RESET}"
      ;;
  esac
else
  echo -e "  ${GREEN}✅ pdftotext found${RESET}"
fi

# Make chawseek.sh executable
echo -e "\n  ${BOLD}Setting permissions...${RESET}"
chmod +x "$INSTALL_DIR/chawseek.sh"
echo -e "  ${GREEN}✅ chawseek.sh is executable${RESET}"

# Symlink to /usr/local/bin
echo -e "\n  ${BOLD}Installing to /usr/local/bin/chawseek...${RESET}"
if [ ! -d /usr/local/bin ]; then
  sudo mkdir -p /usr/local/bin
fi
sudo ln -sf "$INSTALL_DIR/chawseek.sh" /usr/local/bin/chawseek
echo -e "  ${GREEN}✅ Symlink created: /usr/local/bin/chawseek → $INSTALL_DIR/chawseek.sh${RESET}"

echo -e "\n${GREEN}${BOLD}  ✅ Chawseek installed successfully!${RESET}"
echo -e "  ${CYAN}Run it anywhere with:${RESET} ${BOLD}chawseek \"your query\"${RESET}\n"
