# School Rush — análise e plano de execução do MVP

Data: 19/10/2026. Proposta de escopo para a equipe, sujeita a playtest.

**Situação atual (21/10/2026):** ciclo completo implementado (M1–M4), B1 e B2 concluídos: barra de vida, quatro disciplinas e recompensas configuráveis. Versão Windows atual: **0.1.2**, entrega incremental da expansão 0.2. Público confirmado: **Ensino Médio**. M5 permanece aberto para playtest humano, revisão pedagógica e validação em outro PC. Instruções em [COMO_JOGAR.md](COMO_JOGAR.md).

## Objetivo e situação atual

### Expansão 0.2 — blocos de execução

A expansão será entregue em blocos, preservando o ciclo de quatro salas. Os marcos M1–M5 abaixo registram a base 0.1.0.

| Bloco | Escopo | Situação |
| --- | --- | --- |
| B1 — vida do jogador | Barra com valor numérico, indicação de dano/cura/vida baixa, vida máxima independente e reset | Concluído; testes e inspeção visual aprovados |
| B2 — disciplinas | Ciências e Português, cinco questões por matéria, ofertas variadas e recompensas configuráveis | Concluído; vinte questões para Ensino Médio, sete suítes aprovadas |
| B3 — monstros | Nuvem com ataque à distância e centurião com golpe frontal anunciado; cenas preparadas para sprites | Concluído; oito suítes aprovadas, integração dos encontros em B4 |
| B4 — encontros | Apresentar inimigos gradualmente e misturar comportamentos nas salas | Planejado |
| B5 — validação | Balanceamento, playtest e nova build da versão 0.2 completa | Planejado |

Aceite de B1: barra e texto devem acompanhar dano, cura e mudança da vida máxima; cura não ultrapassa o limite; vida baixa usa aviso textual; reinício restaura vida e limite iniciais sem exibir uma cura falsa. Este bloco não adiciona ainda novas recompensas ou disciplinas.

Entrega B1 (0.1.1):

- Barra fixa com valor atual/máximo; avisos temporários mostram dano e cura efetivos. Abaixo ou igual a 25%, exibe “VIDA BAIXA”; ao morrer, “SEM VIDA”. Cor é um reforço, não a única indicação.
- Vida máxima começa em 100 e pode ser ampliada pela API do jogador. Ampliar o limite não cura automaticamente. Dano/cura negativos são ignorados, cura não ressuscita e reinício restaura 100/100.
- HUD, descrição da cura e tela de vitória passam a respeitar o limite atual. A nova API fica preparada para Ciências, ainda sem recompensa disponível na partida.
- `tests/test_health.gd` cobre sincronização da barra pelo sinal, limiar percentual, alteração do limite, cura limitada, dano letal, pausa dos avisos e reset. As cinco suítes passaram; o encerramento da nova suíte respeita um frame de processamento do áudio antes de liberar a cena.
- Capturas de dano, vida baixa, aumento do limite e cura inspecionadas em 960×540 e 1280×720, sem sobreposição com a arena.
- Executável 0.1.1 exportado e inicialização headless aprovada. Build em `builds/windows/SchoolRush.exe`; pacote em `builds/SchoolRush-MVP-0.1.1-windows-x64.zip`.

Entrega B2 (0.1.2, 21/10/2026):

