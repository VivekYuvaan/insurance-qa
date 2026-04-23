# Find all emoji/unicode escape sequences that are problematic in JSON
$files = @(
    "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json",
    "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
)

foreach ($file in $files) {
    $name = Split-Path $file -Leaf
    Write-Host "=== Scanning $name ==="
    
    $bytes = [System.IO.File]::ReadAllBytes($file)
    
    # Strip BOM if present
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "BOM: YES (stripping)"
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        Write-Host "BOM: NO"
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    
    # Find all non-ASCII characters and their positions
    $nonAsciiMatches = [regex]::Matches($raw, '[^\x00-\x7F]')
    if ($nonAsciiMatches.Count -gt 0) {
        Write-Host "Non-ASCII chars found: $($nonAsciiMatches.Count)"
        $shown = 0
        foreach ($m in $nonAsciiMatches) {
            if ($shown -lt 20) {
                $ctx = $raw.Substring([Math]::Max(0,$m.Index-20), [Math]::Min(50, $raw.Length - [Math]::Max(0,$m.Index-20)))
                Write-Host "  Pos $($m.Index): '$($m.Value)' (U+$('{0:X4}' -f [int][char]$m.Value)) in: $ctx"
                $shown++
            }
        }
        if ($nonAsciiMatches.Count -gt 20) {
            Write-Host "  ... and $($nonAsciiMatches.Count - 20) more"
        }
    } else {
        Write-Host "Non-ASCII chars: NONE"
    }
    Write-Host ""
}
