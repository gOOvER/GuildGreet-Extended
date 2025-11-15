# Get used keys from code
$usedKeys = @()
$files = @(
    'x:\Github Workspace\WoW Addons\GuildGreet-Extended\GuildGreet.lua'
) + (Get-ChildItem 'x:\Github Workspace\WoW Addons\GuildGreet-Extended\libs\*.lua')

foreach ($file in $files) {
    $lines = Get-Content $file -Encoding UTF8
    foreach ($line in $lines) {
        # Match L["key"] or L['key']
        $matches = [regex]::Matches($line, 'L\[([''"])([^\1]*?)\1\]')
        foreach ($match in $matches) {
            $key = $match.Groups[2].Value
            if ($key -ne '') { 
                $usedKeys += $key 
            }
        }
    }
}
$usedKeys = $usedKeys | Sort-Object -Unique

# Get defined keys from language files
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

$enUSKeys = $enUSKeys | Sort-Object -Unique
$deDEKeys = $deDEKeys | Sort-Object -Unique

# Find missing keys
$missingInEnUS = $usedKeys | Where-Object { $_ -notin $enUSKeys }
$missingInDeDE = $usedKeys | Where-Object { $_ -notin $deDEKeys }

Write-Output "=== LOKALISIERUNGS-ANALYSE ==="
Write-Output "Verwendete Keys im Code: $($usedKeys.Count)"
Write-Output "Definierte Keys in enUS.lua: $($enUSKeys.Count)"
Write-Output "Definierte Keys in deDE.lua: $($deDEKeys.Count)"
Write-Output ""

Write-Output "=== FEHLENDE KEYS IN enUS.lua ($($missingInEnUS.Count)) ==="
$missingInEnUS | ForEach-Object { Write-Output "  $_" }
Write-Output ""

Write-Output "=== FEHLENDE KEYS IN deDE.lua ($($missingInDeDE.Count)) ==="
$missingInDeDE | ForEach-Object { Write-Output "  $_" }
Write-Output ""

# Additional check for keys in enUS but not in deDE  
$inEnUSNotInDeDE = $enUSKeys | Where-Object { $_ -notin $deDEKeys }
Write-Output "=== KEYS IN enUS.lua ABER NICHT IN deDE.lua ($($inEnUSNotInDeDE.Count)) ==="
$inEnUSNotInDeDE | ForEach-Object { Write-Output "  $_" }