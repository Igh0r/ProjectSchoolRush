# School Rush — estudante jogável

Estudante comum com mochila azul-esverdeada e régua de madeira. Visão superior inclinada, para jogo 2D top-down.

## Conteúdo
- `student_spritesheet.png`: atlas transparente de 1344 × 1536 pixels.
- `frames/`: 48 PNGs individuais, cada um com 224 × 192 pixels.
- `student_frames.tres`: recurso SpriteFrames para Godot 4.
- `animations.json`: dimensões, ordem, velocidade e repetição.

## Animações
Seis quadros por animação. Linhas de cima para baixo: walk_down, walk_left, walk_right, walk_up, attack_down, attack_left, attack_right, attack_up. Caminhada: 10 fps, repetição. Ataque: 12 fps, sem repetição.

## Godot 4
1. Copie a pasta `school_rush_player` inteira para a raiz do projeto (`res://school_rush_player/`).
2. Adicione um AnimatedSprite2D e arraste `student_frames.tres` para Sprite Frames.
3. Defina Texture Filter como Nearest para preservar o visual pixelado.
4. Execute, por exemplo, `$AnimatedSprite2D.play("walk_down")` ou `$AnimatedSprite2D.play("attack_right")`.
5. Para repouso, pare a animação de caminhada e selecione o quadro 0.

A escala visual pode ser ajustada no nó. Configure colisão, dano e alcance da régua separadamente no jogo; o arco desenhado é somente visual. Arte criada com geração de imagens; os quadros podem precisar de ajustes finos de alinhamento conforme a escala e a movimentação do jogo.
