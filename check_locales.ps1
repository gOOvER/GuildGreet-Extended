# Get all defined keys from language files
$enUSKeys = @()
$deDEKeys = @()

# Read enUS.lua
$lines = Get-Content 'x:\Github Workspace\WoW Addons\GuildGreet-Extended\lang\enUS.lua' -Encoding UTF8
foreach ($line in $lines) {
    if ($line -match 'L\[([''"])([^\1]*?)\1\]\s*=') {
        $key = $matches[2]
        if ($key -ne '') { 
            $enUSKeys += $key 
        }
    }
}

# Read deDE.lua  
$lines = Get-Content 'x:\Github Workspace\WoW Addons\GuildGreet-Extended\lang\deDE.lua' -Encoding UTF8
foreach ($line in $lines) {
    if ($line -match 'L\[([''"])([^\1]*?)\1\]\s*=') {
        $key = $matches[2]
        if ($key -ne '') { 
            $deDEKeys += $key 
        }
    }
}

# Remove duplicates and sort
$enUSKeys = $enUSKeys | Sort-Object -Unique
$deDEKeys = $deDEKeys | Sort-Object -Unique

Write-Output "Definierte Keys in enUS.lua: $($enUSKeys.Count)"
Write-Output "Definierte Keys in deDE.lua: $($deDEKeys.Count)"
Write-Output ""

# Show first few keys from each
Write-Output "Erste 20 enUS Keys:"
$enUSKeys | Select-Object -First 20 | ForEach-Object { Write-Output "  $_" }
Write-Output ""
Write-Output "Erste 20 deDE Keys:"  
$deDEKeys | Select-Object -First 20 | ForEach-Object { Write-Output "  $_" }