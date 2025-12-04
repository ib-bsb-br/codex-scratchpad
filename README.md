# URL Extractor (PowerShell)

PowerShell 5.1 script that extracts unique HTTP/HTTPS URLs from clipboard HTML/plain text, files, or supplied input values. Results are printed, optionally saved to a file, and can be copied back to the clipboard for normal (non-admin) Windows users.

## Usage

Run in Windows PowerShell 5.1:

```powershell
# Extract from clipboard (HTML/plain text) and copy results back to clipboard
./url-extractor.ps1 -FromClipboard -CopyToClipboard

# Provide plain text directly and skip clipboard copy
./url-extractor.ps1 -InputText "Check https://example.com and [docs](https://contoso.com/path)." -CopyToClipboard:$false

# Read from a file, write results to another file, and avoid clipboard operations
./url-extractor.ps1 -InputPath .\input.txt -OutputPath .\urls.txt -CopyToClipboard:$false

# Pipeline input is supported
"Visit https://example.com" | ./url-extractor.ps1
```

## Behavior

- Validates URLs using `System.Uri` and only accepts `http` or `https` schemes.
- Cleans trailing punctuation such as `)` or `.` that commonly follow URLs.
- Extracts URLs from anchor tags in HTML (including clipboard CF_HTML fragments), markdown links, and plain text while removing inline `<script>` content.
- Accepts input from pipeline text, parameters, files, or clipboard HTML/text without requiring administrative privileges.
- Optionally writes URLs to a specified output path and copies results back to the clipboard when requested.
- Deduplicates URLs case-insensitively and exposes comment-based help for Get-Help usage.
