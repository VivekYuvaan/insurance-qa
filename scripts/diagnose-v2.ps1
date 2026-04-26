$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$raw = [System.IO.File]::ReadAllText($v2)

Write-Host "File size: $([Math]::Round($raw.Length/1KB,1)) KB"

# Find what folders are inside the event array (same bug as v1)
# The last "event": [ in the file is the COLLECTION-LEVEL event
$lastEventPos = $raw.LastIndexOf('"event": [')
Write-Host "Last event array at char: $lastEventPos"
Write-Host "Content after last event array start (200 chars):"
Write-Host $raw.Substring($lastEventPos, [Math]::Min(200, $raw.Length - $lastEventPos))

# Find all folder names that appear AFTER the last event array start
$folderPattern = '"name": "(\d{2} - [^"]+)"'
$allMatches = [regex]::Matches($raw, $folderPattern)
Write-Host "`nAll top-level folder names in file:"
foreach ($m in $allMatches) {
    $inEvent = $m.Index -gt $lastEventPos
    $marker = if ($inEvent) { " <-- INSIDE EVENT (WRONG)" } else { "" }
    Write-Host "  Pos $($m.Index): $($m.Value)$marker"
}
