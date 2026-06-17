# 🔍 Chawseek — Smart Local File Search

Chawseek is a fast, terminal-based file search tool that searches **file contents and filenames** across your home directory, categorized by file type with colorized output.

---

## Requirements

| Requirement | Required | Notes |
|---|---|---|
| Bash | Yes | v3.2+ |
| Python 3 | Yes | Standard library only |
| pdftotext | Optional | For PDF content search — install via poppler |

---

## Install

```bash
git clone https://github.com/samsouta/chawseek.git
cd chawseek
bash install.sh
```

`install.sh` will:
- Verify Python 3 is installed
- Install `pdftotext` via Homebrew (macOS) or apt (Linux) if missing
- Make `chawseek.sh` executable
- Symlink it to `/usr/local/bin/chawseek` so it's available system-wide

---

## Usage

```bash
chawseek "<query>"
```

### Examples

```bash
# Search for a function definition
chawseek "def main"

# Find files containing a keyword
chawseek "TODO"

# Find files by name
chawseek "resume"

# Search for config values
chawseek "DATABASE_URL"
```

---

## Supported File Types

| Category | Extensions |
|---|---|
| 📄 PDF | `.pdf` |
| 📝 Notes | `.txt`, `.md` |
| 💻 Code | `.js`, `.py`, `.sh`, `.ts`, `.jsx`, `.tsx`, `.go`, `.rb` |
| 🔎 Filename | Any file where the filename matches the query |

---

## How It Works

1. `chawseek.sh` validates the environment, prints the branded header, and calls `search.py`
2. `search.py` walks your home directory with `os.walk()`, skipping hidden folders and noise directories (`node_modules`, `.git`, `__pycache__`, etc.)
3. Results are grouped by category and printed with full file paths and the first matching line
4. PDF content search uses `pdftotext` via subprocess; if unavailable, PDFs are skipped with a warning

---

## Skipped Directories

To keep searches fast, Chawseek skips:

`node_modules` · `.git` · `__pycache__` · `.venv` · `dist` · `build` · `.cache` · `.npm` · any hidden folder (starting with `.`)
