# School Rush — playtest aprovado e acompanhamento da fase 0.3

Atualizado em 23/10/2026. **Playtest interno da base anterior aprovado pelo usuário e Igor.** Público: Ensino Médio. Nova candidata para avaliação: **0.3.0-rc2**, Windows x64, sem necessidade do editor Godot. Os campos em branco abaixo são o roteiro para a próxima rodada, não reprovações da base.

**D1–D4 e E1 implementados:** oitenta questões, histórico na sessão, preferências de tema/dificuldade e alternativas embaralhadas; separação e reposicionamento dos inimigos, dois leques do cacto, coordenação dos ataques, varredura do chefe e resumo/revisão de partida com relatório local opcional. Quinze suítes aprovadas e capturas de textos/avisos conferidas. Não houve novo playtest humano dessa fase nesta entrega.

## Resultado informado em 23/10/2026

- Participantes: usuário e Igor. Resultado relatado: o playtest passou e o jogo está bom.
- Melhorias solicitadas: mais variedade de perguntas e melhor combate dos inimigos.
- Decisão: base aceita para evolução; próximos blocos D1–D5 registrados em [PLANO_MVP.md](PLANO_MVP.md).
- Registro qualitativo: não foram fornecidos versão exata testada, tempos, quantidade de partidas ou resultados individuais do checklist. Revisão pedagógica por questão e teste em outro PC não foram confirmados separadamente.

## Próxima rodada — variedade e combate

Comparar a base aprovada com a candidata resultante da fase D. Usuário e Igor avaliam se as perguntas variam entre partidas e se os ataques permitem decisões claras de esquiva e contra-ataque. Registrar versão, rota e observações concretas antes de ajustar parâmetros.

| Foco | O que observar | Registro |
| --- | --- | --- |
| Variedade | Temas e formas de raciocínio diferentes; repetição após reiniciar na mesma sessão | IDs vistos/repetidos e número de partidas |
| Clareza das questões | Enunciados, alternativas e explicações corretos e legíveis | ID, dúvida e correção necessária |
| Movimento inimigo | Amontoamento, inimigos presos e perseguição/fuga excessiva | Rota, sala e inimigos envolvidos |
| Ataques | Aviso percebido, possibilidade de escapar e janela de contra-ataque | Padrão e situação em que houve dificuldade |
| Encontros e chefe | Sobreposição de perigos, espaço de fuga e distinção dos dois padrões previstos | Sala, posição e combinação de ataques |
| Balanceamento | Duração e dificuldade com e sem recompensas | Tempo, acertos, sala final e causa da derrota |

Os comportamentos D1–D4 estão disponíveis na candidata. Jogar duas partidas seguidas sem fechar o jogo para avaliar variedade; repetir as rotas e registrar em qual sala/padrão ocorreram ataques difíceis de evitar. Como houve mudança no combate, registrar o retorno desta rodada separadamente do aceite anterior.

## Sessão complementar com jogadores

Como ampliação opcional, convidar cinco pessoas externas à equipe para duas partidas cada: primeira na rota clássica, segunda na expedição científica. Essa amostra não é condição para iniciar a fase D. Usar identificadores P1–P5 e registrar a versão da build e o PC utilizado. Na primeira partida, deixar a pessoa ler o menu e tentar entender o jogo sem explicação verbal; anotar se precisou de ajuda. Na segunda, observar uso das recompensas e compreensão dos novos avisos. As rotas têm inimigos diferentes; não comparar diretamente seus tempos como medida de aprendizado.

Usar o tempo exibido no resumo, contado do início da primeira escolha até vitória ou derrota, incluindo leitura/feedback e excluindo pausas. Menu e revisão final não contam. Registrar a duração mesmo em derrotas. Não interpretar a média de partidas encerradas cedo como duração de uma partida completa; o alvo de 5–8 minutos ainda precisa ser avaliado nas partidas concluídas.

Antes de reiniciar, usar **Rever respostas** para anotar IDs confusos e, se desejado, **Salvar resumo neste computador**. O caminho aparece na tela; os arquivos ficam na pasta `reports` dos dados locais do jogo (detalhes em `COMO_JOGAR.md`). Associar manualmente cada arquivo a P1/P2 etc. na ficha; o jogo não registra nome, causa da morte nem percepção dos avisos. Esses itens dependem da observação da equipe. O JSON contém apenas as questões respondidas; para estudar repetição das ofertas não escolhidas, anotar também seus IDs durante a sessão.

