$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$bytes = [System.IO.File]::ReadAllBytes($v2)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

# The file currently has \\r (JSON literal backslash+r) at end of each exec string line
# This results in JS seeing backslash+r which is a SyntaxError outside string literals
# Fix: simply remove all \\r" occurrences from the Create Client prerequest exec block

$execStart = 10342
$execClose = 11483

$oldExec = $raw.Substring($execStart, $execClose - $execStart + 1)
Write-Host "Old exec block length: $($oldExec.Length)"

# Remove \\r from end of each string (replace \r" with ")
# In the raw string, \\r" appears as: \\r" (4 chars: \,\,r,")
$fixedExec = $oldExec -replace '\\\\r"', '"'

# Also simplify - rewrite as a clean exec block with correct JSON escaping
# The \\ in PowerShell regex means literal \ so \\\\r matches two backslashes + r
Write-Host "Fixed exec block:"
Write-Host $fixedExec

$raw = $raw.Substring(0, $execStart) + $fixedExec + $raw.Substring($execClose + 1)

# Verify no more \\r in the prerequest area  
$prereqArea = $raw.Substring($execStart, $fixedExec.Length + 100)
if ($prereqArea -match '\\\\r"') {
    Write-Host "WARNING: \\r still found in prerequest"
} else {
    Write-Host "SUCCESS: No stray \\r in prerequest"
}

if ($raw.Contains("1985-06-15")) {
    Write-Host "dateOfBirth fallback still present: OK"
}

[System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
Write-Host "Written: $v2"
