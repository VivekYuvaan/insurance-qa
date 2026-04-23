# Fix both collection files:
# 1. Strip UTF-8 BOM from v2
# 2. Replace all non-ASCII/emoji with ASCII equivalents in both files

$replacements = @{
    # Emoji → ASCII
    [char]0x2705 = '[OK]'       # ✅
    [char]0x274C = '[FAIL]'     # ❌
    [char]0x26A0 = '[WARN]'     # ⚠
    [char]0xFE0F = ''           # variation selector (invisible, just remove)
    [char]0x23F1 = '[TIME]'     # ⏱
    [char]0xD83D = ''           # surrogate pair start (part of emoji like 💾)
    [char]0xDCBE = '[SAVE]'     # surrogate pair end for 💾
    [char]0x1F4BE = '[SAVE]'    # 💾 direct
    [char]0x1F5D1 = '[DEL]'     # 🗑
    [char]0x1F680 = '[ROCKET]'  # 🚀
    # Arrows & punctuation → ASCII
    [char]0x2192 = '->'         # →
    [char]0x2190 = '<-'         # ←
    [char]0x2014 = '--'         # em-dash —
    [char]0x2013 = '-'          # en-dash –
    [char]0x201C = '"'          # left curly quote "
    [char]0x201D = '"'          # right curly quote "
    [char]0x2018 = "'"          # left single quote '
    [char]0x2019 = "'"          # right single quote '
    [char]0x2026 = '...'        # ellipsis …
    [char]0x2020 = '+'          # dagger † (corruption artifact)
    # Common 2-byte corruption patterns from UTF-8 misread
    [char]0x00E2 = ''           # â (first byte of multi-byte sequence misread)
    [char]0x20AC = ''           # € (second byte artifact)
    [char]0x0161 = ''           # š (corruption)
    [char]0x00A0 = ' '          # non-breaking space → regular space
    [char]0x00EF = ''           # ï (corruption)
    [char]0x00B8 = ''           # ¸ (corruption)
    [char]0x008F = ''           # (control char corruption)
    [char]0x0153 = ''           # œ (corruption artifact)
}

$files = @(
    "d:/insurance-qa/collections/insurance-enterprise-v1-stable.json",
    "d:/insurance-qa/collections/insurance-enterprise-v2-complete.json"
)

foreach ($file in $files) {
    $name = Split-Path $file -Leaf
    Write-Host "Processing $name..."
    
    $bytes = [System.IO.File]::ReadAllBytes($file)
    
    # Strip BOM if present
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "  Stripping UTF-8 BOM..."
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    
    $originalLength = $raw.Length
    
    # Apply all replacements
    foreach ($kvp in $replacements.GetEnumerator()) {
        $raw = $raw.Replace([string]$kvp.Key, $kvp.Value)
    }
    
    # Final pass: remove any remaining non-ASCII chars (catch-all)
    $cleaned = [System.Text.StringBuilder]::new()
    $removed = 0
    foreach ($c in $raw.ToCharArray()) {
        $code = [int][char]$c
        if ($code -le 127) {
            [void]$cleaned.Append($c)
        } else {
            $removed++
            # Replace with safe ASCII approximation
            [void]$cleaned.Append('?')
        }
    }
    $raw = $cleaned.ToString()
    
    Write-Host "  Non-ASCII chars removed/replaced: $removed"
    
    # Remove the placeholder ? that now appear in JSON strings from the catch-all
    # Replace "?" that are clearly emoji placeholders in console.log strings
    $raw = $raw -replace '\?{1,3}([A-Z])', '$1'
    
    # Validate it now parses
    try {
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
        Write-Host "  Post-fix JSON: VALID"
        Write-Host "  Folders: $($obj.item.Count)"
    } catch {
        Write-Host "  Post-fix JSON: STILL INVALID - $($_.Exception.Message)"
    }
    
    # Write back as pure ASCII-compatible UTF-8 without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($file, $raw, $utf8NoBom)
    Write-Host "  Written: $file"
    Write-Host ""
}

Write-Host "Done. Both files cleaned."
