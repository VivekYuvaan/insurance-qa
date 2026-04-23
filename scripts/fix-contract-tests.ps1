$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$bytes = [System.IO.File]::ReadAllBytes($v2)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

$folderStart = $raw.IndexOf('"03 - Contract Tests"')
$folderEnd   = $raw.IndexOf('"04 - Cover Scenarios"')

Write-Host "Contract Tests: $folderStart to $folderEnd"

# Fix 1 & 2: In the two agent-creation tests, change agentId -> contractAgentId
# Both have: pm.environment.set(\"agentId\", json.agentId);
# Replace ONLY within the Contract Tests folder
$section = $raw.Substring($folderStart, $folderEnd - $folderStart)
$fixedSection = $section -replace 'pm\.environment\.set\(\\\"agentId\\\", json\.agentId\)', 'pm.environment.set(\"contractAgentId\", json.agentId)'

$changeCount = ($fixedSection -split 'contractAgentId').Count - 1
Write-Host "agentId -> contractAgentId replacements: $changeCount"

# Fix 3: Quote Schema Validation body uses {{clientId}} + {{agentId}}
# Since agentId is now NOT overwritten, this should just work.
# But let's verify the quote body uses the right variables
$qsvBodyIdx = $fixedSection.IndexOf('"Quote - Schema Validation"')
$qsvBody    = $fixedSection.Substring($qsvBodyIdx, 500)
Write-Host "Quote Schema Validation body area:"
Write-Host $qsvBody

$raw = $raw.Substring(0, $folderStart) + $fixedSection + $raw.Substring($folderEnd)

# Verify: agentId should NOT be set in Contract Tests section anymore
$verify = $raw.Substring($folderStart, $folderEnd - $folderStart)
$remaining = [regex]::Matches($verify, 'pm\.environment\.set\(\\\"agentId\\\"')
Write-Host "Remaining agentId writes in Contract Tests: $($remaining.Count)"

$contractAgentSets = [regex]::Matches($verify, 'pm\.environment\.set\(\\\"contractAgentId\\\"')
Write-Host "contractAgentId writes confirmed: $($contractAgentSets.Count)"

[System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
Write-Host "Written: $v2"
