$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$raw = [System.IO.File]::ReadAllText($v2)

# The actual string from the file (from debug output above)
$find    = '"smokerStatus\": \"{{clientSmokerStatus}}\",\\n  \"occupation\": \"{{occupation}}\",\\n  \"clientType\": \"{{clientType}}\",\\n  \"idType\": \"{{idType}}\",\\n  '
$replace = '"'

# Simpler approach: find the unique substring pattern and remove unsupported fields
$oldSnippet = '\"gender\\\": \\\"{{gender}}\\\",\\n  \\\"dateOfBirth\\\": \\\"{{dateOfBirth}}\\\",\\n  \\\"email\\\": \\\"{{clientEmail}}\\\",\\n  \\\"phoneNumber\\\": \\\"{{phoneNumber}}\\\",\\n  \\\"smokerStatus\\\": \\\"{{clientSmokerStatus}}\\\",\\n  \\\"occupation\\\": \\\"{{occupation}}\\\",\\n  \\\"clientType\\\": \\\"{{clientType}}\\\",\\n  \\\"idType\\\": \\\"{{idType}}\\\",\\n  \\\"agentId\\\":'

$newSnippet = '\"gender\\\": \\\"MALE\\\",\\n  \\\"dateOfBirth\\\": \\\"{{dateOfBirth}}\\\",\\n  \\\"email\\\": \\\"{{clientEmail}}\\\",\\n  \\\"phoneNumber\\\": \\\"{{phoneNumber}}\\\",\\n  \\\"agentId\\\":'

if ($raw.Contains($oldSnippet)) {
    $raw = $raw.Replace($oldSnippet, $newSnippet)
    Write-Host "SUCCESS: Fixed Create Client body"
} else {
    Write-Host "Trying partial match..."
    # Try finding just the extra fields part
    $extra = '\\\"smokerStatus\\\": \\\"{{clientSmokerStatus}}\\\",\\n  \\\"occupation\\\": \\\"{{occupation}}\\\",\\n  \\\"clientType\\\": \\\"{{clientType}}\\\",\\n  \\\"idType\\\": \\\"{{idType}}\\\",\\n  '
    if ($raw.Contains($extra)) {
        $raw = $raw.Replace($extra, '')
        Write-Host "SUCCESS: Removed extra fields via partial match"
    } else {
        # Last resort: work with the actual escaping in file
        $raw = $raw -replace [regex]::Escape('\"gender\": \"{{gender}}\"'), '\"gender\": \"MALE\"'
        $raw = $raw -replace ',\\n  \\"smokerStatus\\": \\"{{clientSmokerStatus}}\\",\\n  \\"occupation\\": \\"{{occupation}}\\",\\n  \\"clientType\\": \\"{{clientType}}\\",\\n  \\"idType\\": \\"{{idType}}\\"', ''
        Write-Host "Applied regex fallback"
    }
}

# Verify the fix
if ($raw.Contains('"gender\": \"MALE\"') -or $raw.Contains('gender\\\":\\\"MALE')) {
    Write-Host "gender=MALE confirmed in file"
}
if (-not $raw.Contains('clientSmokerStatus')) {
    Write-Host "clientSmokerStatus removed - OK"
} else {
    Write-Host "WARNING: clientSmokerStatus still in Create Client body"
}

[System.IO.File]::WriteAllText($v2, $raw, $utf8NoBom)
Write-Host "Written."
