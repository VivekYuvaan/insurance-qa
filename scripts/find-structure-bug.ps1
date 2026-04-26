$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"

Write-Host "Reading v1..."
$bytes = [System.IO.File]::ReadAllBytes($v1)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

Write-Host "Original size: $([Math]::Round($bytes.Length/1KB,1)) KB, lines: $($raw.Split("`n").Count)"

# Step 1: Find the broken structure
# The file has folders 08 and 09 inside the "event" array
# We need to:
#   a) Find where the event array starts after the last top-level folder
#   b) Find where 08-Security Tests starts within event
#   c) Cut out 08 and 09 from inside event, close the event array properly
#   d) Put 08, 09, and 99-Teardown AFTER the event array in the item array

# Find the key boundary: the end of the global test script (before 08 appears)
# Pattern: the global test script ends, then incorrectly 08 starts inside event

$marker08 = '"name": "08 - Security Tests"'
$marker09 = '"name": "09 - Agent & Client CRUD"'
$marker99 = '"name": "99 - Teardown"'

$pos08 = $raw.IndexOf($marker08)
$pos09 = $raw.IndexOf($marker09)
$pos99 = $raw.IndexOf($marker99)

Write-Host "08 at char: $pos08"
Write-Host "09 at char: $pos09"
Write-Host "99 at char: $pos99"

# Find the closing of the event array that incorrectly contains 08 and 09
# This is the "}  ]  ]  }" pattern at the very end
# The correct structure should be:
#   "item": [...all folders...],
#   "event": [{ prerequest }, { test }]   <- no folders inside
# }

# Find where 08 folder OBJECT starts (go back to the '{' before "name": "08")
# It starts with "    {\n      \"name\": \"08..."
$pos08Start = $raw.LastIndexOf("{", $pos08)
Write-Host "08 object starts at: $pos08Start"
# Context around 08 start
Write-Host "Context:" $raw.Substring($pos08Start - 10, 40)

# Find the separator between the last valid event script and 08
# Look for the ',' before '{\n      "name": "08'
$beforeFolder08 = $raw.Substring($pos08Start - 30, 30)
Write-Host "Before 08 folder:" $beforeFolder08

# The structure inside event looks like:
# { prerequest script },
# { test script },      <- we need to remove the comma after this
# { "name": "08..." },  <- this should not be here
# { "name": "09..." }   <- this should not be here

# Strategy: find the ',\n    {\n      "name": "08' pattern and everything after it (still inside event)
# Replace it with just closing the event array: '  ]\n}'

# Find the exact position of comma+newline+spaces just before { of 08
$search08 = ",`r`n    {`r`n      `"name`": `"08 - Security Tests`""
if ($raw.Contains($search08)) {
    Write-Host "Found CRLF pattern before 08"
} else {
    $search08 = ",`n    {`n      `"name`": `"08 - Security Tests`""
    if ($raw.Contains($search08)) { Write-Host "Found LF pattern before 08" }
    else { Write-Host "WARNING: Could not find separator pattern before 08" }
}

$insertionPos = $raw.IndexOf($search08)
Write-Host "Insertion point (comma before 08): $insertionPos"
Write-Host "Text there:" $raw.Substring($insertionPos, 50)

if ($insertionPos -lt 0) {
    Write-Host "Trying alternate pattern..."
    # Try with different whitespace
    $idx = $raw.IndexOf($marker08)
    # Go back to find the preceding comma
    $searchBack = $raw.Substring([Math]::Max(0,$idx-100), 100)
    Write-Host "100 chars before 08: [$searchBack]"
}
