# School Rush — MVP 0.2.0-rc1

## Jogar

No Windows 64 bits, abra `SchoolRush.exe` na pasta da build. Não é necessário instalar o editor Godot. No projeto-fonte, abra `project.godot` no Godot 4.7.2 e pressione F6 na cena `main.tscn` ou F5 para executar o projeto.

| Tecla | Ação |
| --- | --- |
| WASD ou setas | Mover e orientar a régua |
| Shift | Correr |
| Espaço | Atacar; pode manter pressionado |
| E | Avançar perto da porta verde após vencer a sala |
| Esc | Pausar ou continuar durante combate/saída |
| M | Ligar/desligar efeitos sonoros |
| Mouse ou Tab + Enter | Selecionar opções nos menus |

Escolha uma das duas perguntas e responda. O banco contém 20 questões de revisão introdutória para Ensino Médio, cinco por matéria. Cada oferta apresenta duas matérias diferentes; as quatro aparecem nas duas primeiras salas e cada matéria é oferecida duas vezes por partida. As oito questões apresentadas não se repetem dentro da partida.

| Matéria | Bônus por acerto, recebido após vencer a sala |
| --- | --- |
| Matemática | +2 de dano da régua |
| História | Recupera 20 de vida, até o máximo atual |
| Ciências | +10 de vida máxima e recupera 10 de vida |
| Português | +5% da velocidade inicial, acumulando até +20% |

Errar não impede avançar. Morrer antes de vencer a sala cancela o bônus reservado. A velocidade também afeta a corrida; na partida atual de quatro salas, Português pode ser escolhido no máximo duas vezes (+10%). Consulte os atributos na pausa ou na tela de vitória.

A barra no canto superior esquerdo mostra a vida atual e máxima. Avisos indicam quanto você perdeu ou recuperou; com 25% ou menos, aparece “VIDA BAIXA”. Cada nova partida começa com 100/100 de vida, dano 10 e velocidade sem bônus. Ciências atualiza tanto o limite quanto a barra.

Vença três salas e Napoleão no ginásio. O golpe da régua atinge um cone na última direção de movimento: aproxime-se, golpeie e recue. Ao perder toda a vida, a partida termina e os atributos são restaurados no reinício.

| Sala | Encontro | Como enfrentar |
| --- | --- | --- |
| 1 | Dois dados | Eles perseguem e causam dano por contato; golpeie e recue |
| 2 | Dois dados e uma nuvem | O aviso DISPARO e a linha marcam a mira fixa; desvie para o lado e aproxime-se entre tiros |
| 3 | Dois dados, uma nuvem e um centurião | O setor marcado GOLPE anuncia o ataque frontal; saia do setor e ataque na recuperação |
| 4 | Napoleão | Desvie da linha amarela e aproveite a recuperação entre investidas |

A nuvem e o centurião param de mirar ao iniciar o aviso. Tiros desaparecem nas paredes, ao atingir o jogador ou quando a nuvem morre. A pausa congela monstros e projéteis.

## Estado da versão

Versão candidata da expansão, com formas e sons provisórios. O conteúdo educacional ainda precisa da revisão da equipe, e o balanceamento precisa de playtest. As verificações automatizadas não substituem uma partida manual nem o teste em outro computador. O roteiro e a ficha de registro estão em `PLAYTEST.md`, incluído na distribuição.

## Validar e exportar o projeto

Requisitos: Godot 4.7.2 e templates oficiais de exportação da mesma versão para Windows x64, disponíveis na [página oficial da versão](https://godotengine.org/download/archive/4.7.2-stable/). Configure os templates pelo menu Editor → Gerenciar templates de exportação.

No PowerShell, na pasta do projeto:

```powershell
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe'
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' -Export
```

O segundo comando executa as nove suítes (catálogo, combate, progressão, partida, movimento, vida, recompensas, monstros e encontros) e exporta `builds/windows/SchoolRush.exe`, com os recursos e o catálogo JSON embutidos. Distribua a pasta `windows` junto com `GODOT_NOTICES.txt`, este guia e `PLAYTEST.md`. Builds, capturas e caches não entram no Git.

Para revisar questões ou ajustar recompensas, siga [data/README.md](data/README.md) no projeto-fonte e gere uma nova build.

Para integrar os seus sprites às cenas dos monstros, siga [SPRITES.md](SPRITES.md) no projeto-fonte. A arte pode ser substituída sem alterar os ataques ou as colisões.

Para gerar capturas das telas com renderização (abre uma janela temporária):

```powershell
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_preview.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_enemies.gd
```

O plano, as decisões e as pendências de aceite estão em `PLANO_MVP.md`.
