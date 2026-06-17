#!/usr/bin/env python3
import os
import sys
import time
import subprocess
import shutil

# ANSI colors — disabled when not a tty
if sys.stdout.isatty():
    RESET  = "\033[0m"
    BOLD   = "\033[1m"
    RED    = "\033[91m"
    GREEN  = "\033[92m"
    YELLOW = "\033[93m"
    BLUE   = "\033[94m"
    CYAN   = "\033[96m"
    DIM    = "\033[2m"
else:
    RESET = BOLD = RED = GREEN = YELLOW = BLUE = CYAN = DIM = ""

DIVIDER = f"{DIM}{'─' * 50}{RESET}"

SKIP_DIRS = {
    "node_modules", ".git", "__pycache__", ".venv",
    "dist", "build", ".cache", ".npm",
}

CODE_EXTS   = {".js", ".py", ".sh", ".ts", ".jsx", ".tsx", ".go", ".rb"}
NOTES_EXTS  = {".txt", ".md"}
PDF_EXT     = ".pdf"


def should_skip_dir(name: str) -> bool:
    return name.startswith(".") or name in SKIP_DIRS


def search_text_file(filepath: str, query: str) -> str | None:
    try:
        with open(filepath, encoding="utf-8", errors="ignore") as f:
            for line in f:
                if query.lower() in line.lower():
                    return line.strip()
    except (OSError, PermissionError):
        pass
    return None


def search_pdf(filepath: str, query: str) -> str | None:
    try:
        result = subprocess.run(
            ["pdftotext", filepath, "-"],
            capture_output=True, text=True, timeout=10
        )
        for line in result.stdout.splitlines():
            if query.lower() in line.lower():
                return line.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired, OSError):
        pass
    return None


def print_result(filename: str, filepath: str, match_line: str | None) -> None:
    print(f"  {GREEN}✅ {BOLD}{filename}{RESET}")
    print(f"  {BLUE}📍 {filepath}{RESET}")
    if match_line:
        truncated = match_line[:120] + ("…" if len(match_line) > 120 else "")
        print(f"  {DIM}📝 {truncated}{RESET}")
    print()


def print_section_header(title: str) -> None:
    print(DIVIDER)
    print(f"{BOLD}{CYAN}{title}{RESET}")
    print()


def main() -> None:
    if len(sys.argv) < 3:
        print(f"{RED}Usage: search.py <query> <root_dir>{RESET}", file=sys.stderr)
        sys.exit(1)

    query     = sys.argv[1]
    root_dir  = sys.argv[2]
    start     = time.time()

    pdf_results      = []
    notes_results    = []
    code_results     = []
    filename_results = []

    pdf_available = shutil.which("pdftotext") is not None
    pdf_warned    = False

    for dirpath, dirs, files in os.walk(root_dir):
        dirs[:] = [d for d in dirs if not should_skip_dir(d)]

        for filename in files:
            filepath = os.path.join(dirpath, filename)
            _, ext   = os.path.splitext(filename.lower())

            # Filename match (any file type)
            if query.lower() in filename.lower():
                filename_results.append((filename, filepath, None))

            # PDF content
            if ext == PDF_EXT:
                if not pdf_available:
                    if not pdf_warned:
                        print(
                            f"{YELLOW}⚠️  pdftotext not found — skipping PDF content search. "
                            f"Install with: brew install poppler (macOS) or "
                            f"sudo apt install poppler-utils (Linux){RESET}\n",
                            file=sys.stderr,
                        )
                        pdf_warned = True
                else:
                    match = search_pdf(filepath, query)
                    if match is not None:
                        pdf_results.append((filename, filepath, match))

            # Notes
            elif ext in NOTES_EXTS:
                match = search_text_file(filepath, query)
                if match is not None:
                    notes_results.append((filename, filepath, match))

            # Code
            elif ext in CODE_EXTS:
                match = search_text_file(filepath, query)
                if match is not None:
                    code_results.append((filename, filepath, match))

    total = len(pdf_results) + len(notes_results) + len(code_results) + len(filename_results)

    sections = [
        ("📄  PDF FILES",   pdf_results),
        ("📝  NOTES",       notes_results),
        ("💻  CODE",        code_results),
        ("🔎  FILENAME MATCHES", filename_results),
    ]

    for title, results in sections:
        if results:
            print_section_header(title)
            for item in results:
                print_result(*item)

    elapsed = time.time() - start
    print(DIVIDER)

    if total == 0:
        print(f"\n{YELLOW}😔 No results found for: {BOLD}{query}{RESET}\n")
    else:
        print(f"\n{GREEN}{BOLD}🏁 Found {total} result{'s' if total != 1 else ''} in {elapsed:.2f}s{RESET}\n")


if __name__ == "__main__":
    main()
