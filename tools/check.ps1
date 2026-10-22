param(
    [string]$Godot = 'godot',
    [switch]$Export
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Invoke-GodotCheck {
    param([string[]]$Arguments)
    $result = @(& $Godot --headless --path $projectRoot @Arguments 2>&1)
    $code = $LASTEXITCODE
    $result | ForEach-Object { Write-Output $_ }
    if ($code -ne 0 -or ($result -join "`n") -match '(?m)^(SCRIPT ERROR|ERROR):') {
        throw "Godot falhou: $($Arguments -join ' ')"
    }
}

Invoke-GodotCheck -Arguments @('--editor', '--import', '--quit')
foreach ($suite in @('catalog', 'combat', 'progression', 'run', 'movement', 'health', 'rewards', 'enemies', 'encounters', 'art', 'science_route')) {
    Invoke-GodotCheck -Arguments @('--script', "res://tests/test_$suite.gd")
}
if ($Export) {
    $buildRoot = Join-Path $projectRoot 'builds'
    New-Item -ItemType Directory -Path (Join-Path $buildRoot 'windows') -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $buildRoot '.gdignore') -Force | Out-Null
    Invoke-GodotCheck -Arguments @('--export-release', 'Windows Desktop', 'builds/windows/SchoolRush.exe')
    Invoke-GodotCheck -Arguments @('--script', 'res://tools/write_notices.gd')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'COMO_JOGAR.md') -Destination (Join-Path $buildRoot 'windows/COMO_JOGAR.md')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'PLAYTEST.md') -Destination (Join-Path $buildRoot 'windows/PLAYTEST.md')
    $smokeLog = Join-Path $buildRoot 'standalone-smoke.log'
    $smokeErrors = Join-Path $buildRoot 'standalone-smoke-errors.log'
    $gameProcess = Start-Process -FilePath (Join-Path $buildRoot 'windows/SchoolRush.exe') -ArgumentList @('--headless', '--quit-after', '120') -WorkingDirectory (Join-Path $buildRoot 'windows') -WindowStyle Hidden -RedirectStandardOutput $smokeLog -RedirectStandardError $smokeErrors -PassThru
    # Preserve o handle antes de esperar: Windows PowerShell pode perder o ExitCode após a saída.
    $null = $gameProcess.Handle
    if (-not $gameProcess.WaitForExit(15000)) {
        $gameProcess.Kill()
        throw 'O teste de inicialização do executável excedeu 15 segundos.'
    }
    $gameProcess.Refresh()
    $smokeOutput = (Get-Content -LiteralPath $smokeLog -Raw) + (Get-Content -LiteralPath $smokeErrors -Raw)
    Write-Output $smokeOutput
    if ($gameProcess.ExitCode -ne 0 -or $smokeOutput -match '(?m)^(SCRIPT ERROR|ERROR):') {
        throw "O executável exportado falhou no teste de inicialização (código: $($gameProcess.ExitCode))."
    }
}
Write-Output 'Verificações concluídas sem falhas.'
