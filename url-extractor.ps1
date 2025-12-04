<#
.SYNOPSIS
Extract HTTP/HTTPS URLs from text, HTML fragments, files, or the clipboard.

.DESCRIPTION
Parses plain text, markdown links, and HTML anchor tags to collect unique URLs,
validates schemes, optionally writes results to a file, and can copy them back
to the clipboard. Designed for Windows PowerShell 5.1 without requiring
administrative privileges.

.PARAMETER InputText
Plain text content to scan. Accepts pipeline input.

.PARAMETER InputPath
Path to a file whose contents will be scanned for URLs.

.PARAMETER FromClipboard
Read HTML/text from the clipboard (CF_HTML and plain text formats).

.PARAMETER CopyToClipboard
Copy extracted URLs back to the clipboard.

.PARAMETER OutputPath
Optional file path to write extracted URLs (one per line).

.EXAMPLE
./url-extractor.ps1 -FromClipboard -CopyToClipboard

Extracts URLs from clipboard HTML/text, writes them to output, and copies them
back to the clipboard.

.EXAMPLE
"Check https://example.com and [docs](https://contoso.com/path)." | ./url-extractor.ps1

Scans pipeline text and writes the URLs to the pipeline.

.EXAMPLE
./url-extractor.ps1 -InputPath .\large_log.txt -OutputPath .\urls.txt

Scans a large file in chunks (memory efficient) and writes URLs to urls.txt.
#>

[CmdletBinding(DefaultParameterSetName = 'Input')]
param(
    [Parameter(ParameterSetName = 'Input', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string[]]$InputText,

    [Parameter(ParameterSetName = 'Input')]
    [ValidateNotNullOrEmpty()]
    [string]$InputPath,

    [Parameter(ParameterSetName = 'Clipboard')]
    [switch]$FromClipboard,

    [switch]$CopyToClipboard,

    [ValidateNotNullOrEmpty()]
    [string]$OutputPath
)

function Remove-TrailingPunctuation {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    return ($Url -replace '[)\]\}\.,!?;:''"]+$', '').Trim()
}

function Test-AndCleanUrl {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $cleaned = Remove-TrailingPunctuation -Url $Url
    if ([string]::IsNullOrWhiteSpace($cleaned)) {
        return $null
    }

    $uri = $null
    if (-not [Uri]::TryCreate($cleaned, [UriKind]::Absolute, [ref]$uri)) {
        return $null
    }

    if ($uri.Scheme -ne 'http' -and $uri.Scheme -ne 'https') {
        return $null
    }

    return $uri.AbsoluteUri
}

function Add-UniqueUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.HashSet[string]]$Seen,
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[string]]$Collector
    )

    if ($Seen.Add($Url)) {
        [void]$Collector.Add($Url)
    }
}

