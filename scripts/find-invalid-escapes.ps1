# The error "parsing [\u{1F600}-\u{1F9FF}]" means there's a literal string
# in the JSON that contains [\u{...}] which is NOT valid JSON unicode escape syntax
# (JSON uses \uXXXX not \u{XXXXX})
# Find and fix this exact pattern

$files = @(
    "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json",
    "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
)

foreach ($file in $files) {
    $name = Split-Path $file -Leaf
    Write-Host "=== $name ==="
    
    $bytes = [System.IO.File]::ReadAllBytes($file)
    
    # Strip BOM if present
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
        Write-Host "BOM stripped"
    } else {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    
    # Find occurrences of \u{ which is the problematic pattern
    $pattern = '\\u\{'
    $matches = [regex]::Matches($raw, $pattern)
    Write-Host "Found $($matches.Count) occurrences of \u{ (invalid JSON escape)"
    
    foreach ($m in $matches) {
        $ctx = $raw.Substring([Math]::Max(0,$m.Index-30), [Math]::Min(80, $raw.Length - [Math]::Max(0,$m.Index-30)))
        Write-Host "  Position $($m.Index): $ctx"
    }
    
    # Also find literal surrogate pairs in test scripts that break JSON
    $surrogates = [regex]::Matches($raw, '[\uD800-\uDFFF]')
    Write-Host "Found $($surrogates.Count) surrogate code units"
    
    Write-Host ""
}