| Pessoa | Partida | Tempo | Sala final / resultado | Acertos / respondidas | Causa da morte | Entendeu o bônus sem ajuda? | Dúvidas e avisos não percebidos |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | 1 | | | | | | |
| P1 | 2 | | | | | | |
| P2 | 1 | | | | | | |
| P2 | 2 | | | | | | |
| P3 | 1 | | | | | | |
| P3 | 2 | | | | | | |
| P4 | 1 | | | | | | |
| P4 | 2 | | | | | | |
| P5 | 1 | | | | | | |
| P5 | 2 | | | | | | |

Ao terminar, perguntar: quando você recebe o bônus? Como evitou o tiro da nuvem? Como evitou o golpe do centurião? Houve alguma pergunta confusa ou ataque que pareceu impossível de evitar? Os textos, avisos e sons ficaram claros?

## Verificações manuais da equipe

- [ ] Movimento, diagonal, corrida, régua e paredes respondem bem no teclado.
- [ ] A barra acompanha dano, cura e aumento da vida máxima; vida baixa fica clara.
- [ ] As quatro matérias aparecem; escolher/responder rapidamente não duplica ações.
- [ ] Reiniciar e voltar ao menu preservam prioridade de perguntas inéditas; fechar o jogo inicia novo histórico.
- [ ] Alternativas mudam de posição e o feedback continua indicando a resposta correta.
- [ ] Dados se separam, nuvem/cientista reposicionam entre ataques e continuam alcançáveis.
- [ ] ABERTO comunica a oportunidade de contra-ataque do centurião e do chefe.
- [ ] Os leques estreitos/largos do cacto correspondem às linhas de aviso.
- [ ] Na sala mista, observar sobreposição de perigos e saída possível perto das paredes.
- [ ] INVESTIDA e VARREDURA são distinguíveis; sair do setor fixo evita o golpe do chefe.
- [ ] Acerto só premia após o combate; erro permite seguir; morte cancela o bônus.
- [ ] DISPARO anuncia direção fixa; o tiro permite esquiva e para nas paredes.
- [ ] GOLPE anuncia o setor antes do dano; sair do setor evita o golpe; a recuperação permite contra-atacar.
- [ ] Sala 3 permite distinguir dados, nuvem, centurião e projéteis sem sobreposição confusa.
- [ ] Os seis monstros são reconhecíveis; sprites não cobrem avisos nem barras de vida nos quatro pisos.
- [ ] Os dois botões do menu iniciam a rota correspondente; reinício mantém a escolha e voltar ao menu permite trocar.
- [ ] No pátio, as três linhas de ESPINHOS permitem prever e evitar o disparo.
- [ ] No laboratório, o círculo de MISTURA permanece fixo; sair dele antes da ativação evita dano.
- [ ] A mistura ativa expira, respeita invulnerabilidade e não causa vários acertos na mesma área.
- [ ] Pausa congela animações, misturas e espinhos; matar a fonte ou encerrar combate remove seus perigos.
- [ ] Esc congela avisos e tiros; retomar, reiniciar e voltar ao menu funcionam.
- [ ] Limpar a sala remove tiros; a porta só permite avançar sem inimigos vivos.
- [ ] Vitória e derrota bloqueiam ataques; três reinícios não mantêm atributos ou inimigos antigos.
- [ ] Resumo mostra rota, acertos/respondidas, salas concluídas e tempo sem pausas em vitória e derrota.
- [ ] Revisão preserva a resposta escolhida, gabarito, explicação e estado do bônus; navegar não modifica atributos.
- [ ] Salvar mostra um arquivo legível; Abrir pasta dos resumos permite encontrá-lo; segundo clique em salvar reutiliza o mesmo relatório; reinício inicia outro registro.
- [ ] Textos longos, alternativas e botões são acessíveis em 960×540 e após redimensionar.
- [ ] M alterna os efeitos sonoros; música, volume e efeitos são confortáveis.
- [ ] Em outro PC sem Godot, extrair o ZIP e completar uma vitória, uma derrota e um reinício.

## Revisão pedagógica

Igor deve revisar enunciado, quatro alternativas, resposta e explicação de cada questão em `data/curriculum.json` no projeto-fonte. Marcar somente depois de confirmar correção e adequação ao Ensino Médio; registrar qualquer ajuste por ID.

