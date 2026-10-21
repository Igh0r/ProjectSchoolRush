# Usar sprites nos monstros

As cenas estão em `scenes/enemies/`: `dice.tscn`, `cloud.tscn`, `centurion.tscn` e `boss.tscn`. Cada uma separa o corpo físico, `CollisionShape2D`, do desenho em `Visual/AnimatedSprite2D`. Sem frames configurados, o jogo usa formas provisórias.

1. Copie os PNGs ou spritesheets para uma pasta como `assets/monsters/` no projeto. Aguarde a importação do Godot.
2. Abra a cena do monstro e selecione `Visual/AnimatedSprite2D`.
3. No Inspector, abra o recurso **Sprite Frames**. Se for compartilhar um recurso já usado por outro monstro, use **Make Unique** antes de alterá-lo.
4. Preencha a animação `idle`. Para imagens individuais, arraste os arquivos para os frames; para uma spritesheet, use **Add frames from a sprite sheet**, informe a grade e selecione os quadros na ordem desejada. Uma imagem única em `idle` também funciona.
5. Opcionalmente adicione `move`, `attack` e `hurt`. O código usa `idle` quando a animação solicitada não existe ou está vazia. Ajuste FPS e loop no recurso.
6. Ajuste escala e posição do nó visual para centralizar o personagem no círculo de colisão. O filtro está em Nearest para pixel art; use Linear se o estilo da arte pedir suavização.
7. Rode o jogo e confira as quatro salas, dano, pausa e reinício. Os avisos de ataque e barras de vida continuam sendo desenhados pelo código.

Não altere a escala do nó raiz para corrigir o tamanho da imagem: isso também muda a colisão e as distâncias do combate. O jogador atinge os centros dos monstros até 60 px; preserve uma silhueta compatível com a área física. Raios atuais: dado e nuvem 16 px, centurião 18 px, Napoleão 24 px.

O aviso de ataque é independente da duração da animação: nuvem 0,8 s, centurião 0,75 s, Napoleão 0,8 s. A animação `attack` é decorativa e não dispara dano por frame. `hurt` é um feedback breve, podendo ser substituído pela animação de movimento no próximo frame; o clarão continua durante 0,12 s. Este MVP remove o monstro ao morrer e ainda não espera uma animação `death`.

Use `tests/capture_enemies.gd` para conferir os avisos em 960×540 e 1280×720. Não cubra o cone, a linha de mira ou as barras com um sprite muito grande. Depois execute `tools/check.ps1` e gere uma nova build. Verifique a licença dos arquivos que escolher distribuir.

Nenhum sprite de monstro foi encontrado no projeto nesta entrega; as cenas estão preparadas, mas a arte final ainda não foi integrada.
