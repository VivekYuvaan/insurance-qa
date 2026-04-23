$files = @(
    "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json",
    "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
)

foreach ($file in $files) {
    $name = Split-Path $file -Leaf
    Write-Host "--- $name ---"
    
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $size = [Math]::Round($bytes.Length / 1KB, 1)
        Write-Host "  Size: $size KB"
        
        # Check for BOM
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Host "  WARNING: UTF-8 BOM detected - stripping for parse test"
            $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
        } else {
            $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
        }
        
        # Check for problematic characters
        $hasEmoji = $raw -match '[\u{1F600}-\u{1F9FF}]'
        Write-Host "  Has emoji/special chars: $hasEmoji"
        
        # Try parse
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
        
        Write-Host "  JSON: VALID"
        Write-Host "  _postman_id : $($obj.info._postman_id)"
        Write-Host "  name        : $($obj.info.name)"
        Write-Host "  schema      : $($obj.info.schema)"
        Write-Host "  folders     : $($obj.item.Count)"
        
        foreach ($folder in $obj.item) {
            $testCount = if ($folder.item) { $folder.item.Count } else { 0 }
            Write-Host "    [$testCount] $($folder.name)"
        }
        
    } catch {
        Write-Host "  JSON: PARSE ERROR"
        Write-Host "  Error: $($_.Exception.Message)"
    }
    Write-Host ""
}