O aceite geral do playtest não foi registrado como revisão individual das questões. O banco D1 possui oitenta questões; a ficha completa está em [data/REVISAO_PEDAGOGICA.md](data/REVISAO_PEDAGOGICA.md), com tema, dificuldade, gabarito, revisor/data e resultado por ID. Os grupos abaixo são resumos para preenchimento somente após revisar todos os IDs correspondentes.

- [ ] Matemática: mat1–mat20.
- [ ] História: his1–his20.
- [ ] Ciências: cie1–cie20.
- [ ] Português: por1–por20.

## Parâmetros iniciais e decisões após o teste

| Encontro | Vida total dos inimigos | Golpes mínimos da régua sem bônus, supondo um alvo por golpe |
| --- | --- | --- |
| Sala 1: dois dados | 60 | 6 |
| Sala 2: dois dados e nuvem | 85 | 9 |
| Sala 3: dois dados, nuvem e centurião | 130 | 14 |
| Chefe: Napoleão | 150 | 15 |
| Total | 425 | 44 |

A base tinha 420 de vida total e exigia 42 golpes nas mesmas condições. O aumento é pequeno, mas novos padrões podem elevar muito a dificuldade; esses números não medem a duração real. A régua pode acertar mais de um inimigo no mesmo golpe. Os bônus de Matemática também reduzem a quantidade de golpes.

Na expedição científica, os totais por sala são 60, 90, 135 e 150 de vida: **435 no total**, com **46 golpes** nas mesmas condições. O cacto tem 35 de vida e dispara três espinhos de 8 de dano após 0,95 s; o cientista tem 35 de vida e marca uma mistura de raio 42, com aviso de 1 s, duração ativa de 1,2 s e no máximo um acerto de 10. A posição da mistura fica limitada à arena. Avaliar separadamente a pressão desses ataques na segunda rota.

Mantivemos no máximo uma nuvem e um centurião por sala; a rota científica acrescenta cacto no pátio e cientista no laboratório, substituindo outros inimigos. Nuvem avisa por 0,8 s e recupera por 1,2 s; centurião avisa por 0,75 s e recupera por 1,1 s. O novo coordenador limita a dois ataques especiais/fonte em andamento, contando tiros/áreas ainda ativos. Um leque de três espinhos ocupa uma vaga. Dados não usam vagas de ataques especiais.

Napoleão mantém 150 de vida e investida de 20 de dano. A nova varredura também causa 20, uma única vez, em um setor de 125 px e ±0,9 rad após aviso fixo de 0,9 s; efeito de 0,2 s e recuperação de 1,2 s. A aproximação antes da varredura dura até 1,6 s a 100 px/s. Se o jogador estiver distante, o chefe anuncia outra investida. Comparar a pressão desses comportamentos com a base aprovada, mantendo as quantidades e a vida dos inimigos como referência.

Se a maioria não perceber um aviso, ajustar primeiro sua legibilidade. Se reconhecer o aviso, mas não conseguir escapar, revisar duração e alcance. Se o combate ficar longo mesmo com esquivas e ataques consistentes, revisar vida e tempo de recuperação. Alterar um parâmetro por vez, registrar o motivo e repetir o teste afetado.

## Critérios para a próxima entrega

- Usuário e Igor percebem mais variedade entre partidas e avaliam como compreensíveis os movimentos e padrões de ataque novos; registrar problemas e correções.
- Caso a rodada externa seja realizada, observar a meta de quatro entre cinco pessoas entenderem pergunta → combate → bônus sem explicação verbal.
- Nenhum erro bloqueante de progressão, pausa, derrota, reinício ou execução standalone.
- Revisão pedagógica aprovada e avisos de ataque compreendidos; investigar relatos recorrentes de dano inevitável.
- Duração de partidas concluídas avaliada contra o alvo de 5–8 minutos; registrar decisão caso o alvo seja revisto.
- Sensação dos controles/áudio e execução em outro PC aprovadas pela equipe.

Registrar responsáveis, resultados e correções no `PLANO_MVP.md`. A base anterior já recebeu aceite interno; D5 permanece aberto para avaliação humana da 0.3.0-rc2, revisão pedagógica e execução em outro PC. A candidata não foi promovida automaticamente a versão final.
