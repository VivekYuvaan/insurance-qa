$json = Get-Content 'd:/insurance-qa/collections/insurance-enterprise-v2-complete.json' -Raw
$newId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
$json = $json.Replace('f5b34113-af0d-4868-bee6-2eebc799aaa6', $newId)
[System.IO.File]::WriteAllText('d:/insurance-qa/collections/insurance-enterprise-v2-complete.json', $json, [System.Text.Encoding]::UTF8)
Write-Host "v2 collection ID updated to: $newId"
