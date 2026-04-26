$raw = [System.IO.File]::ReadAllText('d:\insurance-qa\collections\insurance-enterprise-v2-complete.json')

# Show all agentId writes between 03 folder and its end
$folderStart = $raw.IndexOf('"03 - Contract Tests"')
$folderEnd = $raw.IndexOf('"04 - Cover Scenarios"')

$section = $raw.Substring($folderStart, $folderEnd - $folderStart)
Write-Host "=== Section length: $($section.Length) ==="

# Find all env set calls
$matches = [regex]::Matches($section, 'pm\.(environment|globals)\.set\([^)]+\)')
foreach ($m in $matches) {
    Write-Host "SET: $($m.Value)"
}

Write-Host "`n=== Full Contract Tests section ==="
Write-Host $section.Substring(0, 4000)
