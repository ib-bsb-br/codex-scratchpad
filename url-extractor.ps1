<#
.SYNOPSIS
Extracts HTTP and HTTPS URLs from text, HTML fragments, files, or the clipboard.

.DESCRIPTION
Parses plain text, markdown links, and HTML anchor tags to collect unique URLs,
validates schemes, optionally writes results to a file, and can copy them back
to the clipboard. Designed for Windows PowerShell 5.1 without requiring
administrative privileges.
#>

[CmdletBinding(DefaultParameterSetName = 'Input')]
param(
    [Parameter(ParameterSetName = 'Input', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string[]]$InputText,

    [Parameter(ParameterSetName = 'Input')]
    [string]$InputPath,

    [Parameter(ParameterSetName = 'Clipboard')]
    [switch]$FromClipboard,

    [switch]$CopyToClipboard,

    [string]$OutputPath
)

function Remove-TrailingPunctuation {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    return ($Url -replace "[)\]\}\.,!?;:'\"]+$", '').Trim()
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
        $Collector.Add($Url) | Out-Null
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

    $hrefPattern = '<a\s+(?:[^>]*?\s+)?href\s*=\s*["\'](?<url>[^"\'#\s>]+)'
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

    $plainUrlPattern = '\bhttps?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)'
    foreach ($match in [regex]::Matches($PlainText, $plainUrlPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
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

    $startMarker = '<!--StartFragment'
    $endMarker = '<!--EndFragment'
    $startIndex = $RawHtml.IndexOf($startMarker)
    $endIndex = $RawHtml.IndexOf($endMarker)

    if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
        $fragmentStart = $RawHtml.IndexOf('>', $startIndex)
        $fragmentEnd = $RawHtml.IndexOf('<', $endIndex)
        if ($fragmentStart -ge 0 -and $fragmentEnd -gt $fragmentStart) {
            return $RawHtml.Substring($fragmentStart + 1, $fragmentEnd - $fragmentStart - 1)
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

function Resolve-InputContent {
    [OutputType([PSCustomObject])]
    param(
        [string[]]$InputTextSegments,
        [string]$InputPath,
        [switch]$FromClipboard
    )

    $plainSegments = New-Object System.Collections.Generic.List[string]
    $htmlSegments = New-Object System.Collections.Generic.List[string]

    if ($InputTextSegments) {
        $plainSegments.AddRange($InputTextSegments)
    }

    if ($InputPath) {
        if (-not (Test-Path -LiteralPath $InputPath)) {
            throw "Input path '$InputPath' does not exist."
        }

        $fileContent = Get-Content -LiteralPath $InputPath -Raw -ErrorAction Stop
        if ($fileContent) {
            $plainSegments.Add($fileContent)
        }
    }

    if ($FromClipboard) {
        try {
            $clipboardText = Get-Clipboard -Raw -ErrorAction Stop
            if ($clipboardText) {
                $plainSegments.Add($clipboardText)
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
                    $htmlSegments.Add($htmlFragment)
                }
            }
        }
        catch {
            Write-Verbose 'HTML clipboard format not available.'
        }
    }

    $combinedPlain = [string]::Join([Environment]::NewLine, $plainSegments)
    $combinedHtml = [string]::Join([Environment]::NewLine, $htmlSegments)

    if ([string]::IsNullOrWhiteSpace($combinedHtml) -and ($combinedPlain -match '<html|<body|<div|<a\s+')) {
        $combinedHtml = $combinedPlain
    }

    return [PSCustomObject]@{
        Plain = $combinedPlain
        Html   = Remove-ScriptContent -Content $combinedHtml
    }
}

function Extract-Urls {
    [OutputType([string[]])]
    param(
        [string]$HtmlContent,
        [string]$PlainText
    )

    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    $collector = New-Object 'System.Collections.Generic.List[string]'

    Extract-HtmlUrls -HtmlContent $HtmlContent -Seen $seen -Collector $collector
    Extract-MarkdownUrls -PlainText $PlainText -Seen $seen -Collector $collector
    Extract-PlainUrls -PlainText $PlainText -Seen $seen -Collector $collector

    return $collector.ToArray()
}

function Write-Results {
    param(
        [string[]]$Urls,
        [switch]$CopyToClipboard,
        [string]$OutputPath
    )

    if (-not $Urls -or $Urls.Count -eq 0) {
        Write-Host 'No URLs found.' -ForegroundColor Yellow
        return
    }

    $ordered = $Urls | Sort-Object -Unique
    $output = $ordered -join [Environment]::NewLine
    $ordered | ForEach-Object { Write-Output $_ }

    if ($OutputPath) {
        $outputDirectory = Split-Path -Parent $OutputPath
        if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
        }

        $output | Set-Content -LiteralPath $OutputPath -Encoding UTF8 -ErrorAction Stop
    }

    if ($CopyToClipboard) {
        try {
            $output | Set-Clipboard -ErrorAction Stop
            Write-Verbose ("Copied {0} URL(s) to clipboard." -f $ordered.Count)
        }
        catch {
            Write-Warning 'Failed to copy URLs to clipboard.'
        }
    }
}

begin {
    $pipelineBuffer = New-Object System.Collections.Generic.List[string]
}

process {
    if ($null -ne $_) {
        $pipelineBuffer.Add([string]$_)
    }
}

end {
    $inputSegments = @()
    if ($pipelineBuffer.Count -gt 0) {
        $inputSegments += $pipelineBuffer
    }

    if ($PSBoundParameters.ContainsKey('InputText') -and $InputText) {
        $inputSegments += $InputText
    }

    $resolvedContent = Resolve-InputContent -InputTextSegments $inputSegments -InputPath $InputPath -FromClipboard:$FromClipboard

    if ([string]::IsNullOrWhiteSpace($resolvedContent.Plain) -and [string]::IsNullOrWhiteSpace($resolvedContent.Html)) {
        Write-Warning 'No input provided. Supply text, a path, pipeline input, or use -FromClipboard.'
        return
    }

    $urls = Extract-Urls -HtmlContent $resolvedContent.Html -PlainText $resolvedContent.Plain

    Write-Results -Urls $urls -CopyToClipboard:$CopyToClipboard -OutputPath $OutputPath
    Write-Host ("Found {0} URL(s)." -f ($urls | Sort-Object -Unique).Count)
}
