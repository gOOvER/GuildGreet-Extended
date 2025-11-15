$usedKeys = @()

# Get all Lua files
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

# Remove duplicates and sort
$usedKeys = $usedKeys | Sort-Object -Unique

Write-Output "Gefundene L[...] Keys aus dem Code:"
Write-Output "================================="
$usedKeys | ForEach-Object { Write-Output $_ }
Write-Output ""
Write-Output "Anzahl gefundene Keys: $($usedKeys.Count)"