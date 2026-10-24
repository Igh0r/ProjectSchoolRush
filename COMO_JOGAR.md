# School Rush — MVP 0.3.0-rc4

A candidata 0.3.0-rc4 acrescenta controles de áudio no menu e na pausa à progressão de dificuldade, oitenta questões, combate e revisão de partida existentes. O aceite da base anterior está registrado; esta fase precisa de um novo playtest.

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

No menu, escolha **Rota clássica** ou **Expedição científica**. Cada uma tem quatro salas e o mesmo sistema de perguntas/recompensas. Reiniciar mantém a rota escolhida; volte ao início para trocar.

Escolha uma das duas perguntas e responda. O banco contém 80 questões para Ensino Médio, vinte por matéria, com temas de revisão, aplicação e interpretação. Cada oferta apresenta duas matérias diferentes; as quatro aparecem nas duas primeiras salas e cada matéria é oferecida duas vezes por partida. As oito questões apresentadas não se repetem dentro da partida.

| Sala | Dificuldade das duas opções | Tipo de raciocínio |
| --- | --- | --- |
| 1 | Fácil | Conceitos e aplicação direta |
| 2 | Médio | Aplicação contextualizada e interpretação |
| 3 | Médio | Consolidação com outros temas e questões |
| 4 | Difícil | Condições, múltiplas etapas e leitura crítica |

Essa curva vale nas duas rotas e continua após reiniciar. O nível aparece antes de escolher a pergunta. Dentro do nível da sala, o jogo prioriza questões ainda não vistas na sessão e depois reutiliza as menos recentes. Uma fácil já vista pode voltar antes de uma difícil inédita para manter o começo acessível. Fechar o jogo limpa esse histórico. Alternativas continuam mudando de posição. As classificações serão refinadas com a revisão de Igor e os playtests.

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
| 4 | Napoleão | Saia da linha de INVESTIDA ou do setor de VARREDURA; ataque quando aparecer ABERTO |

A nuvem e o centurião param de mirar ao iniciar o aviso. Tiros desaparecem nas paredes, ao atingir o jogador ou quando a nuvem morre. A pausa congela monstros e projéteis.

Dados se aproximam por lados diferentes e procuram se separar. Nuvem e cientista se movem entre ataques; o centurião sinaliza a recuperação com um anel azul e ABERTO. Nas salas mistas, até dois ataques especiais ficam em andamento, incluindo tiros e áreas ainda ativos. Os dados continuam causando dano por contato.

Napoleão tenta se aproximar após a investida para usar a varredura. O setor amarelo fica fixo por 0,9 s antes de causar dano: afaste-se ou passe para trás dele. Ambos os golpes abrem 1,2 s de recuperação.

Na **Expedição científica**, os encontros mudam:

| Sala | Ambiente e inimigos | Nova ameaça |
| --- | --- | --- |
| 1 | Sala de aula: dois dados | Aquecimento com os controles |
| 2 | Pátio: dado, cacto e nuvem | ESPINHOS: o cacto alterna leques estreitos/largos; as três linhas mostram o próximo disparo |
| 3 | Laboratório: dado, centurião, cientista e nuvem | MISTURA: saia do círculo marcado antes de ficar verde; a área ativa dura 1,2 s |
| 4 | Ginásio: Napoleão | Mesmo chefe da rota clássica |

Cada mistura causa no máximo um acerto. Derrotar o cientista remove suas misturas; derrotar o cacto remove seus espinhos. Pausa, derrota, saída e reinício também controlam esses perigos.

## Resumo e revisão da partida

Ao vencer ou perder, veja os acertos, salas concluídas, tempo e atributos finais. O tempo começa na primeira escolha e inclui leitura, feedback, combate e deslocamento até a saída; pausa, menu e revisão não entram na contagem. Acertos usam como total as perguntas respondidas: uma derrota na primeira sala pode mostrar 1/1, mesmo com 0/4 salas concluídas.

Em **Rever respostas**, percorra suas escolhas, gabaritos e explicações. A primeira página mostra também os acertos por nível; níveis ainda não respondidos são identificados sem contar como erro. A revisão indica se o bônus foi recebido, não teve efeito por atingir o limite ou foi cancelado pela derrota. Use a rolagem ou Tab para acessar os botões de textos longos; **Voltar ao resumo** retorna ao resultado.

