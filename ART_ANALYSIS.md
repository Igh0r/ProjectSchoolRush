# Análise dos pacotes de arte — 22/10/2026

**Atualização de 25/10/2026:** o usuário forneceu `school_rush_player`, com um estudante sem nome próprio. Os 48 PNGs transparentes e `student_frames.tres` foram integrados diretamente, substituindo o círculo do jogador. Caminhada e ataque têm quatro direções e seis quadros cada. O pacote anterior de personagens nomeados foi substituído por essa decisão; seus arquivos originais continuam preservados.

Foram inventariados os onze ZIPs e a pasta de inimigos extraída em `art/`. A análise conferiu os READMEs, as folhas de referência de cada categoria, os sprites selecionados e os cenários individuais. Arquivos preparados para Unity podem fornecer imagens ao Godot; scripts C# de Unity não são componentes utilizáveis diretamente neste projeto.

| Material | Situação encontrada | Uso decidido |
| --- | --- | --- |
| Inimigos HD corrigidos | PNG RGBA transparente; células reais de 384×384 para comuns e 512×512 para Napoleão | Integrar dado, centurião, nuvem e Napoleão; preparar cientista e cacto para a nova rota |
| Babuíno | Arte disponível; comportamento ainda não implementado | Reservar para outra expansão, sem criar um inimigo apenas com aparência diferente |
| ZIP antigo dos inimigos | Outra versão da mesma coleção, com enquadramento diferente | Usar a revisão HD já extraída para evitar mistura de escalas e recortes |
| Cenários individuais HD | Vinte imagens completas de ambientes, quatro variações de cinco locais | Reaproveitar regiões de piso; não tratar a imagem como mapa de colisão |
| Cenários “arte aprovada” | Composição e recortes de referência | Consulta visual; preferir as imagens individuais na integração |
| Pranchas antigas de personagens | Folhas com títulos, fundo opaco e quadros de tamanhos irregulares | Referência histórica; substituídas pelo estudante sem nome próprio fornecido em 25/10 |
| Estudante (`school_rush_player`) | 48 PNGs transparentes de 224×192, oito animações e SpriteFrames Godot | Integrado em E6; origem e orientação preservadas, escala visual 0,28 e deslocamento vertical −8 px |
| Armas | Recortes de uma prancha com fundo, rótulos e diferentes vistas | Referência para régua/lapiseira; preparar PNGs transparentes antes de uso direto |
| HUD e perguntas | Layouts de exemplo com textos já desenhados | Referência de estilo; preservar texto real e botões acessíveis em `Control` |
| Efeitos | Pranchas com vários efeitos e legendas | Exigem recorte e transparência; manter avisos de combate atuais legíveis |
| Props e tileset | Categorias recortadas da prancha; não é um atlas regular de tiles 32×32 | Preparação adicional antes de montar TileSet e colisões |
| Implementação Unity | Scripts e checklist de outro motor | Referência de ideias; não importados como código Godot |

## Integração dos monstros

Origem: `art/inimigos trabalho/Inimigos_2D_PixelArt_Unity_HD_CORRIGIDOS_DE_VERDADE/`. Os PNGs selecionados são copiados sem alterações de pixels para `assets/monsters/<id>/`. `tools/prepare_art.ps1` reproduz a cópia e gera recursos `SpriteFrames` com `AtlasTexture`; a execução também grava hashes SHA-256 locais em `builds/art-source-hashes.txt`.

Os seis recursos usam quatro quadros de `idle`. Dado, nuvem e centurião têm quatro quadros de ataque. Cientista e cacto usam somente os três primeiros: o quarto quadro é um projétil/efeito isolado, não o corpo. A revisão HD de Napoleão contém apenas idle; sua investida usa essa animação e o aviso desenhado pelo código, sem inventar frames ausentes.

Nos comuns, os recortes são células de 384×384. Em Napoleão, a região fixa `(128, 48, 352, 416)` dentro de cada célula de 512×512 centraliza o corpo e exclui um pequeno fragmento periférico. Não há edição destrutiva dos PNGs. O `AnimatedSprite2D` usa escala 0,16 e filtro Nearest; o corpo e os raios físicos permanecem iguais.

Os sprites são imagens com uma vista predominante, não animações completas em quatro direções. Centurião e Napoleão podem espelhar horizontalmente; a direção real de ataque é indicada pelos avisos. O golpe visual do centurião começa no estado de ataque, depois do aviso, sem antecipar dano.

## Organização

Sala de aula, pátio, laboratório e ginásio usam a variação 01 de `Cenarios_2D_Individuais_HD.zip`, copiada para `assets/rooms/` pelo mesmo preparador. `room.gd` desenha somente regiões abertas de piso, com redução de brilho para destacar atores e avisos. Móveis, portas decorativas e paredes pintadas na imagem não são usados como obstáculos falsos. As paredes físicas e a saída continuam explícitas no jogo.

`art/` guarda os originais locais e tem `.gdignore`, evitando a importação indiscriminada de pranchas e duplicatas. Os pacotes brutos ficam fora do Git; os recursos usados em `assets/` e seus arquivos `.import` são versionados. A build usa somente as cópias de produção e não depende da presença dos ZIPs.

O material foi fornecido pelo usuário. Os READMEs descrevem sua preparação, mas não identificam uma licença externa nem comprovam autoria; registrar a procedência/licença da coleção antes da distribuição pública. Isso não impede a integração e avaliação local solicitadas.

## Preparação restante

A preparação das pranchas antigas de personagens deixou de ser necessária para o MVP: E6 usa o estudante sem nome próprio do novo pacote. Para tiles/props/armas/efeitos adicionais, definir recortes e separar os rótulos da arte. Para HUD/perguntas, reconstruir o layout em controles reais, aproveitando elementos limpos quando disponíveis. Esses materiais permanecem preservados nos pacotes originais.

## Integração do estudante

O PNG original, o atlas e os quadros individuais recebidos permanecem em `school_rush_player`, sem alterações de pixels. O jogo referencia somente o SpriteFrames e os quadros individuais; o atlas duplicado e `source_generated.png` são excluídos do executável. O `LEIA-ME.md` fornecido informa geração de imagens como origem.

A escala fica apenas no `AnimatedSprite2D`; corpo físico e alcance não mudam. Repouso usa o primeiro quadro da caminhada. O ataque começa no quarto quadro, que já contém o impacto, e toca a recuperação a 15 fps. Isso preserva o dano imediato da régua; os três quadros de antecipação originais permanecem disponíveis, mas não são usados no fluxo atual. Não há animações dedicadas de dano/morte: tintura, anel de invulnerabilidade e congelamento comunicam esses estados. Detalhes em [SPRITES.md](SPRITES.md).