- Catálogo `data/curriculum.json` com vinte questões autorais de revisão introdutória para Ensino Médio: cinco de Matemática, História, Ciências e Português. As questões anteriores também foram ajustadas ao público. Orientações de edição em [data/README.md](data/README.md); revisão pedagógica ainda pendente.
- Duas matérias diferentes por oferta; prioridade às menos apresentadas. As quatro aparecem nas duas primeiras salas, cada matéria aparece duas vezes na partida e nenhuma das oito questões apresentadas se repete.
- Recompensas configuradas no catálogo: Matemática +2 de dano; História cura 20; Ciências +10 de vida máxima e cura 10; Português +5% da velocidade inicial, limitado a +20%. Na partida atual, Português pode ser escolhido duas vezes, chegando a +10%.
- Acerto reserva o bônus, vitória na sala aplica uma vez e derrota cancela. Limites de cura e velocidade são respeitados; reinício restaura todos os atributos. Pausa e vitória mostram os atributos atualizados.
- Validação do catálogo bloqueia dados inválidos, incluindo alternativas repetidas, referência de matéria desconhecida, índice incorreto e recompensa inválida. O JSON é incluído explicitamente no executável exportado.
- O verificador de exportação preserva o handle do processo antes da espera, garantindo leitura do código de saída também no Windows PowerShell. Uma falha inicial de leitura foi investigada; a execução direta retornou 0 e a checagem foi corrigida.
- Sete suítes aprovadas: catálogo, combate, progressão, partida, movimento, vida e recompensas. Cobertura inclui 50 sequências de ofertas, efeitos dos quatro bônus, aplicação única, cancelamento na derrota, movimento com bônus, limite de velocidade e reset.
- O teste de movimento processa um frame após retomar a pausa antes de liberar a cena. Isso corrige um aviso intermitente de objetos de áudio pendentes; cinco execuções isoladas e a validação completa passaram sem o aviso.
- Capturas de escolha, resposta, feedback, recompensa de Ciências e atributos de Português inspecionadas em 960×540; enunciados e ações legíveis. Build 0.1.2 e pacote `builds/SchoolRush-MVP-0.1.2-windows-x64.zip` preparados; inicialização standalone validada.

Entrega B3 (21/10/2026):

- Cenas reutilizáveis para dado, nuvem, centurião e Napoleão. `Visual/AnimatedSprite2D` separado da colisão; frames vazios mantêm arte provisória. Instruções em [SPRITES.md](SPRITES.md). Não foram encontrados sprites de monstros na pasta.
- Nuvem: 25 de vida, aproximação a 70 px/s, mira fixa anunciada por 0,8 s e recuperação de 1,2 s; projétil a 230 px/s causa 12 de dano. O tiro usa colisão varrida contra parede/jogador, dura até 3,5 s e desaparece ao atingir, ao morrer a nuvem ou ao encerrar o combate.
- Centurião: 45 de vida, aproximação a 85 px/s, aviso de 0,75 s, golpe frontal único de 18 de dano até 105 px, setor de ±0,65 rad e recuperação de 1,1 s. Não causa dano por contato; sair do setor evita o golpe.
- Avisos usam geometria e texto: linha e “DISPARO” para nuvem, setor e “GOLPE” para centurião. Barras de vida permanecem visíveis com sprites.
- Oito suítes aprovadas. A nova suíte verifica mira fixa, esquiva, dano único, colisão varrida e paredes, tempo de vida, pausa, morte/limpeza e troca do visual sem alterar colisão. Capturas dos avisos, golpe e recuperação em `tests/capture_enemies.gd`.
- Avisos e áreas de ataque inspecionados em capturas renderizadas a 960×540 e 1280×720; geometria, texto e barras legíveis.

**Próximo bloco:** B4 — introduzir nuvem na segunda sala e centurião na terceira, misturando comportamentos sem aumentar o número de salas. B5 reúne build candidata, balanceamento inicial e aceite humano da expansão.

Validar se alternar perguntas escolares e combate de ação cria uma partida divertida, compreensível e repetível. A entrega é uma partida completa para PC Windows, com início, progressão, derrota, reinício e vitória. Não basta demonstrar movimentação.

Na análise inicial, o repositório continha apenas movimentação e arena. O estado atualizado e as validações por etapa estão registrados no fim deste documento. O alvo técnico usado é Godot 4.7.2, com formas geométricas provisórias.

Na revisão inicial foram adicionados corrida com Shift, proteção contra registro duplicado dos controles e câmera fixa no centro da arena. A câmera antes seguia o jogador e deixava partes da sala fora da tela. O cache `.godot/` foi excluído do versionamento via `.gitignore`; arquivos `.gd.uid` devem ser mantidos. A exclusão de README já presente no diretório não foi revertida.

## Escopo da base e atualização da expansão

A tabela registra o recorte atual. B2 amplia as disciplinas da base 0.1.0; B3 e B4 serão as próximas ampliações de inimigos e encontros, sem adicionar salas ou sistemas de loja.

