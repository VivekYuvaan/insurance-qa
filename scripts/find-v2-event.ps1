$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$raw = [System.IO.File]::ReadAllText($v2)

# Find the COLLECTION-LEVEL "event" key - it appears right after the item array closes
# The pattern is: ],\r\n  "event": [ OR ],\n  "event": [  (at depth 1 in JSON)
$collEventPatternCRLF = "],`r`n  `"event`": ["
$collEventPatternLF   = "],`n  `"event`": ["

$collEventPos = $raw.IndexOf($collEventPatternCRLF)
if ($collEventPos -lt 0) { $collEventPos = $raw.IndexOf($collEventPatternLF) }

Write-Host "Collection-level event starts after item array at: $collEventPos"

if ($collEventPos -lt 0) {
    Write-Host "No collection-level event found - different structure"
    # Check what's at the end of file
    Write-Host "Last 500 chars of file:"
    Write-Host $raw.Substring($raw.Length - 500)
} else {
    $afterEvent = $raw.Substring($collEventPos)
    Write-Host "Content at event boundary (400 chars):"
    Write-Host $afterEvent.Substring(0, [Math]::Min(400, $afterEvent.Length))
}
