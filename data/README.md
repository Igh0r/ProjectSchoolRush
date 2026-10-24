# Catálogo educacional

`curriculum.json` é a fonte de disciplinas, recompensas e questões. O público é Ensino Médio. O bloco D1 amplia o banco para **oitenta questões autorais, vinte por matéria**, preservando os vinte IDs anteriores. Cada matéria tem oito questões básicas, oito intermediárias e quatro desafios. O conteúdo e essa classificação ainda precisam de revisão pedagógica da equipe; não há alinhamento certificado a uma série ou currículo específico. Acompanhe cada ID em [REVISAO_PEDAGOGICA.md](REVISAO_PEDAGOGICA.md).

## Editar questões

Cada item de `questions` contém:

| Campo | Conteúdo |
| --- | --- |
| `id` | Identificador único e estável, como `cie1` |
| `subject` | ID de uma disciplina: `math`, `history`, `science` ou `portuguese` |
| `topic` | Tema mostrado acima do enunciado |
| `difficulty` | Um dos valores `basic`, `intermediate` ou `challenge`; obrigatório e sensível a maiúsculas |
| `prompt` | Enunciado completo |
| `options` | Exatamente quatro alternativas diferentes e não vazias |
| `correct` | Índice inteiro de 0 a 3: A = 0, B = 1, C = 2, D = 3 |
| `explanation` | Explicação curta exibida após qualquer resposta |

Mantenha o JSON em UTF-8 e sem comentários. Revise correção, clareza, dificuldade e legibilidade antes de distribuir. A validação automática verifica a estrutura, não a correção pedagógica.

`basic` identifica revisão de conceitos ou aplicação direta; `intermediate`, aplicação contextualizada, comparação ou inferência; `challenge`, combinação de etapas, condições ou leitura crítica. São categorias editoriais provisórias, não medidas de desempenho dos jogadores. Desde E2/E3, a interface usa **Fácil, Médio e Difícil** e a sala determina o nível antes de considerar novidade e tema. Em 24/10/2026, mat20, cie10, por9, por15 e por20 foram revisadas para refletir melhor essa exigência; aceites pedagógicos continuam pendentes.

Matemática inclui funções, probabilidade, geometria, estatística, progressões e finanças. História combina conceitos, processos sociais e análise de fontes. Ciências reúne Biologia, Física e Química. Português inclui interpretação, argumentação, gramática em contexto, variação linguística e literatura. Exemplos de textos e situações são autorais, não transcrições de documentos históricos ou obras literárias.

## Ajustar recompensas

Cada disciplina em `subjects` tem `id`, `name` e `reward`. Os tipos suportados são:

| Tipo | Campos | Efeito |
| --- | --- | --- |
| `damage` | `amount`: inteiro positivo | Soma dano à régua |
| `heal` | `amount`: inteiro positivo | Cura até a vida máxima atual |
| `max_health` | `amount`: inteiro positivo; `heal`: inteiro não negativo | Amplia o limite e depois cura o valor indicado |
| `speed` | `amount`: percentual positivo; `cap`: limite entre amount e 100 | Soma pontos percentuais sobre a velocidade inicial, respeitando o limite |

O bônus exige acerto e conclusão da sala; é consumido uma única vez, cancelado na derrota e removido ao reiniciar. A interface lê as descrições do mesmo catálogo.

## Ofertas e validação

O sorteio prioriza disciplinas menos oferecidas e nunca repete uma matéria na mesma oferta. Cada questão apresentada é removida da partida, mesmo sem ser escolhida. Com as quatro matérias atuais, cada uma aparece duas vezes nas quatro salas; as primeiras duas salas apresentam todas as matérias. E2 aplica **básica → intermediária → intermediária → desafio** às duas opções, em ambas as rotas, inclusive após reiniciar.

Dentro da matéria e do nível da sala, usa inéditas antes de reutilizar as menos recentes da sessão; temas menos vistos desempatarão candidatas inéditas. Fechar o jogo encerra o histórico. Uma questão fácil já vista pode reaparecer antes de um desafio inédito, para preservar a curva; não há mais promessa de consumir as oitenta questões antes da primeira repetição global. Se um catálogo editado não tiver questões disponíveis no nível esperado, usa o nível mais próximo, favorecendo o mais fácil em empate. O catálogo atual possui estoque suficiente para cumprir a curva nas quatro salas. As alternativas são embaralhadas em cópias, com gabarito remapeado. Nenhuma questão se repete dentro da partida.

O carregador exige pelo menos duas disciplinas e duas questões por disciplina, além de dificuldade válida em cada item. A quantidade de oitenta questões e a distribuição 8/8/4 por matéria são metas de conteúdo verificadas nos testes, não limites fixos do carregador. Alterações de quantidade exigem rever a cobertura e a disponibilidade para quatro salas.

Execute `tools/check.ps1` com o caminho do Godot indicado em `COMO_JOGAR.md`. As dezessete suítes incluem catálogo/dificuldade, cobertura de temas, cem sementes com 64 partidas cada para progressão e variedade, esgotamento completo das oitenta questões, recompensas, movimento, consumo único, reset, monstros, coordenação, encontros, arte, rota científica, resumo/revisão de partida, áudio e treino. `tests/capture_catalog.gd` gera capturas reproduzíveis dos textos extensos em 960×540 e 1280×720.

E1 registra no resumo apenas as questões respondidas, copiando textos após o embaralhamento. O relatório local opcional inclui ID, tema, dificuldade, resposta escolhida, gabarito e explicação para apoiar a revisão. E3 acrescenta `difficulty_breakdown`, com `answered` e `correct` para os três níveis. Níveis não respondidos ficam com zero contagens, sem tratá-los como erros. Ele não altera este catálogo nem marca qualquer questão como pedagogicamente aprovada.

O preset Windows inclui `data/*.json`. Após editar, exporte novamente: o executável contém uma cópia embutida do catálogo e não usa o JSON externo.
