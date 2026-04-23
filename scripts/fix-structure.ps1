$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

$raw = [System.IO.File]::ReadAllText($v1)

# THE BUG: Folders 08-Security Tests, 09-Agent & Client CRUD, 99-Teardown
# are INSIDE the collection-level "event" array. They must be in the "item" array.
#
# Current broken ending (simplified):
#   "item": [...07, 10...],
#   "event": [
#     { prerequest },
#     { test },          <- ends here
#     { "name": "08.." }, <- WRONG - folder in event
#     { "name": "09.." }, <- WRONG
#     { "name": "99.." }  <- WRONG
#   ]
# }
#
# Target correct ending:
#   "item": [...07, 08, 09, 10, 99...],
#   "event": [
#     { prerequest },
#     { test }
#   ]
# }

# Step 1: Find the exact cut point - comma before 08 folder inside event
$cutMarker = "},`r`n    {`r`n      `"name`": `"08 - Security Tests`""
$cutPos = $raw.IndexOf($cutMarker)

if ($cutPos -lt 0) {
    Write-Host "ERROR: Could not find the cut marker. Check file."
    exit 1
}

Write-Host "Cut position found at: $cutPos"
Write-Host "Context: $($raw.Substring($cutPos, 60))"

# Step 2: Split the file at the cut point
# Part A = everything up to and including the closing } of the test script
$partA = $raw.Substring(0, $cutPos + 1)  # includes the closing } of test script

# Part B = the three misplaced folders + the closing of event array + closing of root
$partB = $raw.Substring($cutPos + "},`r`n    ".Length)
# partB now starts with: { "name": "08..." ... all three folders ... ] \r\n}

Write-Host "PartA ends with: $($partA.Substring($partA.Length - 30))"
Write-Host "PartB starts with: $($partB.Substring(0, 50))"

# Step 3: Find where the event array closes in partB and what the root close is
# partB contains: {folder08}, {folder09}, {folder99} ] \r\n}
# We need to extract: {folder08}, {folder09}, {folder99}
# And the closing:    ] \r\n}  (which closes event array and root)

# The last ]<newline>} closes the event array then the root object
# Find the last occurrence of "\r\n  ]\r\n}" in partB
$eventClose = "`r`n  ]`r`n}"
$eventClosePos = $partB.LastIndexOf($eventClose)

if ($eventClosePos -lt 0) {
    $eventClose = "`n  ]`n}"
    $eventClosePos = $partB.LastIndexOf($eventClose)
}

Write-Host "Event close position in partB: $eventClosePos"

# The three folders are: partB from start to eventClosePos
$threeFolders = $partB.Substring(0, $eventClosePos)
Write-Host "Three folders length: $($threeFolders.Length)"
Write-Host "Three folders start: $($threeFolders.Substring(0, 40))"
Write-Host "Three folders end: $($threeFolders.Substring($threeFolders.Length - 40))"

# Step 4: Find where the item array closes in partA (before "event" starts)
# partA ends with the valid event content. We need to find where "item" array closed.
# That's: ],\r\n  "event": [
$itemClose = "],`r`n  `"event`": ["
$itemClosePos = $partA.IndexOf($itemClose)
if ($itemClosePos -lt 0) {
    $itemClose = "],`n  `"event`": ["
    $itemClosePos = $partA.IndexOf($itemClose)
}

Write-Host "Item close in partA at: $itemClosePos"

if ($itemClosePos -lt 0) {
    Write-Host "ERROR: Could not find item array close in partA"
    exit 1
}

# partA structure:
# ... item array content ... ],
# "event": [ { prerequest }, { test } <-- cut here
#
# We need to:
# 1. Re-open item array (remove the ], before "event")
# 2. Add three folders to item array
# 3. Close item array
# 4. Add event array with just prerequest + test
# 5. Close root

# Split partA at the item close
$beforeItemClose = $partA.Substring(0, $itemClosePos)  # item content without closing ]
$eventPart = $partA.Substring($itemClosePos + $itemClose.Length)  # just the two event scripts + their opening

Write-Host "Before item close ends: $($beforeItemClose.Substring($beforeItemClose.Length - 30))"
Write-Host "Event part starts: $($eventPart.Substring(0, 50))"

# Build the corrected file:
$newContent = $beforeItemClose        # item array content (folders 00-07, 10)
$newContent += ",`r`n    $threeFolders"  # add 08, 09, 99 to item array
$newContent += "`r`n  ],`r`n  `"event`": ["  # close item array, open event array
$newContent += $eventPart             # the two valid event scripts
$newContent += "`r`n  ]`r`n}"        # close event array and root

Write-Host "New file length: $($newContent.Length)"
Write-Host "File starts with '{': $($newContent.TrimStart()[0] -eq '{')"
Write-Host "File ends with '}': $($newContent.TrimEnd()[-1] -eq '}')"

# Validate by checking key markers are in right place
$newItemClosePos = $newContent.IndexOf("],`r`n  `"event`": [")
$new08Pos = $newContent.IndexOf('"08 - Security Tests"')
$new09Pos = $newContent.IndexOf('"09 - Agent')
$new99Pos = $newContent.IndexOf('"99 - Teardown"')
$eventArrayPos = $newContent.LastIndexOf('"event": [')

Write-Host "New item close at: $newItemClosePos"
Write-Host "08 folder at: $new08Pos"
Write-Host "09 folder at: $new09Pos"
Write-Host "99 folder at: $new99Pos"
Write-Host "Last event array at: $eventArrayPos"

# 08, 09, 99 should all be BEFORE the last event array (i.e., in item array)
if ($new08Pos -lt $eventArrayPos -and $new09Pos -lt $eventArrayPos -and $new99Pos -lt $eventArrayPos) {
    Write-Host "STRUCTURE VALID: All 3 folders are before the event array"
} else {
    Write-Host "STRUCTURE ERROR: Folders still in wrong position!"
    Write-Host "  08 before event: $($new08Pos -lt $eventArrayPos)"
    Write-Host "  09 before event: $($new09Pos -lt $eventArrayPos)"
    Write-Host "  99 before event: $($new99Pos -lt $eventArrayPos)"
    exit 1
}

# Write the fixed file
[System.IO.File]::WriteAllText($v1, $newContent, $utf8NoBom)
Write-Host "SUCCESS: Written to $v1"
