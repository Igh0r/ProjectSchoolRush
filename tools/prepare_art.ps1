param([string]$ArtRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'art'))
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $ArtRoot 'inimigos trabalho/Inimigos_2D_PixelArt_Unity_HD_CORRIGIDOS_DE_VERDADE'
$assetRoot = Join-Path $projectRoot 'assets/monsters'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$specs = @(
    @{Id='dice'; Folder='01_Dado_Flutuante'; Count=4; Rate=20},
    @{Id='centurion'; Folder='02_Centuriao_Romano'; Count=4; Rate=24},
    @{Id='cloud'; Folder='03_Nuvem_Tempestade'; Count=4; Rate=20},
    @{Id='scientist'; Folder='05_Cientista'; Count=3; Rate=10},
    @{Id='cactus'; Folder='06_Cacto_Lancador_de_Espinhos'; Count=3; Rate=10},
    @{Id='boss'; Folder='07_Napoleao_Boss'; Count=0; Rate=6}
)
$manifest = @()
foreach ($spec in $specs) {
    $destRoot = Join-Path $assetRoot $spec.Id
    New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
    $idleName = if ($spec.Id -eq 'boss') { 'idle_spritesheet_HD.png' } else { 'idle_spritesheet.png' }
    $source = Join-Path (Join-Path $sourceRoot $spec.Folder) $idleName
    Copy-Item -LiteralPath $source -Destination (Join-Path $destRoot 'idle.png')
    $manifest += "$($spec.Id)/idle.png`t$((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash)`t$source"
    if ($spec.Count -gt 0) {
        $source = Join-Path (Join-Path $sourceRoot $spec.Folder) 'attack_spritesheet.png'
        Copy-Item -LiteralPath $source -Destination (Join-Path $destRoot 'attack.png')
        $manifest += "$($spec.Id)/attack.png`t$((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash)`t$source"
    }
    $resources = [System.Collections.Generic.List[string]]::new()
    $resources.Add('[gd_resource type="SpriteFrames" load_steps=' + (6 + $spec.Count + [int]($spec.Count -gt 0)) + ' format=3]')
    $resources.Add('[ext_resource type="Texture2D" path="res://assets/monsters/' + $spec.Id + '/idle.png" id="idle"]')
    if ($spec.Count -gt 0) { $resources.Add('[ext_resource type="Texture2D" path="res://assets/monsters/' + $spec.Id + '/attack.png" id="attack"]') }
    foreach ($animation in @('idle','attack')) {
        $count = if ($animation -eq 'idle') { 4 } else { $spec.Count }
        for ($frame = 0; $frame -lt $count; $frame++) {
            $region = if ($spec.Id -eq 'boss') { "$($frame * 512 + 128), 48, 352, 416" } else { "$($frame * 384), 0, 384, 384" }
            $resources.Add('[sub_resource type="AtlasTexture" id="' + $animation + $frame + '"]')
            $resources.Add('atlas = ExtResource("' + $animation + '")')
            $resources.Add('region = Rect2(' + $region + ')')
        }
    }
    $animations = @()
    foreach ($animation in @('idle','attack')) {
        $count = if ($animation -eq 'idle') { 4 } else { $spec.Count }
        if ($count -eq 0) { continue }
        $frameRefs = @()
        for ($frame = 0; $frame -lt $count; $frame++) { $frameRefs += '{"duration": 1.0, "texture": SubResource("' + $animation + $frame + '")}' }
        $loop = if ($animation -eq 'idle') { 'true' } else { 'false' }
        $rate = if ($animation -eq 'idle') { 6 } else { $spec.Rate }
        $animations += '{"frames": [' + ($frameRefs -join ', ') + '], "loop": ' + $loop + ', "name": &"' + $animation + '", "speed": ' + $rate + '.0}'
    }
    $resources.Add('[resource]')
    $resources.Add('animations = [' + ($animations -join ",`n") + ']')
    [System.IO.File]::WriteAllText((Join-Path $destRoot 'frames.tres'), ($resources -join "`n`n") + "`n", $utf8)
}
$manifest | Set-Content -LiteralPath (Join-Path $projectRoot 'builds/art-source-hashes.txt') -Encoding UTF8
Write-Output 'Sprites copiados sem alterar pixels; AtlasTexture e SpriteFrames gerados.'
