$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$bytes = [System.IO.File]::ReadAllBytes($v1)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

Write-Host "Before: $([Math]::Round($bytes.Length/1KB,1)) KB, non-ASCII: $(($raw.ToCharArray() | Where-Object {[int]$_ -gt 127}).Count)"

# Replace specific non-ASCII chars with safe ASCII equivalents
# Focus only on chars that cause Postman parser failure
$pairs = @(
    @(0x2192, '->'),    # ? (arrow)
    @(0x2014, '--'),    # ? (em dash)
    @(0x2013, '-'),     # ? (en dash)
    @(0x2705, '[OK]'),  # ? (check mark)
    @(0x274C, '[X]'),   # ? (X mark)
    @(0x26A0, '[!]'),   # ? (warning)
    @(0xFE0F, ''),      # (variation selector)
    @(0x23F1, ''),      # ? (timer)
    @(0x2026, '...'),   # ? (ellipsis)
    @(0x201C, '"'),     # ? (left curly quote)
    @(0x201D, '"'),     # ? (right curly quote)
    @(0x2018, "'"),     # ? (left single quote)
    @(0x2019, "'")      # ? (right single quote)
)

foreach ($pair in $pairs) {
    $charVal = [char]$pair[0]
    $replacement = $pair[1]
    if ($raw.Contains([string]$charVal)) {
        $count = ([regex]::Matches($raw, [regex]::Escape([string]$charVal))).Count
        Write-Host "  Replacing U+$($pair[0].ToString('X4')) ($count occurrences) -> '$replacement'"
        $raw = $raw.Replace([string]$charVal, $replacement)
    }
}

# Final catch-all for any remaining non-ASCII (surrogate pairs, etc.)
$sb = New-Object System.Text.StringBuilder
$remaining = 0
foreach ($c in $raw.ToCharArray()) {
    if ([int]$c -le 127) {
        [void]$sb.Append($c)
    } else {
        $remaining++
        # Don't add a replacement - just skip these (they're invisible/control chars)
        # Unless it's a printable char we missed
        [void]$sb.Append('?')
    }
}
$raw = $sb.ToString()

Write-Host "Catch-all removed: $remaining chars"
Write-Host "After non-ASCII: $(($raw.ToCharArray() | Where-Object {[int]$_ -gt 127}).Count)"

# Remove lone ? that appeared where emoji were (they're inside JSON strings so safe to remove)
# Only remove ? that appear to be emoji placeholders (preceded by space or apostrophe in strings)
$raw = $raw -replace " \?([A-Za-z])", " `$1"
$raw = $raw -replace "'\?([A-Za-z])", "'`$1"
$raw = $raw -replace '"\?([A-Za-z])', '"`$1'

# Validate basic JSON structure
$startsOk = $raw.TrimStart()[0] -eq '{'
$endsOk = $raw.TrimEnd()[-1] -eq '}'
$hasPostmanId = $raw.Contains('"_postman_id"')
$hasEvent = $raw.Contains('"event"')
$hasItem = $raw.Contains('"item"')

Write-Host "Starts with '{': $startsOk"
Write-Host "Ends with '}': $endsOk"
Write-Host "Has _postman_id: $hasPostmanId"
Write-Host "Has event: $hasEvent"  
Write-Host "Has item: $hasItem"
Write-Host "Final size: $([Math]::Round($raw.Length/1KB,1)) KB"

# Write back
[System.IO.File]::WriteAllText($v1, $raw, $utf8NoBom)
Write-Host "Written successfully: $v1"
