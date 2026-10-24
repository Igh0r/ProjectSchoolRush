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
foreach ($suite in @('catalog', 'question_variety', 'combat', 'progression', 'run', 'run_report', 'audio', 'movement', 'health', 'rewards', 'enemies', 'enemy_movement', 'attack_coordination', 'encounters', 'art', 'science_route')) {
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
    Copy-Item -LiteralPath (Join-Path $projectRoot 'ART_ANALYSIS.md') -Destination (Join-Path $buildRoot 'windows/ART_ANALYSIS.md')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'PLANO_MVP.md') -Destination (Join-Path $buildRoot 'windows/PLANO_MVP.md')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'SPRITES.md') -Destination (Join-Path $buildRoot 'windows/SPRITES.md')
    New-Item -ItemType Directory -Path (Join-Path $buildRoot 'windows/data') -Force | Out-Null
    foreach ($referenceFile in @('README.md', 'REVISAO_PEDAGOGICA.md', 'curriculum.json')) {
        Copy-Item -LiteralPath (Join-Path $projectRoot "data/$referenceFile") -Destination (Join-Path $buildRoot "windows/data/$referenceFile")
    }
    $versionMatch = [regex]::Match((Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw), '(?m)^config/version="([^"]+)"')
    $sourceCommit = & git -c core.fsmonitor=false -C $projectRoot rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao identificar o commit da build.' }
    $sourceChanges = @(& git -c core.fsmonitor=false -C $projectRoot status --porcelain)
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao verificar o estado do projeto.' }
    @(
        "School Rush MVP $($versionMatch.Groups[1].Value)",
        'Godot 4.7.2 - Windows x64',
        "Source base commit: $sourceCommit",
        "Source modified at export: $($sourceChanges.Count -gt 0)",
        '80 questions; session history; shuffled options; six enemy types; two routes.',
        'Room difficulty: basic, intermediate, intermediate, challenge. Results grouped by difficulty.',
        'Validation: 16 suites. Includes run review, optional reports and saved audio preferences.',
        'See PLAYTEST.md for the pending human evaluation of this candidate.',
        'data/curriculum.json is a review copy; the game loads the embedded catalog.'
    ) | Set-Content -LiteralPath (Join-Path $buildRoot 'windows/BUILD_INFO.txt') -Encoding UTF8
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