**Salvar resumo neste computador** guarda um arquivo JSON e mostra o caminho completo. Depois, use **Abrir pasta dos resumos** para localizá-lo no Explorador. No Windows, a pasta padrão é `%APPDATA%\Godot\app_userdata\School Rush\reports`. Você decide se deseja compartilhá-lo com a equipe; não há envio automático nem solicitação de nome. O arquivo contém versão, rota, data UTC, tempos, resultado, atributos e respostas com explicações. Clicar novamente em salvar reutiliza o mesmo arquivo.

Salve antes de reiniciar ou sair se quiser conservar o registro. Partidas abandonadas pelo menu/reinício não geram relatório. O arquivo não permite retomar a partida nem restaura o histórico de questões ao reabrir o jogo.

## Ajustar o áudio

Abra **Áudio** no menu inicial ou na pausa. Ajuste **Música** e **Efeitos** separadamente entre 0 e 100%; zero silencia o canal. Use mouse ou Tab e setas. O padrão de 100% corresponde aos volumes anteriores do jogo.

**Silenciar efeitos (M)** interrompe os efeitos, preservando o volume escolhido. M continua controlando só os efeitos; para silenciar música, coloque Música em 0%. A música mantém a posição durante o silêncio. O menu inicial não inicia uma música apenas para testar o volume; os ajustes são ouvidos durante a partida ou pela pausa.

As mudanças são imediatas. **Salvar e voltar** mantém as preferências ao reabrir o jogo; **Voltar sem salvar** ou Esc mantém as alterações só até fechar o jogo. **Restaurar padrão** aplica 100% e liga os efeitos; salve depois se quiser conservar esse padrão. Reiniciar uma partida preserva os ajustes da sessão. Ao abrir Áudio pela pausa, Esc retorna à pausa, sem retomar o combate.

As preferências ficam em `%APPDATA%\Godot\app_userdata\School Rush\audio.cfg` no Windows. Se não for possível salvar, o jogo informa e mantém o ajuste durante a sessão, permitindo tentar novamente. Isso não salva progresso da partida.

## Estado da versão

Versão candidata com sprites animados em seis tipos de monstros e quatro pisos derivados da arte fornecida. O jogador e parte da interface/efeitos continuam provisórios: os respectivos pacotes são referências que ainda precisam de preparação. As músicas adicionadas pela equipe foram preservadas; M alterna os efeitos sonoros e não a música de fundo.

O usuário e Igor aprovaram o playtest interno da base em 23/10/2026. O conteúdo ampliado precisa de revisão pedagógica, acompanhada por ID em `data/REVISAO_PEDAGOGICA.md`, e a fase nova terá outra rodada de playtest. As verificações automatizadas não substituem essa avaliação nem o teste em outro computador. O registro e roteiro estão em `PLAYTEST.md`; `ART_ANALYSIS.md` registra a seleção de arte.

## Validar e exportar o projeto

Requisitos: Godot 4.7.2 e templates oficiais de exportação da mesma versão para Windows x64, disponíveis na [página oficial da versão](https://godotengine.org/download/archive/4.7.2-stable/). Configure os templates pelo menu Editor → Gerenciar templates de exportação.

No PowerShell, na pasta do projeto:

```powershell
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe'
.\tools\check.ps1 -Godot 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' -Export
```

O segundo comando executa as dezesseis suítes, incluindo variedade de questões, movimento inimigo, coordenação dos ataques, resumo/revisão de partida e áudio, e exporta `builds/windows/SchoolRush.exe`, com recursos e catálogo embutidos. Distribua a pasta `windows` completa: guia, plano, roteiro, avisos do Godot e referências de arte/revisão. A cópia de `data/curriculum.json` ao lado do executável serve à revisão; modificá-la não altera o jogo exportado. Builds, capturas e caches não entram no Git.

Para revisar questões ou ajustar recompensas, siga [data/README.md](data/README.md) no projeto-fonte e gere uma nova build.

Para integrar os seus sprites às cenas dos monstros, siga [SPRITES.md](SPRITES.md) no projeto-fonte. A arte pode ser substituída sem alterar os ataques ou as colisões.

Para gerar capturas das telas com renderização (abre uma janela temporária):

```powershell
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_preview.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_enemies.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_expansion.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_catalog.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_combat_phase.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_run_report.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_difficulty.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/capture_audio.gd
```

O plano, as decisões e as pendências de aceite estão em `PLANO_MVP.md`.
