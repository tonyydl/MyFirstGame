param([string]$Godot = '')

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $Godot) {
    $localGodot = Join-Path $projectRoot '.tools\godot.console.exe'
    $Godot = if (Test-Path -LiteralPath $localGodot) { $localGodot } else { 'godot' }
}
$godotCommand = (Get-Command $Godot -ErrorAction Stop).Source
$logDirectory = Join-Path $projectRoot '.tools\validation'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
$previousAppData = $env:APPDATA
$previousLocalAppData = $env:LOCALAPPDATA
$env:APPDATA = Join-Path $projectRoot '.tools\appdata'
$env:LOCALAPPDATA = Join-Path $projectRoot '.tools\localappdata'
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
$script:certificateWarning = $false

function Invoke-GodotCheck([string]$Name, [string[]]$Arguments, [bool]$RequirePass = $false) {
    $logPath = Join-Path $logDirectory "$Name.log"
    $output = & $godotCommand --headless --path $projectRoot --log-file $logPath @Arguments 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    # This Windows sandbox cannot access the OS certificate store. Keep the
    # original log; exempt only this exact diagnostic, never GDScript errors.
    $knownDiagnostic = '(?m)^ERROR: Failed to read the root certificate store\.\r?\n\s+at: get_system_ca_certificates \(platform/windows/os_windows\.cpp:\d+\)\r?\n'
    if ($output -match $knownDiagnostic) { $script:certificateWarning = $true }
    $checkedOutput = $output -replace $knownDiagnostic, ''
    if ($exitCode -ne 0 -or $checkedOutput -match '(?m)(SCRIPT ERROR:|ERROR:|WARNING:)' -or ($RequirePass -and $output -notmatch 'PASS:')) {
        Write-Output $output
        throw "$Name failed (exit=$exitCode). Log: $logPath"
    }
    Write-Output "PASS: $Name (exit=0)"
}

try {
    Invoke-GodotCheck 'import' @('--editor', '--quit')
    foreach ($testName in @('navigation', 'movement', 'combat', 'game_flow')) {
        Invoke-GodotCheck $testName @('--script', "res://tests/test_$testName.gd") $true
    }
    Invoke-GodotCheck 'main-menu' @('--quit-after', '10')
    Invoke-GodotCheck 'battlefield' @('--scene', 'res://scenes/battlefield.tscn', '--quit-after', '10')
    if ($script:certificateWarning) {
        Write-Output 'Environment note: Windows root certificate store is unavailable; original diagnostic retained in logs. No other errors were exempted.'
    }
    Write-Output "Logs: $logDirectory"
}
finally {
    $env:APPDATA = $previousAppData
    $env:LOCALAPPDATA = $previousLocalAppData
}
