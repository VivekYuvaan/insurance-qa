$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

Write-Host "Reading v1..."
$bytes = [System.IO.File]::ReadAllBytes($v1)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

# ============================================================
# STEP 1: Fix the structural bug
# Folders 08-Security Tests and 09-Agent & Client CRUD are 
# incorrectly placed inside the collection-level "event" array.
# They need to be in the top-level "item" array.
#
# Current broken structure (simplified):
#   "item": [00,01,02,03,04,05,06,07,10,99],
#   "event": [
#     { prerequest },
#     { test },
#     { "name": "08..." },   <- WRONG
#     { "name": "09..." }    <- WRONG
#   ]
# }
#
# Target correct structure:
#   "item": [00,01,02,03,04,05,06,07,08,09,10,99],
#   "event": [
#     { prerequest },
#     { test }
#   ]
# }
# ============================================================

# The separator between the last valid event script and 08 folder
$badSeparator = ",`r`n    {`r`n      `"name`": `"08 - Security Tests`""

# Extract the text from that comma onwards (this is everything that shouldn't be in event)
$cutPoint = $raw.IndexOf($badSeparator)
Write-Host "Cut point found at char: $cutPoint"

# Everything from $cutPoint onwards inside the event array needs to move out
# The text after the last valid event script up to and including "}\n]\n}" at the very end
# We need to:
# 1. Close event array after the test script: }  <- end of test script object
#                                              ]  <- close event array  
#                                              }  <- close root object (WRONG - item array not closed)
# 
# Wait - the current file ends with:
#   ... (09 CRUD content) ...
#   "99 - Teardown" ... items ...
#   ]    <- closes 99 item array
# }    <- closes 99 folder  
# ]    <- closes what? should be closing "item" top-level array
# ]    <- extra closing of event array?
# }    <- closes root

# Let's see what's at the very end
$endChars = $raw.Substring($raw.Length - 50)
Write-Host "Last 50 chars: [$endChars]"

# The correct ending should be:
# (last folder closes)
#   }\r\n  ]\r\n],\r\n  "event": [...]\r\n}

# Step: cut everything from the comma before "08" to find what needs to be extracted
$beforeCut = $raw.Substring(0, $cutPoint)   # valid content up to the comma
$extractedFolders = $raw.Substring($cutPoint + 1)  # starts with \r\n    { "name": "08...

# Now $extractedFolders contains:
# \r\n    { "name": "08..." },
# \r\n    { "name": "09..." }
# \r\n  ]\r\n}\r\n  ]\r\n]\r\n}
# We need to find where the event array closing is and what comes after

# Find the actual closing sequence at the end
# After 09-CRUD, the event array closes, then what's left?
$end = $extractedFolders.TrimEnd()
Write-Host "End of extracted section (last 100):" $end.Substring([Math]::Max(0,$end.Length-100))

# The extracted section ends with:
#   ]\r\n    }\r\n  ]\r\n]\r\n}
# This is:  close 09-CRUD item array, close 09 folder, close event array, extra ], close root
# We need: close 09-CRUD item array, close 09 folder, close top-level item array, close event [...], close root

# Split out the folders from the closing brackets
# Find where 09-CRUD folder ends (look for last "]\r\n    }" pattern)
$folder09End = $extractedFolders.LastIndexOf("`r`n    }`r`n  ]")
if ($folder09End -lt 0) { $folder09End = $extractedFolders.LastIndexOf("`n    }`n  ]") }
Write-Host "09 folder end position in extracted: $folder09End"

$foldersContent = $extractedFolders.Substring(0, $folder09End + "`r`n    }`r`n  ]".Length)
Write-Host "Folders content length: $foldersContent.Length"

# Now build the corrected file:
# beforeCut = everything up to (not including) the comma before 08
# We need to close the event array, add a comma, add the two folders to the item array
# 
# beforeCut ends with the test script object (closing })
# Then we need:  \r\n  ]\r\n  and then close item with ],\r\n  "event": [prereq, test]\r\n}
# 
# Actually simpler: 
# - beforeCut has the valid event array content (prereq + test scripts, ends with "}")
# - We need to close event: add \r\n  ]\r\n}
# - But we also need to add 08 and 09 to the TOP-LEVEL item array
# 
# The item array was closed before "event" started in the original
# So the file looks like:
# {
#   "info": {...},
#   "item": [...folders...],    <- closed with ]
#   "event": [...]              <- global scripts
# }
#
# The misplacement means 08 and 09 got injected INTO the event array instead of item array
# Fix: extract 08 and 09, put them back into the item array, keep event clean

# Since item array was already closed before event, we need to:
# 1. Re-open item array (remove the ], before "event")
# 2. Add 08 and 09 to item array
# 3. Close item array
# 4. Close event array properly

# Find "],\r\n  \"event\"" - this is where item was closed and event started
$itemClosePattern = "],`r`n  `"event`""
$itemClosePos = $raw.IndexOf($itemClosePattern)
if ($itemClosePos -lt 0) {
    $itemClosePattern = "],`n  `"event`""
    $itemClosePos = $raw.IndexOf($itemClosePattern)
}
Write-Host "Item close + event start at: $itemClosePos"
Write-Host "Pattern found: $($itemClosePos -ge 0)"

if ($itemClosePos -ge 0) {
    Write-Host "Context around item close:" $raw.Substring($itemClosePos - 20, 60)
}