| Incluído no MVP | Adiado para depois da validação |
| --- | --- |
| Uma partida com três salas comuns e uma sala de chefe | Múltiplos andares e geração procedural |
| Uma sala de aula reutilizada e ginásio do chefe | Biblioteca, laboratório e pátio |
| Movimento, corrida sem stamina e régua de plástico | Lapiseira, níveis de arma, poderes e inventário |
| Dado flutuante que persegue e ataca por contato | Demais inimigos, NPC vendedor e loja |
| Napoleão com um ataque telegrafado | Múltiplas fases e padrões do chefe |
| Matemática, História, Ciências e Português, cinco questões por matéria | Outras matérias, puzzles e travessias especiais |
| Vida, sala atual, resultado da pergunta e recompensa no HUD | Pontuação competitiva e metaprogressão |
| Início, pausa, derrota, vitória e reinício | Save, narração e configurações avançadas |
| Arte provisória legível e efeitos essenciais | Arte final completa e trilha específica do chefe |

Tempo-alvo de uma partida: 5–8 minutos, a confirmar com jogadores. Público definido: Ensino Médio. Igor deve revisar as vinte questões quanto à correção e adequação antes do aceite pedagógico.

## Regras que removem as ambiguidades do GDD

1. Ao iniciar, oferecer duas perguntas de matérias diferentes, priorizando as menos apresentadas. Mostrar enunciado e recompensa antes da escolha. A pergunta escolhida abre quatro alternativas e admite uma única resposta.
2. Exibir resultado e explicação curta, com botão para continuar. Durante pergunta e feedback, o combate permanece bloqueado.
3. Acerto reserva uma recompensa; ela só é aplicada após eliminar todos os inimigos da sala. Matemática concede +2 de dano da régua; História recupera 20 de vida, limitada ao máximo; Ciências amplia o máximo em 10 e recupera 10; Português soma 5% da velocidade inicial, com limite acumulado de 20%. Exibir os valores na interface.
4. Erro mostra a resposta correta e não reserva bônus. O jogador ainda pode concluir a sala e avançar. Não retirar vida nem repetir a pergunta como punição.
5. A porta permanece fechada durante o combate. Ao limpar a sala, aplicar o bônus uma vez e permitir avançar com E perto da porta. Avançar abre a escolha da próxima sala; não usar transição automática por contato.
6. Repetir o fluxo antes das quatro salas, incluindo o chefe. Uma questão apresentada sai do conjunto da partida mesmo se não for escolhida: quatro salas consomem oito das vinte questões. Reiniciar repõe o banco e todos os atributos.
7. Vida zero encerra imediatamente a partida; não há reinício só da sala. Matar o chefe e permanecer vivo encerra com vitória. Se ambos morrerem no mesmo passo de simulação, derrota tem precedência.
8. Esc pausa apenas durante combate ou sala liberada. Retomar preserva o estado anterior. Telas finais oferecem reiniciar e voltar ao início.

## Parâmetros iniciais de balanceamento

Valores de partida para experimentar, não metas finais.

| Elemento | Valor/regra inicial |
| --- | --- |
| Jogador | 100 de vida; 230 px/s; corrida ×1,4 |
| Régua | 10 de dano; alcance 60 px; intervalo 0,4 s |
| Direção do golpe | Última direção de movimento; direção inicial para baixo |
| Entrada do golpe | Espaço; acertar cada inimigo no máximo uma vez por golpe |
| Dano recebido | Invulnerabilidade de 0,7 s após dano, com feedback visual |
| Dado | 30 de vida; 10 de dano; 100 px/s; intervalo de contato 1 s |
| Salas comuns | 2, 3 e 4 dados; posições fixas, a pelo menos 160 px da entrada |
| Napoleão | 150 de vida; investida de 20 de dano |
| Ciclo do chefe | Mira fixa com aviso de 0,8 s, investida de até 0,5 s a 420 px/s, recuperação de 1,2 s |

A investida termina ao atingir parede; não reposiciona a mira durante o aviso. Sem invocações ou projéteis. Na sala liberada e nas interfaces não ocorre dano. Ataque tem área frontal, para que posicionamento seja relevante. Validar a duração e ajustar vida/quantidade de inimigos antes de adicionar conteúdo.

