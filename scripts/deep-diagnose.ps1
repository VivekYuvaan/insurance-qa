$baseline = "d:/insurance-qa/collections/insurance-original-baseline.json"
$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"
$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"

foreach ($file in @($baseline, $v1, $v2)) {
    $name = Split-Path $file -Leaf
    $exists = Test-Path $file
    if (-not $exists) { Write-Host "$name : FILE NOT FOUND"; continue }
    
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    
    if ($hasBOM) {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }

    # Count non-ASCII chars
    $nonAscii = 0
    foreach ($c in $raw.ToCharArray()) { if ([int]$c -gt 127) { $nonAscii++ } }

    # Check for \uXXXXX (5-hex-digit) which is invalid in JSON
    $fiveDigitUnicode = [regex]::Matches($raw, '\\u[0-9a-fA-F]{5}').Count

    # Check for unescaped control chars in strings (tab, newline within strings - common JSON corruption)
    $unescapedTabs = [regex]::Matches($raw, '"[^"]*\t[^"]*"').Count

    # Check for invalid \r\n in strings (should be \\r\\n not literal)
    $literalNewlines = 0
    $inString = $false
    $prev = ' '
    foreach ($c in $raw.ToCharArray()) {
        if ($c -eq '"' -and $prev -ne '\') { $inString = -not $inString }
        if ($inString -and ($c -eq "`n" -or $c -eq "`r")) { $literalNewlines++ }
        $prev = $c
    }

    # Count \r\n sequences (should only appear as \\r\\n inside JSON strings)
    $crlf = [regex]::Matches($raw, '\r\n').Count
    $lf = [regex]::Matches($raw, '(?<!\r)\n').Count

    Write-Host "=== $name ==="
    Write-Host "  Size          : $([Math]::Round($bytes.Length/1KB,1)) KB"
    Write-Host "  BOM           : $hasBOM"
    Write-Host "  Non-ASCII     : $nonAscii"
    Write-Host "  5-digit \\uXXXXX: $fiveDigitUnicode"
    Write-Host "  Unescaped tabs: $unescapedTabs"
    Write-Host "  Literal newlines in strings: $literalNewlines"
    Write-Host "  CRLF line endings: $crlf"
    Write-Host "  LF line endings : $lf"
    Write-Host "  Starts with '{': $($raw.TrimStart()[0] -eq '{')"
    Write-Host "  Ends with '}': $($raw.TrimEnd()[-1] -eq '}')"
    Write-Host ""
}
