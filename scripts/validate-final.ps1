# Clean final validation — no emoji in the regex patterns
$files = @(
    "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json",
    "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
)

foreach ($file in $files) {
    $name = Split-Path $file -Leaf
    Write-Host "=== $name ==="
    
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $sizeKB = [Math]::Round($bytes.Length / 1KB, 1)
    
    # Check BOM
    $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    Write-Host "  Size: $sizeKB KB"
    Write-Host "  BOM: $hasBOM"
    
    if ($hasBOM) {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    
    # Count non-ASCII
    $nonAscii = 0
    foreach ($c in $raw.ToCharArray()) {
        if ([int][char]$c -gt 127) { $nonAscii++ }
    }
    Write-Host "  Non-ASCII chars: $nonAscii"
    
    # Try to parse — use Newtonsoft-style via .NET
    try {
        # Use the built-in .NET JSON parser
        $ns = [System.Text.Json.JsonDocument]::Parse($raw)
        $root = $ns.RootElement
        $itemCount = $root.GetProperty('item').GetArrayLength()
        $collName = $root.GetProperty('info').GetProperty('name').GetString()
        $collId = $root.GetProperty('info').GetProperty('_postman_id').GetString()
        Write-Host "  JSON: VALID (System.Text.Json)"
        Write-Host "  Name: $collName"
        Write-Host "  ID: $collId"
        Write-Host "  Top-level folders: $itemCount"
        
        $items = $root.GetProperty('item')
        foreach ($folder in $items.EnumerateArray()) {
            $folderName = $folder.GetProperty('name').GetString()
            $testCount = 0
            if ($folder.TryGetProperty('item', [ref]$null)) {
                $testCount = $folder.GetProperty('item').GetArrayLength()
            }
            Write-Host "    [$testCount tests] $folderName"
        }
    } catch {
        Write-Host "  JSON: PARSE ERROR - $($_.Exception.Message)"
    }
    Write-Host ""
}
