$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$bytes = [System.IO.File]::ReadAllBytes($v2)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

# Insert point confirmed: 163868 (right after closing " of "`);" in global prerequest)
$insertAt = 163868

# Verify context
Write-Host "Context at insert point: [$($raw.Substring($insertAt - 10, 30))]"

$nl = "`r`n"
$sp = "          "

# Use here-string for the fallback block to avoid escaping issues
$fallbackLines = @(
    '"// === GLOBAL CSV FALLBACKS: safe defaults when running in Postman GUI (not data-driven) ==="',
    '"const sb=(k,d)=>{const v=pm.variables.get(k);if(!v||String(v).includes(chr123))pm.variables.set(k,d);};"',
    '"sb(chr34firstName chr34,chr34Vivek chr34); sb(chr34lastName chr34,chr34Kumar chr34); sb(chr34dateOfBirth chr34,chr341985-06-15 chr34);"',
    '"sb(chr34addressLine1 chr34,chr34123 Main Street chr34); sb(chr34addressCity chr34,chr34Mumbai chr34);"',
    '"sb(chr34addressState chr34,chr34MH chr34); sb(chr34addressCountry chr34,chr34India chr34); sb(chr34postalCode chr34,chr34400001 chr34);"',
    '"sb(chr34coverCode chr34,chr34LC chr34); sb(chr34coverName chr34,chr34Life Cover chr34); sb(chr34coverType chr34,chr34BASE chr34);"',
    '"sb(chr34sumAssured chr34,chr34500000 chr34); sb(chr34termYears chr34,chr3420 chr34); sb(chr34commencementDate chr34,chr342026-05-01 chr34);"',
    '"sb(chr34rateableAge chr34,chr3430 chr34); sb(chr34occupationClass chr34,chr34STANDARD chr34); sb(chr34coverSmokerStatus chr34,chr34NON_SMOKER chr34);"',
    '"sb(chr34smokerStatusValue chr34,chr34NON_SMOKER chr34); sb(chr34rateableAgeValue chr34,chr3430 chr34); sb(chr34occupationClassValue chr34,chr34STANDARD chr34);"'
)

# Build the insertion string
$insertion = ""
foreach ($line in $fallbackLines) {
    $insertion += ",$nl$sp$line"
}

# Replace placeholder tokens with actual chars
$insertion = $insertion.Replace("chr34", [char]92 + [char]34)  # \" (escaped quote in JSON)
$insertion = $insertion.Replace("chr123", [char]92 + [char]34 + "{" + [char]92 + [char]34)  # \"{\"  

# Actually simpler: just build direct strings
$esc = '\"'  # This is the JSON escaped quote sequence: \"
$ob  = '{'   # opening brace

$insertion = ",$nl$sp" + '"// === GLOBAL CSV FALLBACKS ==="' +
             ",$nl$sp" + '"const sb=(k,d)=>{const v=pm.variables.get(k);if(!v||String(v).includes(' + "'{')" + ')pm.variables.set(k,d);};' + '"' +
             ",$nl$sp" + '"sb(' + $esc + 'firstName' + $esc + ',' + $esc + 'Vivek' + $esc + '); sb(' + $esc + 'lastName' + $esc + ',' + $esc + 'Kumar' + $esc + '); sb(' + $esc + 'dateOfBirth' + $esc + ',' + $esc + '1985-06-15' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'addressLine1' + $esc + ',' + $esc + '123 Main Street' + $esc + '); sb(' + $esc + 'addressCity' + $esc + ',' + $esc + 'Mumbai' + $esc + '); sb(' + $esc + 'addressState' + $esc + ',' + $esc + 'MH' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'addressCountry' + $esc + ',' + $esc + 'India' + $esc + '); sb(' + $esc + 'postalCode' + $esc + ',' + $esc + '400001' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'coverCode' + $esc + ',' + $esc + 'LC' + $esc + '); sb(' + $esc + 'coverName' + $esc + ',' + $esc + 'Life Cover' + $esc + '); sb(' + $esc + 'coverType' + $esc + ',' + $esc + 'BASE' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'sumAssured' + $esc + ',' + $esc + '500000' + $esc + '); sb(' + $esc + 'termYears' + $esc + ',' + $esc + '20' + $esc + '); sb(' + $esc + 'commencementDate' + $esc + ',' + $esc + '2026-05-01' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'rateableAge' + $esc + ',' + $esc + '30' + $esc + '); sb(' + $esc + 'occupationClass' + $esc + ',' + $esc + 'STANDARD' + $esc + '); sb(' + $esc + 'coverSmokerStatus' + $esc + ',' + $esc + 'NON_SMOKER' + $esc + ');"' +
             ",$nl$sp" + '"sb(' + $esc + 'smokerStatusValue' + $esc + ',' + $esc + 'NON_SMOKER' + $esc + '); sb(' + $esc + 'rateableAgeValue' + $esc + ',' + $esc + '30' + $esc + '); sb(' + $esc + 'occupationClassValue' + $esc + ',' + $esc + 'STANDARD' + $esc + ');"'

Write-Host "Insertion preview (first 300 chars): $($insertion.Substring(0, [Math]::Min(300, $insertion.Length)))"

$raw = $raw.Substring(0, $insertAt) + $insertion + $raw.Substring($insertAt)

Write-Host "New size: $([Math]::Round($raw.Length/1KB,1)) KB"

if ($raw.Contains("GLOBAL CSV FALLBACKS")) {
    Write-Host "SUCCESS: Fallbacks block found in file"
} else {
    Write-Host "ERROR: Block not inserted"
    exit 1
}

[System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
Write-Host "Written."
