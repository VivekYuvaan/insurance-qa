$raw = [System.IO.File]::ReadAllText('d:\insurance-qa\collections\insurance-enterprise-v2-complete.json')
$pos = $raw.IndexOf('usedClientEmails')
Write-Host "usedClientEmails at: $pos"
if ($pos -gt 0) { Write-Host $raw.Substring([Math]::Max(0,$pos-200), 400) }