## Organização técnica proposta

Manter Godot 4.7.x e renderizador Compatibility do projeto. Não instalar plugins para este escopo. Antes da entrega, registrar a versão exata usada pela equipe.

| Componente a implementar | Responsabilidade |
| --- | --- |
| `RunManager` | Estado da partida, sala atual, transições, vitória/derrota e reinício |
| `Player` | Entrada, movimento, ataque, vida e invulnerabilidade |
| `Enemy` e `Boss` | Movimento, ataque, vida e sinal de morte emitido uma vez |
| `Room` | Paredes, pontos de spawn, inimigos vivos e porta |
| `QuestionManager` | Seleção sem repetição, validação da resposta e bônus pendente |
| `HUD` e painéis `Control` | Apresentação e sinais de escolha; sem aplicar dano ou recompensa |
| Banco JSON ou Resources | ID, matéria, enunciado, quatro alternativas, índice correto e explicação |

Estados explícitos: INÍCIO → PERGUNTA → FEEDBACK → COMBATE → SALA_LIBERADA → PERGUNTA; COMBATE também pode levar a DERROTA ou VITÓRIA. Pausa guarda o estado anterior. Um único controlador confirma a transição e consome o bônus pendente, evitando recompensa duplicada por sinais de morte simultâneos.

Separar colisões: jogador, cenário, inimigos e áreas de ataque. Evitar dano contínuo por frame. Preferir sinais (`died`, `health_changed`, `room_cleared`) a buscas globais por nós. Migrar a arena montada por código para uma cena reutilizável quando implementar portas e spawns; não antecipar uma arquitetura procedural.

## Execução por marcos

Estimativa: seis semanas de trabalho parcial da equipe. Como a disponibilidade não foi informada, são janelas de planejamento, não datas prometidas. Só avançar de marco com o aceite cumprido; arte pode ocorrer em paralelo sem bloquear o combate.

| Marco | Janela | Trabalho e responsável | Critério de aceite |
| --- | --- | --- | --- |
| M0 — escopo e movimento | Semana 1 | Igor define faixa escolar e revisa regras; Moisés consolida controles e arena | Andar/correr em oito direções, colisão íntegra e arena inteira visível; escopo registrado |
| M1 — combate mínimo | Semana 2 | Moisés implementa régua, vida, invulnerabilidade, dado e derrota; Matheus produz feedback provisório | É possível matar dois dados, receber dano, morrer e reiniciar sem duplicar nós ou controles |
| M2 — ciclo educacional | Semana 3 | Igor entrega dez perguntas revisadas; Moisés implementa seleção, resposta, feedback e bônus | Acerto só premia após combate; erro permite avançar; não há questões repetidas nem múltiplas respostas |
| M3 — partida comum | Semana 4 | Moisés cria cena de sala, porta e sequência; Eduardo cria cenário e silhuetas legíveis | Três salas encadeadas preservam vida/atributos; porta bloqueia avanço prematuro |
| M4 — conclusão | Semana 5 | Moisés implementa chefe, início, pausa e telas finais; Matheus anima aviso de ataque; Eduardo prepara ginásio | Partida completa até vitória ou derrota; chefe comunica ataque antes do dano; reinício limpa todo o estado |
| M5 — entrega | Semana 6 | Todos testam; Igor balanceia; Moisés exporta; arte/áudio essenciais entram sem expandir escopo | Build Windows executa sem editor, controles documentados e todos os casos críticos abaixo aprovados |

Caminho crítico da base: movimento → combate → perguntas/recompensas → salas → chefe/finais → exportação. Na expansão, seguir B3 → B4 → B5, mantendo aberto o playtest da versão atual. Não começar pela loja ou arte definitiva.

## Verificação e definição de pronto

Por marco, executar importação headless e abertura da cena no editor. Headless detecta erros de scripts/recursos, mas não comprova sensação de combate, visibilidade ou usabilidade.

Checklist manual obrigatório da entrega:

