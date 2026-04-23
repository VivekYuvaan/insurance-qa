$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$raw = [System.IO.File]::ReadAllText($v2)

Write-Host "File size: $([Math]::Round($raw.Length/1KB,1)) KB"

# Find the comma before the first misplaced folder (08) inside event
# v2 uses LF not CRLF
$cutMarker = "},`n    {`n      `"name`": `"08 - Security Tests`""
$cutPos = $raw.IndexOf($cutMarker)

if ($cutPos -lt 0) {
    # Try CRLF
    $cutMarker = "},`r`n    {`r`n      `"name`": `"08 - Security Tests`""
    $cutPos = $raw.IndexOf($cutMarker)
}

if ($cutPos -lt 0) {
    Write-Host "Trying alternate pattern..."
    $idx08 = $raw.IndexOf('"08 - Security Tests"')
    Write-Host "08 folder at: $idx08"
    Write-Host "100 chars before: [$($raw.Substring([Math]::Max(0,$idx08-100), 100))]"
    exit 1
}

Write-Host "Cut position: $cutPos"
Write-Host "Context: $($raw.Substring($cutPos, 60))"

# Split: partA = everything including the closing } of the global test script
$partA = $raw.Substring(0, $cutPos + 1)

# The misplaced folders + event close + root close
$partB_raw = $raw.Substring($cutPos + 1)

# Find where the event array + root closes at the very end
# Should be: \n  ]\n}  (event close + root close)
$endPattern = "`n  ]`n}"
$endPos = $partB_raw.LastIndexOf($endPattern)
if ($endPos -lt 0) {
    $endPattern = "`r`n  ]`r`n}"
    $endPos = $partB_raw.LastIndexOf($endPattern)
}

Write-Host "End pattern position in partB: $endPos"
Write-Host "Last 100 chars of partB_raw: $($partB_raw.Substring($partB_raw.Length - 100))"

# Extract the three misplaced folders (everything before the event+root close)
$misplacedFolders = $partB_raw.Substring(0, $endPos).TrimStart(",`n `r")
Write-Host "Misplaced folders length: $($misplacedFolders.Length)"
Write-Host "Starts: $($misplacedFolders.Substring(0, 50))"
Write-Host "Ends: $($misplacedFolders.Substring($misplacedFolders.Length - 50))"

# Find where the item array closed in partA (to insert folders before event)
$itemClosePatternLF   = "],`n  `"event`": ["
$itemClosePatternCRLF = "],`r`n  `"event`": ["

$itemClosePos = $partA.IndexOf($itemClosePatternLF)
if ($itemClosePos -lt 0) { $itemClosePos = $partA.IndexOf($itemClosePatternCRLF); $itemClosePattern = $itemClosePatternCRLF }
else { $itemClosePattern = $itemClosePatternLF }

Write-Host "Item array closes at: $itemClosePos"

$beforeItemClose = $partA.Substring(0, $itemClosePos)
$eventOpenOnwards = $partA.Substring($itemClosePos + $itemClosePattern.Length)

Write-Host "Before item close ends: $($beforeItemClose.Substring($beforeItemClose.Length - 30))"
Write-Host "Event onwards starts: $($eventOpenOnwards.Substring(0, 50))"

# Use LF consistently (v2 was LF)
$nl = "`n"

# Build corrected file
$newContent  = $beforeItemClose           # item array content (00-07, 10)
$newContent += ",$nl    $misplacedFolders" # add 08, 09, 11, 12, 13, 14, 99 to item
$newContent += "$nl  ],$nl  `"event`": [" # close item, open event
$newContent += $eventOpenOnwards          # prerequest + test scripts
$newContent += "$nl  ]$nl}"              # close event + root

Write-Host "`nNew file size: $([Math]::Round($newContent.Length/1KB,1)) KB"
Write-Host "Starts with '{': $($newContent.TrimStart()[0] -eq '{')"
Write-Host "Ends with '}': $($newContent.TrimEnd()[-1] -eq '}')"

# Validate: all new folders should be BEFORE the collection-level event
$collEventPos = $newContent.IndexOf("],`n  `"event`": [")
if ($collEventPos -lt 0) { $collEventPos = $newContent.IndexOf("],`r`n  `"event`": [") }

$folders = @("08 - Security Tests", "09 - Agent", "11 - Quote Status", "12 - Underwriting Attr", "13 - Underwriting Sub", "14 - Agent Status", "99 - Teardown")
$allOk = $true
foreach ($f in $folders) {
    $pos = $newContent.IndexOf("`"$f")
    $inItem = ($pos -gt 0 -and $pos -lt $collEventPos)
    $status = if ($inItem) { "OK" } else { "WRONG pos=$pos (event at $collEventPos)" }
    Write-Host "  $f : $status"
    if (-not $inItem) { $allOk = $false }
}

if ($allOk) {
    [System.IO.File]::WriteAllText($v2, $newContent, $utf8NoBom)
    Write-Host "`nSUCCESS: v2 structure fixed and written"
} else {
    Write-Host "`nERROR: Structure validation failed - NOT writing file"
}
