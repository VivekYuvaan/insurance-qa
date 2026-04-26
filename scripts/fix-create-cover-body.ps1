$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$bytes = [System.IO.File]::ReadAllBytes($v2)
$raw = [System.Text.Encoding]::UTF8.GetString($bytes)

# Find 1.5 Create Cover
$anchor = '"name": "1.5  [SMOKE]  Create Cover"'
$pos = $raw.IndexOf($anchor)
if ($pos -lt 0) {
    Write-Host "Could not find 1.5 Create Cover"
    exit 1
}

$bodyAnchor = '"raw": "{\n  \"insuredId\": {{insuredId}},\n  \"coverCode\": \"{{coverCode}}\",\n  \"coverName\": \"{{coverName}}\",\n  \"coverType\": \"{{coverType}}\",\n  \"sumAssured\": {{sumAssured}},\n  \"termYears\": {{termYears}},\n  \"rateableAge\": {{rateableAge}},\n  \"occupationClass\": \"{{occupationClass}}\",\n  \"smokerStatus\": \"{{coverSmokerStatus}}\",\n  \"commencementDate\": \"{{commencementDate}}\"\n}"'

$bodyPos = $raw.IndexOf($bodyAnchor, $pos)
if ($bodyPos -lt 0) {
    Write-Host "Could not find exact request body"
    # Try finding just the body start
    $bodyStart = $raw.IndexOf('"raw": "{\n  \"insuredId\": {{insuredId}}', $pos)
    if ($bodyStart -gt 0) {
        Write-Host "Found body start at $bodyStart"
        $bodyEnd = $raw.IndexOf('}"', $bodyStart)
        Write-Host "Current body:"
        Write-Host $raw.Substring($bodyStart, $bodyEnd - $bodyStart + 2)
    }
} else {
    Write-Host "Found exact body match."
    $newBody = '"raw": "{\n  \"insuredId\": {{insuredId}},\n  \"coverCode\": \"{{coverCode}}\",\n  \"coverName\": \"{{coverName}}\",\n  \"coverType\": \"{{coverType}}\",\n  \"sumAssured\": {{sumAssured}},\n  \"termYears\": {{termYears}},\n  \"commencementDate\": \"{{commencementDate}}\"\n}"'
    
    $raw = $raw.Substring(0, $bodyPos) + $newBody + $raw.Substring($bodyPos + $bodyAnchor.Length)
    [System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
    Write-Host "Replaced 1.5 Create Cover body to remove rateableAge, occupationClass, smokerStatus."
}
