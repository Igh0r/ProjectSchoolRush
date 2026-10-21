# School Rush — validação da versão 0.2.0-rc1

Preparado em 21/10/2026. **Ainda não preenchido:** este documento é um roteiro, não um relatório de testes humanos concluídos. Público: Ensino Médio. Build Windows x64; não precisa do editor Godot.

## Sessão com jogadores

Convidar cinco pessoas externas à equipe para duas partidas cada. Usar identificadores P1–P5 e registrar a versão da build e o PC utilizado. Na primeira partida, deixar a pessoa ler o menu e tentar entender o jogo sem explicação verbal; anotar se precisou de ajuda. Na segunda, observar se reconhece melhor os avisos e consegue usar as recompensas.

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
- [ ] Esc congela avisos e tiros; retomar, reiniciar e voltar ao menu funcionam.
- [ ] Limpar a sala remove tiros; a porta só permite avançar sem inimigos vivos.
- [ ] Vitória e derrota bloqueiam ataques; três reinícios não mantêm atributos ou inimigos antigos.
- [ ] Textos longos, alternativas e botões são acessíveis em 960×540 e após redimensionar.
- [ ] M alterna o som; volume e efeitos são confortáveis.
- [ ] Em outro PC sem Godot, extrair o ZIP e completar uma vitória, uma derrota e um reinício.

## Revisão pedagógica

Igor deve revisar enunciado, quatro alternativas, resposta e explicação de cada questão em `data/curriculum.json` no projeto-fonte. Marcar somente depois de confirmar correção e adequação ao Ensino Médio; registrar qualquer ajuste por ID.

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

Mantivemos no máximo uma nuvem e um centurião por sala. A nuvem avisa por 0,8 s e se recupera por 1,2 s; o centurião avisa por 0,75 s e se recupera por 1,1 s após o golpe. A primeira sala e Napoleão preservam os parâmetros anteriores. Não aumentar inimigos antes de observar os jogadores.

Se a maioria não perceber um aviso, ajustar primeiro sua legibilidade. Se reconhecer o aviso, mas não conseguir escapar, revisar duração e alcance. Se o combate ficar longo mesmo com esquivas e ataques consistentes, revisar vida e tempo de recuperação. Alterar um parâmetro por vez, registrar o motivo e repetir o teste afetado.

## Aceite da versão final

- Pelo menos quatro das cinco pessoas entendem pergunta → combate → bônus sem explicação verbal.
- Nenhum erro bloqueante de progressão, pausa, derrota, reinício ou execução standalone.
- Revisão pedagógica aprovada e avisos de ataque compreendidos; investigar relatos recorrentes de dano inevitável.
- Duração de partidas concluídas avaliada contra o alvo de 5–8 minutos; registrar decisão caso o alvo seja revisto.
- Sensação dos controles/áudio e execução em outro PC aprovadas pela equipe.

Registrar responsáveis, resultados e correções no `PLANO_MVP.md` antes de promover a candidata para 0.2.0 final.