- WASD/setas e Shift funcionam; diagonal não é mais rápida; paredes seguram o jogador mesmo correndo.
- Um golpe não causa múltiplos danos no mesmo inimigo; contato respeita invulnerabilidade; inimigos mortos param de atacar.
- Todas as questões têm quatro alternativas, índice correto válido e explicação revisada; escolher/responder repetidamente não duplica eventos.
- Acerto aplica um bônus após a sala; erro aplica zero; cura não excede o máximo atual; morte antes de limpar cancela bônus. Ciências amplia o limite e Português respeita o teto de velocidade.
- A porta só abre sem inimigos; interagir repetidamente não pula salas; chefe só aparece na quarta sala.
- Pausar interrompe movimento, dano e temporizadores; retomar não deixa o jogo congelado.
- Vitória/derrota bloqueiam combate; reiniciar três vezes não mantém bônus, perguntas consumidas ou inimigos anteriores.
- Redimensionar a janela preserva HUD e alternativas; texto é legível; feedback de acerto/erro usa texto além de cor.
- Build Windows abre numa máquina sem Godot e completa uma partida sem erro bloqueante.

Automatizar, quando esses sistemas existirem, os testes de consumo único de recompensa, seleção sem repetição e reset de partida. Evitar testes que apenas reproduzam os valores escritos no código.

Playtest: cinco pessoas externas à equipe, duas partidas cada. Registrar tempo, salas alcançadas, mortes, acertos e dúvidas em uma planilha simples, sem telemetria obrigatória. Meta: pelo menos quatro entendem a relação pergunta → combate → bônus sem explicação verbal. Investigar derrotas recorrentes antes da segunda sala e ataques do chefe percebidos como inevitáveis. Não exigir que todos vençam na primeira tentativa.

## Riscos e decisões de corte

- Escopo: seis inimigos, quatro cenários, duas armas e loja comprometem a entrega. Manter apenas o conjunto incluído neste documento.
- Conteúdo: cinco questões por matéria sustentam quatro salas, mas têm pouca rejogabilidade. Expandir o banco só após validar o ciclo; revisar correção e dificuldade antes de testar com público.
- Integração: arte pode atrasar programação. Usar formas provisórias até o ciclo completo funcionar; substituir sem alterar colisões sem revisão.
- Balanceamento: dano cumulativo pode simplificar o chefe. Medir partidas com zero e quatro acertos; ajustar bônus e chefe juntos.
- Prazo: se atrasar, reduzir as salas comuns de três para duas e simplificar arte/áudio. Preservar perguntas, combate, recompensa, chefe e telas finais.

## Estado desta revisão

### M1 — implementado e validado tecnicamente em 19/10/2026

- Régua frontal (Espaço), cooldown, vida, invulnerabilidade e feedback visual.
- Dois dados perseguem o jogador e causam dano por contato; morte e reinício completos.
- Cena reutilizável de sala, menu inicial, HUD e tela de conclusão provisória.
- Corrida reintegrada: na retomada, o arquivo local do jogador estava novamente sem a implementação de Shift.
- `tests/test_combat.gd`: cone frontal, cooldown, invulnerabilidade, derrota e três reinícios, sem falhas.
- Importação headless aprovada em Godot 4.7.2. Teste manual de sensação do combate segue pendente; M1 tem aceite técnico, não aceite final de playtest.

### M2 e M3 — implementados e validados tecnicamente em 19/10/2026

- Banco provisório de dez questões, duas ofertas por sala, quatro alternativas, feedback e explicação. Revisão pedagógica e definição da faixa escolar ainda pendentes.
- Questões apresentadas não se repetem; acerto reserva bônus, erro permite seguir. Bônus consumido apenas após limpar a sala e cancelado na derrota.
- Três salas encadeadas com 2/3/4 dados, porta bloqueada durante combate e avanço com E somente perto da saída. Vida e dano persistem entre salas.
- `tests/test_progression.gd`: validade do banco, oito questões únicas em quatro ofertas, resposta única, recompensa única, cura limitada, erro sem bônus, portas, interação repetida e reset.
- Testes de combate e progressão aprovados sem falhas; importação aprovada. A arena permanece com arte provisória.

### M4 — implementado e validado tecnicamente em 19/10/2026

