# School Rush — MVP 0.1.1

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

Escolha uma das duas perguntas e responda. Acertar Matemática reserva +2 de dano; História reserva +20 de vida (até a vida máxima). O bônus só é recebido ao eliminar todos os inimigos. Errar não impede avançar. As perguntas apresentadas não se repetem dentro da partida.

A barra no canto superior esquerdo mostra a vida atual e máxima. Avisos indicam quanto você perdeu ou recuperou; com 25% ou menos, aparece “VIDA BAIXA”. Cada nova partida começa com 100/100 de vida. A estrutura permite ampliar a vida máxima, mas essa recompensa ainda não está disponível nesta versão.

Vença três salas de dados e Napoleão no ginásio. O golpe da régua atinge um cone na última direção de movimento: aproxime-se, golpeie e recue. Contra Napoleão, desvie da linha amarela e aproveite a recuperação entre investidas. Ao perder toda a vida, a partida termina e os atributos são restaurados no reinício.

## Estado da versão

Protótipo funcional com formas e sons provisórios. O conteúdo educacional ainda precisa da revisão da equipe, e o balanceamento precisa de playtest. As verificações automatizadas não substituem uma partida manual nem o teste em outro computador.

## Validar e exportar o projeto

Requisitos: Godot 4.7.2 e templates oficiais de exportação da mesma versão para Windows x64, disponíveis na [página oficial da versão](https://godotengine.org/download/archive/4.7.2-stable/). Configure os templates pelo menu Editor → Gerenciar templates de exportação.

No PowerShell, na pasta do projeto:

```powershell
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe'
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' -Export
```

O segundo comando executa as cinco suítes e exporta `builds/windows/SchoolRush.exe`, com os recursos embutidos. Distribua a pasta `windows` junto com `GODOT_NOTICES.txt` e este guia. Builds, capturas e caches não entram no Git.

Para gerar capturas das telas com renderização (abre uma janela temporária):

```powershell
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_preview.gd
```

O plano, as decisões e as pendências de aceite estão em `PLANO_MVP.md`.
