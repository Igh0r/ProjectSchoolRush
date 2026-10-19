# School Rush — análise e plano de execução do MVP

Data: 19/10/2026. Proposta de escopo para a equipe, sujeita a playtest.

## Objetivo e situação atual

Validar se alternar perguntas escolares e combate de ação cria uma partida divertida, compreensível e repetível. A entrega é uma partida completa para PC Windows, com início, progressão, derrota, reinício e vitória. Não basta demonstrar movimentação.

Na análise inicial, o repositório continha apenas movimentação e arena. O estado atualizado e as validações por etapa estão registrados no fim deste documento. O alvo técnico usado é Godot 4.7.2, com formas geométricas provisórias.

Na revisão inicial foram adicionados corrida com Shift, proteção contra registro duplicado dos controles e câmera fixa no centro da arena. A câmera antes seguia o jogador e deixava partes da sala fora da tela. O cache `.godot/` foi excluído do versionamento via `.gitignore`; arquivos `.gd.uid` devem ser mantidos. A exclusão de README já presente no diretório não foi revertida.

## Escopo fechado para a primeira entrega

| Incluído no MVP | Adiado para depois da validação |
| --- | --- |
| Uma partida com três salas comuns e uma sala de chefe | Múltiplos andares e geração procedural |
| Uma sala de aula reutilizada e ginásio do chefe | Biblioteca, laboratório e pátio |
| Movimento, corrida sem stamina e régua de plástico | Lapiseira, níveis de arma, poderes e inventário |
| Dado flutuante que persegue e ataca por contato | Demais inimigos, NPC vendedor e loja |
| Napoleão com um ataque telegrafado | Múltiplas fases e padrões do chefe |
| Matemática e História, cinco questões por matéria | Mais matérias, puzzles e travessias especiais |
| Vida, sala atual, resultado da pergunta e recompensa no HUD | Pontuação competitiva e metaprogressão |
| Início, pausa, derrota, vitória e reinício | Save, narração e configurações avançadas |
| Arte provisória legível e efeitos essenciais | Arte final completa e trilha específica do chefe |

Tempo-alvo de uma partida: 5–8 minutos, a confirmar com jogadores. Perguntas e conteúdo visual devem ser adequados ao público definido pela equipe; Igor deve registrar a faixa escolar antes de produzir o banco definitivo.

## Regras que removem as ambiguidades do GDD

1. Ao iniciar, oferecer duas perguntas, uma de cada matéria. Mostrar enunciado e recompensa antes da escolha. A pergunta escolhida abre quatro alternativas e admite uma única resposta.
2. Exibir resultado e explicação curta, com botão para continuar. Durante pergunta e feedback, o combate permanece bloqueado.
3. Acerto reserva uma recompensa; ela só é aplicada após eliminar todos os inimigos da sala. Matemática concede +2 de dano da régua; História recupera 20 de vida, limitada ao máximo. Exibir os valores na interface.
4. Erro mostra a resposta correta e não reserva bônus. O jogador ainda pode concluir a sala e avançar. Não retirar vida nem repetir a pergunta como punição.
5. A porta permanece fechada durante o combate. Ao limpar a sala, aplicar o bônus uma vez e permitir avançar com E perto da porta. Avançar abre a escolha da próxima sala; não usar transição automática por contato.
6. Repetir o fluxo antes das quatro salas, incluindo o chefe. Uma questão apresentada sai do conjunto da partida mesmo se não for escolhida: quatro salas consomem oito das dez questões. Reiniciar repõe o banco e todos os atributos.
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

Caminho crítico: movimento → combate → perguntas/recompensas → salas → chefe/finais → exportação. Próxima tarefa de implementação: M5, preparação de exportação, áudio essencial e verificação final. Não começar pela loja ou arte definitiva.

## Verificação e definição de pronto

Por marco, executar importação headless e abertura da cena no editor. Headless detecta erros de scripts/recursos, mas não comprova sensação de combate, visibilidade ou usabilidade.

Checklist manual obrigatório da entrega:

- WASD/setas e Shift funcionam; diagonal não é mais rápida; paredes seguram o jogador mesmo correndo.
- Um golpe não causa múltiplos danos no mesmo inimigo; contato respeita invulnerabilidade; inimigos mortos param de atacar.
- Todas as questões têm quatro alternativas, índice correto válido e explicação revisada; escolher/responder repetidamente não duplica eventos.
- Acerto aplica um bônus após a sala; erro aplica zero; cura não excede 100; morte antes de limpar cancela bônus.
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

M5 em andamento. Os templates de exportação não foram encontrados na pasta padrão local; a build Windows ainda não foi gerada. A exclusão local preexistente de `README.md` foi mantida fora dos commits. Versionamento: plano/base em `c26ebc9`, M1 em `c2a2a84`, M2/M3 em `43fa130`, enviados a `origin/master`; cada próxima etapa terá commit após validação, seguido de push.

Validação técnica: importação pelo editor headless e execução da cena por 120 frames no Godot 4.7.2. A validação visual e a experiência dos controles ainda exigem teste manual.
