$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$raw = [System.IO.File]::ReadAllText($v2)

# Verified positions from diagnostic:
$execStart = 10342  # start of "exec": [
$execClose = 10830  # position of closing ]

$oldExec = $raw.Substring($execStart, $execClose - $execStart + 1)
Write-Host "Replacing exec block ($($oldExec.Length) chars)"
Write-Host "Old ends with: $($oldExec.Substring($oldExec.Length-60))"

# Build the new exec block (CRLF because file uses CRLF)
$nl = "`r`n"
$sp = "                  "  # 18 spaces = indent level in file

$newExec = '"exec": [' + $nl +
  $sp + '"eval(pm.globals.get(\"commonUtils\"));\\r",' + $nl +
  $sp + '"const clientEmail = generateUnique(\"client\", \"usedClientEmails\");\\r",' + $nl +
  $sp + '"pm.environment.set(\"clientEmail\", clientEmail + \"@test.com\");\\r",' + $nl +
  $sp + '"const phone = \"+91\" + Math.floor(1000000000 + Math.random() * 9000000000);\\r",' + $nl +
  $sp + '"pm.environment.set(\"phoneNumber\", phone);\\r",' + $nl +
  $sp + '"// CSV fallbacks: set safe defaults when Postman GUI runs without --iteration-data\\r",' + $nl +
  $sp + '"const sb=(k,d)=>{const v=pm.variables.get(k);if(!v||String(v).includes(\"{\"))pm.variables.set(k,d);};\\r",' + $nl +
  $sp + '"sb(\"firstName\",\"Vivek\");\\r",' + $nl +
  $sp + '"sb(\"lastName\",\"Kumar\");\\r",' + $nl +
  $sp + '"sb(\"dateOfBirth\",\"1985-06-15\");\\r",' + $nl +
  $sp + '"sb(\"addressLine1\",\"123 Main Street\");\\r",' + $nl +
  $sp + '"sb(\"addressCity\",\"Mumbai\");\\r",' + $nl +
  $sp + '"sb(\"addressState\",\"MH\");\\r",' + $nl +
  $sp + '"sb(\"addressCountry\",\"India\");\\r",' + $nl +
  $sp + '"sb(\"postalCode\",\"400001\");"' + $nl +
  "                ]"

Write-Host "New exec ends with: $($newExec.Substring($newExec.Length - 40))"

$raw = $raw.Substring(0, $execStart) + $newExec + $raw.Substring($execClose + 1)

# Verify
if ($raw.Contains("1985-06-15") -and $raw.Contains("setIfBlank") -eq $false -and $raw.Contains('sb("dateOfBirth"')) {
    Write-Host "SUCCESS: fallback confirmed"
} elseif ($raw.Contains("1985-06-15")) {
    Write-Host "SUCCESS: dateOfBirth fallback is in file"
} else {
    Write-Host "ERROR: fallback not found"
    exit 1
}

Write-Host "New file size: $([Math]::Round($raw.Length/1KB,1)) KB"
[System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
Write-Host "Written: $v2"
