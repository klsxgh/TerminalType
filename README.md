# TerminalType

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/karth-4eg5p15/TerminalType/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Scoop](https://img.shields.io/badge/Scoop-Extras-orange.svg)](https://github.com/ScoopInstaller/Extras)

A PowerShell-based typing speed test that challenges you with random words from a customizable `words.txt` file or classic predefined sentences and featuring adjustable time limits.

## Features
- Test your typing speed with **Words Per Minute (WPM)** and accuracy stats.
- Choose between **random words** from `words.txt` or **predefined sentences**.
- Set custom time limits (15, 30, 60 seconds, or your own choice).

### Testing It Locally
Let’s make sure it works without Scoop:
1. **Download the Files**:
   - Go to your GitHub repo.
   - Download `TerminalType.ps1` and `words.txt` to `C:\TerminalType\` (or any folder you like).
2. **Run It**:
   ```powershell
   cd C:\TerminalType
   powershell -ExecutionPolicy Bypass -File .\TerminalType.ps1
