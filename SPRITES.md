# Sprites do estudante e dos monstros

## Estudante sem nome próprio

O protagonista é um estudante, sem nome próprio, conforme a decisão de 25/10/2026. A cena `scenes/player/player.tscn` usa `school_rush_player/student_frames.tres` no nó `AnimatedSprite2D`, com os PNGs originais enviados pelo usuário. São seis quadros de 224×192 em cada uma de oito animações: `walk_down/left/right/up` e `attack_down/left/right/up`.

- Visual com filtro Nearest, escala 0,28 e posição `(0, -8)`. Ajuste esse nó para alterar aparência; mantenha raiz e colisão em escala 1, raio 15.
- Caminhada usa 10 fps; corrida/bônus ajustam a reprodução proporcionalmente ao movimento. Parado, usa o quadro 0 da última direção.
- Ataque inicia no índice 3 (impacto), usando quadros 3–5 a 15 fps. Os quadros 0–2 de antecipação continuam no recurso original, mas não são reproduzidos para não atrasar o golpe instantâneo existente. Recarga continua 0,4 s e alcance 60 px; a animação não dispara dano.
- Quatro vistas representam oito direções de movimento: na diagonal com eixos iguais, usa a vista vertical. A direção física continua diagonal; indicador e arco dourados mostram a orientação/alcance reais. O ataque visual mantém a direção capturada no golpe.
- Pausa congela reprodução e recarga. Dano tinge o sprite brevemente e mostra anel durante invulnerabilidade; morte congela e escurece. Reinício limpa esses estados.

Não é necessário regenerar a arte. `source_generated.png` e `student_spritesheet.png` ficam como referências, fora do executável; os 48 quadros individuais são os recursos usados. Para conferir a integração, execute `tests/test_player_visual.gd` ou a suíte completa e gere capturas com `tests/capture_player.gd`.

## Monstros

As cenas estão em `scenes/enemies/`: `dice.tscn`, `cloud.tscn`, `centurion.tscn`, `boss.tscn`, `cactus.tscn` e `scientist.tscn`. Cada uma separa o corpo físico, `CollisionShape2D`, do desenho em `Visual/AnimatedSprite2D`. Os sprites fornecidos em `art/` já estão ligados aos recursos em `assets/monsters/`. Sem frames configurados, o jogo usa formas provisórias.

1. Copie os PNGs ou spritesheets para uma pasta como `assets/monsters/` no projeto. Aguarde a importação do Godot.
2. Abra a cena do monstro e selecione `Visual/AnimatedSprite2D`.
3. No Inspector, abra o recurso **Sprite Frames**. Se for compartilhar um recurso já usado por outro monstro, use **Make Unique** antes de alterá-lo.
4. Preencha a animação `idle`. Para imagens individuais, arraste os arquivos para os frames; para uma spritesheet, use **Add frames from a sprite sheet**, informe a grade e selecione os quadros na ordem desejada. Uma imagem única em `idle` também funciona.
5. Opcionalmente adicione `move`, `attack` e `hurt`. O código usa `idle` quando a animação solicitada não existe ou está vazia. Ajuste FPS e loop no recurso.
6. Ajuste escala e posição do nó visual para centralizar o personagem no círculo de colisão. O filtro está em Nearest para pixel art; use Linear se o estilo da arte pedir suavização.
7. Rode o jogo e confira as quatro salas, dano, pausa e reinício. Os avisos de ataque e barras de vida continuam sendo desenhados pelo código.

Não altere a escala do nó raiz para corrigir o tamanho da imagem: isso também muda a colisão e as distâncias do combate. O jogador atinge os centros dos monstros até 60 px; preserve uma silhueta compatível com a área física. Raios atuais: dado e nuvem 16 px, centurião 18 px, Napoleão 24 px.

O aviso de ataque é independente da duração da animação: nuvem 0,8 s, centurião 0,75 s, Napoleão 0,8 s, cacto 0,95 s e cientista 1 s. A animação `attack` é decorativa e não dispara dano por frame. A coleção não fornece `hurt` separado: o clarão continua durante 0,12 s sobre a animação disponível. Este MVP remove o monstro ao morrer e ainda não espera uma animação `death`.

Use `tests/capture_enemies.gd` para conferir os avisos em 960×540 e 1280×720. Não cubra o cone, a linha de mira ou as barras com um sprite muito grande. Depois execute `tools/check.ps1` e gere uma nova build. Verifique a licença dos arquivos que escolher distribuir.

Em 22/10/2026, a coleção foi analisada e os monstros selecionados foram integrados. Veja [ART_ANALYSIS.md](ART_ANALYSIS.md) para origem, limitações e materiais que ainda exigem preparação. `tools/prepare_art.ps1` regenera os recursos a partir da pasta original; não é necessário executá-lo para jogar ou exportar um checkout com `assets/`.