function Extract-HtmlUrls {
    param(
        [string]$HtmlContent,
        [System.Collections.Generic.HashSet[string]]$Seen,
        [System.Collections.Generic.List[string]]$Collector
    )

    if ([string]::IsNullOrWhiteSpace($HtmlContent)) {
        return
    }

    $hrefPattern = '<a\s+(?:[^>]*?\s+)?href\s*=\s*["''](?<url>[^"''#\s>]+)'
    foreach ($match in [regex]::Matches($HtmlContent, $hrefPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $rawUrl = [System.Net.WebUtility]::HtmlDecode($match.Groups['url'].Value)
        $validated = Test-AndCleanUrl -Url $rawUrl
        if ($validated) {
            Add-UniqueUrl -Url $validated -Seen $Seen -Collector $Collector
        }
    }
}

function Extract-MarkdownUrls {
    param(
        [string]$PlainText,
        [System.Collections.Generic.HashSet[string]]$Seen,
        [System.Collections.Generic.List[string]]$Collector
    )

    if ([string]::IsNullOrWhiteSpace($PlainText)) {
        return
    }

    $markdownRegex = '\[(?:[^\]]*)\]\((https?:\/\/[^\s)]+)\)'
    foreach ($match in [regex]::Matches($PlainText, $markdownRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $validated = Test-AndCleanUrl -Url $match.Groups[1].Value
        if ($validated) {
            Add-UniqueUrl -Url $validated -Seen $Seen -Collector $Collector
        }
    }
}

function Extract-PlainUrls {
    param(
        [string]$PlainText,
        [System.Collections.Generic.HashSet[string]]$Seen,
        [System.Collections.Generic.List[string]]$Collector
    )

    if ([string]::IsNullOrWhiteSpace($PlainText)) {
        return
    }

    $markdownRegex = '\[(?:[^\]]*)\]\((https?:\/\/[^\s)]+)\)'
    $textWithoutMarkdown = [regex]::Replace($PlainText, $markdownRegex, [string]::Empty)
    $plainUrlPattern = '\bhttps?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*)'
    foreach ($match in [regex]::Matches($textWithoutMarkdown, $plainUrlPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $validated = Test-AndCleanUrl -Url $match.Value
        if ($validated) {
            Add-UniqueUrl -Url $validated -Seen $Seen -Collector $Collector
        }
    }
}

function Get-HtmlFragment {
    [OutputType([string])]
    param([string]$RawHtml)

    if ([string]::IsNullOrWhiteSpace($RawHtml)) {
        return $null
    }

    $startOffsetMatch = [regex]::Match($RawHtml, 'StartFragment:(\d+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $endOffsetMatch = [regex]::Match($RawHtml, 'EndFragment:(\d+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($startOffsetMatch.Success -and $endOffsetMatch.Success) {
        $startOffset = [int]$startOffsetMatch.Groups[1].Value
        $endOffset = [int]$endOffsetMatch.Groups[1].Value
        if ($startOffset -ge 0 -and $endOffset -gt $startOffset -and $endOffset -le $RawHtml.Length) {
            return $RawHtml.Substring($startOffset, $endOffset - $startOffset)
        }
    }

    $startMarker = '<!--StartFragment-->'
    $endMarker = '<!--EndFragment-->'
    $startIndex = $RawHtml.IndexOf($startMarker)
    $endIndex = $RawHtml.IndexOf($endMarker)

    if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
        $contentStart = $startIndex + $startMarker.Length
        $contentEnd = $endIndex
        if ($contentEnd -gt $contentStart) {
            return $RawHtml.Substring($contentStart, $contentEnd - $contentStart)
        }
    }

    return $RawHtml
}

function Remove-ScriptContent {
    [OutputType([string])]
    param([string]$Content)

    if ([string]::IsNullOrWhiteSpace($Content)) {
        return $null
    }

    return [System.Text.RegularExpressions.Regex]::Replace(
        $Content,
        '<script[^>]*?>.*?<\/script>',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
}

function Process-TextChunk {
    param(
        [string]$Content,
        [System.Collections.Generic.HashSet[string]]$Seen,
        [System.Collections.Generic.List[string]]$Collector
    )

    if ([string]::IsNullOrWhiteSpace($Content)) {
        return
    }

    $safeContent = Remove-ScriptContent -Content $Content

    $looksLikeHtml = $safeContent -match '<\s*\w+[^>]*>' -or $safeContent -match '<!--'
    if ($looksLikeHtml) {
        Extract-HtmlUrls -HtmlContent $safeContent -Seen $Seen -Collector $Collector
    }
    Extract-MarkdownUrls -PlainText $safeContent -Seen $Seen -Collector $Collector
    Extract-PlainUrls -PlainText $safeContent -Seen $Seen -Collector $Collector
}

function Write-Results {
    param(
        [string[]]$Urls,
        [switch]$CopyToClipboard,
        [string]$OutputPath
    )

    if (-not $Urls -or $Urls.Count -eq 0) {
        Write-Verbose 'No URLs found.'
        return
    }

    $ordered = $Urls
    $ordered | ForEach-Object { Write-Output $_ }

    if ($OutputPath) {
        $outputDirectory = Split-Path -Parent $OutputPath
        if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
        }

        $ordered -join [Environment]::NewLine | Set-Content -LiteralPath $OutputPath -Encoding UTF8 -ErrorAction Stop
    }

    if ($CopyToClipboard) {
        try {
            Set-Clipboard -Value ($ordered -join [Environment]::NewLine) -ErrorAction Stop
            Write-Verbose ("Copied {0} URL(s) to clipboard." -f $ordered.Count)
        }
        catch {
            Write-Warning 'Failed to copy URLs to clipboard.'
        }
    }
}

$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$collector = New-Object 'System.Collections.Generic.List[string]'
$inputSeen = $false

process {
    if ($null -ne $_) {
        if (-not [string]::IsNullOrWhiteSpace([string]$_)) {
            $inputSeen = $true
            Process-TextChunk -Content ([string]$_) -Seen $seen -Collector $collector
        }
    }
}

end {
    if ($PSBoundParameters.ContainsKey('InputText') -and $InputText) {
        foreach ($segment in $InputText) {
            if (-not [string]::IsNullOrWhiteSpace($segment)) {
                $inputSeen = $true
                Process-TextChunk -Content $segment -Seen $seen -Collector $collector
            }
        }
    }

    if ($InputPath) {
        if (-not (Test-Path -LiteralPath $InputPath)) {
            throw [System.IO.FileNotFoundException]::new("Input path '$InputPath' does not exist.")
        }

        Get-Content -LiteralPath $InputPath -ReadCount 2000 | ForEach-Object {
            $chunk = $_ -join [Environment]::NewLine
            if (-not [string]::IsNullOrWhiteSpace($chunk)) {
                $inputSeen = $true
                Process-TextChunk -Content $chunk -Seen $seen -Collector $collector
            }
        }
    }

    if ($FromClipboard) {
        try {
            $clipboardText = Get-Clipboard -Raw -ErrorAction Stop
            if ($clipboardText) {
                $inputSeen = $true
                Process-TextChunk -Content $clipboardText -Seen $seen -Collector $collector
            }
        }
        catch {
            Write-Warning 'Failed to read text from clipboard.'
        }

        try {
            $clipboardHtml = Get-Clipboard -Format Html -ErrorAction Stop
            if ($clipboardHtml) {
                $htmlFragment = Get-HtmlFragment -RawHtml $clipboardHtml
                if ($htmlFragment) {
                    $inputSeen = $true
                    Process-TextChunk -Content $htmlFragment -Seen $seen -Collector $collector
                }
            }
        }
        catch {
            Write-Verbose 'HTML clipboard format not available.'
        }
    }

    if (-not $inputSeen) {
        Write-Warning 'No input provided. Supply text, a path, pipeline input, or use -FromClipboard.'
        return
    }

    Write-Results -Urls $collector.ToArray() -CopyToClipboard:$CopyToClipboard -OutputPath $OutputPath
    Write-Verbose ("Found {0} URL(s)." -f $collector.Count)
}
