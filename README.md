# School Rush — protótipo inicial (Godot 4)

## Executar
1. Instale o Godot 4.x (versão padrão/GDScript).
2. Abra o Gerenciador de Projetos, escolha **Importar** e selecione este `project.godot`.
3. Abra o projeto e pressione **F6** na cena `main.tscn` ou **F5** para executar o projeto.
4. Use WASD ou teclas de direção. O personagem deve parar nas paredes.

## Estrutura
- `main.tscn`: cena inicial
- `scenes/player/player.tscn`: personagem e sua colisão
- `scripts/player/player.gd`: movimentação
- `scripts/systems/main.gd`: controles, arena e paredes temporárias

## Escopo desta entrega
Uma arena 2D e um personagem controlável com colisão. Nenhum sprite externo necessário: o personagem e o cenário são desenhados com primitivas do Godot.

## Próxima etapa
Adicionar disparo de projéteis na direção do mouse e um inimigo que segue o jogador. Depois, separar a arena procedural provisória em cenas de salas reutilizáveis.

## Observação
Os controles são registrados em runtime; os arquivos `project.godot` e `main.tscn` podem ser editados normalmente pelo Godot.