- Napoleão exclusivo da quarta sala, ginásio provisório, aviso de direção fixa, investida e recuperação. Pergunta antes do chefe com explicação do padrão.
- Vitória, derrota, nova partida, retorno ao início e pausa com Esc. Pausa preserva movimento, invulnerabilidade e temporizadores.
- Resolução da sala adiada até o fim do frame, priorizando derrota em morte simultânea. Pausa no último golpe não perde a conclusão da sala.
- `tests/test_run.gd`: quatro salas até vitória, fases do chefe, direção fixa, pausa, retomada, morte simultânea e reinício da pausa; todas as três suítes aprovadas.
- Capturas renderizadas no Godot em 960×540 e 1280×720: menu, perguntas, feedback, combate e chefe inspecionados; texto legível e arena inteira visível. Capturas locais em `builds/previews/`, fora do Git.
- Partida funcional de ponta a ponta disponível. Balanceamento e sensação de controle ainda precisam de playtest humano.

### M5 — entrega técnica preparada em 19/10/2026; aceite humano pendente

- Efeitos sonoros sintetizados para ataque, dano, resposta e conclusão; tecla M alterna o som. Arte continua provisória.
- Proporção 16:9 preservada no redimensionamento; menu, respostas, feedback, sala liberada, pausa e vitória inspecionados em capturas renderizadas.
- Quatro suítes aprovadas, sem erros nem avisos de objetos pendentes: combate, progressão, partida e movimento. A última verifica corrida, diagonal, paredes e congelamento da invulnerabilidade na pausa.
- A thread de áudio recebe tempo para liberar playbacks na limpeza dos testes; canais são parados ao sair da cena.
- Templates oficiais 4.7.2 baixados e componentes Windows x64 instalados. Preset de exportação versionado; recursos embutidos em `builds/windows/SchoolRush.exe`.
- Executável exportado iniciado e encerrado após 120 frames, tanto headless quanto com renderização OpenGL, sem erros. Isso comprova inicialização local, não uma partida manual em outro computador.
- `tools/check.ps1` reproduz importação e testes. Com `-Export`, também gera o executável, avisos do Godot, guia de uso e verifica inicialização standalone com limite de tempo.
- Um teste externo via `--script` não foi executado pelo template release; o processo foi encerrado. Os testes de lógica foram executados pelo editor headless; a build release passou pelos testes de inicialização descritos acima.
- Guia `COMO_JOGAR.md` e pacote local `builds/SchoolRush-MVP-0.1.0-windows-x64.zip` preparados para a equipe. Binários e capturas ficam fora do Git.

### Pendências para aprovar o MVP

| Pendência | Responsável | Evidência esperada |
| --- | --- | --- |
| Revisar as vinte questões para Ensino Médio | Igor | Questões corretas e adequadas ao público confirmado |
| Executar cinco playtests de duas partidas | Equipe | Tempo, mortes, acertos e dúvidas; quatro pessoas entendem o ciclo sem orientação |
| Ajustar combate, duração e dificuldade a partir dos testes | Moisés + Igor | Partida compreensível e alvo de 5–8 minutos avaliado |
| Validar áudio e sensação dos controles | Matheus + equipe | Feedback perceptível e volume confortável |
| Testar a pasta exportada em outro PC sem Godot | Equipe | Uma partida até vitória e outra até derrota, com reinício funcional |

Não declarar o MVP finalizado antes desses aceites. A exclusão local preexistente de `README.md` foi mantida fora dos commits.

### Histórico de versionamento

Trabalho na branch existente `master`, com pushes para `origin/master` após cada etapa validada:

- `c26ebc9`: plano e base inicial.
- `c2a2a84`: M1 — combate, inimigos, vida e reinício.
- `43fa130`: M2/M3 — perguntas, bônus e três salas.
- `8e9fdea`: M4 — Napoleão, pausa e partida completa.
- `9e6a086`: M5 — áudio, exportação, verificações e plano atualizado.
- `aed10a2`: B1 — barra de vida, limite máximo e versão 0.1.1.
- B2: disciplinas de Ensino Médio, catálogo, recompensas e versão 0.1.2 (consultar `git log` para o hash desta entrega).
