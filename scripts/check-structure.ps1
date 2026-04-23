$v1 = "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json"
$v2 = "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"

foreach ($file in @($v1, $v2)) {
    $name = Split-Path $file -Leaf
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    
    if ($hasBOM) {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    
    # Count non-ASCII
    $nonAscii = ($raw.ToCharArray() | Where-Object { [int]$_ -gt 127 }).Count
    
    # Find any remaining ? placeholders from cleanup in JSON strings
    $questionMarks = ([regex]::Matches($raw, '"[^"]*\?[^"]*"')).Count
    
    Write-Host "$name"
    Write-Host "  Size      : $([Math]::Round($bytes.Length/1KB,1)) KB"
    Write-Host "  BOM       : $hasBOM"
    Write-Host "  Non-ASCII : $nonAscii"
    Write-Host "  Strings with ? : $questionMarks"
    
    # Check collection structure basics
    $hasInfo = $raw.Contains('"_postman_id"')
    $hasItems = $raw.Contains('"item"')
    $schemaOk = $raw.Contains('collection/v2.1.0')
    Write-Host "  Has _postman_id : $hasInfo"
    Write-Host "  Has item array  : $hasItems"
    Write-Host "  Schema v2.1.0   : $schemaOk"
    
    # Count top-level folder name occurrences as proxy for folder count
    $folderCount = ([regex]::Matches($raw, '"00 - Setup"|"01 - Quote|"02 - |"03 - |"04 - |"05 - |"06 - |"07 - |"08 - |"09 - |"10 - |"11 - |"12 - |"13 - |"14 - |"99 - ')).Count
    Write-Host "  Folders detected: $folderCount"
    Write-Host ""
}
