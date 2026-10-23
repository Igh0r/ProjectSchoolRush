# School Rush — validação da versão 0.2.0-rc2

Atualizado em 23/10/2026. **Playtest interno aprovado pelo usuário e Igor.** Público: Ensino Médio. Build de referência disponível: 0.2.0-rc2, Windows x64, sem necessidade do editor Godot. Os campos em branco abaixo são o roteiro para a próxima rodada, não reprovações da base.

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

Os comportamentos da fase D ainda são planejados. Preencher os itens correspondentes quando estiverem disponíveis; manter abaixo o roteiro de regressão da base.

## Sessão complementar com jogadores

Como ampliação opcional, convidar cinco pessoas externas à equipe para duas partidas cada: primeira na rota clássica, segunda na expedição científica. Essa amostra não é condição para iniciar a fase D. Usar identificadores P1–P5 e registrar a versão da build e o PC utilizado. Na primeira partida, deixar a pessoa ler o menu e tentar entender o jogo sem explicação verbal; anotar se precisou de ajuda. Na segunda, observar uso das recompensas e compreensão dos novos avisos. As rotas têm inimigos diferentes; não comparar diretamente seus tempos como medida de aprendizado.

Cronometrar do início da primeira escolha até vitória ou derrota. Registrar a duração mesmo em derrotas. Não interpretar a média de partidas encerradas cedo como duração de uma partida completa; o alvo de 5–8 minutos ainda precisa ser avaliado nas partidas concluídas.

| Pessoa | Partida | Tempo | Sala final / resultado | Acertos / 4 | Causa da morte | Entendeu o bônus sem ajuda? | Dúvidas e avisos não percebidos |
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
- [ ] Textos longos, alternativas e botões são acessíveis em 960×540 e após redimensionar.
- [ ] M alterna os efeitos sonoros; música, volume e efeitos são confortáveis.
- [ ] Em outro PC sem Godot, extrair o ZIP e completar uma vitória, uma derrota e um reinício.

## Revisão pedagógica

Igor deve revisar enunciado, quatro alternativas, resposta e explicação de cada questão em `data/curriculum.json` no projeto-fonte. Marcar somente depois de confirmar correção e adequação ao Ensino Médio; registrar qualquer ajuste por ID.

O aceite geral do playtest não foi registrado como revisão individual das questões. Os IDs abaixo representam o banco atual de vinte questões. Em D1, ampliar o registro para cada lote novo, incluindo tema, dificuldade, revisor e resultado; meta planejada de oitenta questões, vinte por disciplina.

- [ ] Matemática: mat1, mat2, mat3, mat4, mat5.
- [ ] História: his1, his2, his3, his4, his5.
- [ ] Ciências: cie1, cie2, cie3, cie4, cie5.
- [ ] Português: por1, por2, por3, por4, por5.

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

Mantivemos no máximo uma nuvem e um centurião por sala; a nova rota acrescenta um cacto no pátio e um cientista no laboratório, substituindo outros inimigos. A nuvem avisa por 0,8 s e se recupera por 1,2 s; o centurião avisa por 0,75 s e se recupera por 1,1 s após o golpe. A primeira sala e Napoleão preservam os parâmetros anteriores. Não aumentar a quantidade simultânea antes de observar os jogadores.

Se a maioria não perceber um aviso, ajustar primeiro sua legibilidade. Se reconhecer o aviso, mas não conseguir escapar, revisar duração e alcance. Se o combate ficar longo mesmo com esquivas e ataques consistentes, revisar vida e tempo de recuperação. Alterar um parâmetro por vez, registrar o motivo e repetir o teste afetado.

## Critérios para a próxima entrega

- Usuário e Igor percebem mais variedade entre partidas e avaliam como compreensíveis os movimentos e padrões de ataque novos; registrar problemas e correções.
- Caso a rodada externa seja realizada, observar a meta de quatro entre cinco pessoas entenderem pergunta → combate → bônus sem explicação verbal.
- Nenhum erro bloqueante de progressão, pausa, derrota, reinício ou execução standalone.
- Revisão pedagógica aprovada e avisos de ataque compreendidos; investigar relatos recorrentes de dano inevitável.
- Duração de partidas concluídas avaliada contra o alvo de 5–8 minutos; registrar decisão caso o alvo seja revisto.
- Sensação dos controles/áudio e execução em outro PC aprovadas pela equipe.

Registrar responsáveis, resultados e correções no `PLANO_MVP.md`. A base já recebeu aceite interno para evolução; estes critérios orientam a próxima entrega. A fase D prevê 0.3.0-rc1, sem promoção automática da build atual para versão final.
