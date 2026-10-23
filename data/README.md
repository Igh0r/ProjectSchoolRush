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

`basic` identifica revisão de conceitos ou aplicação direta; `intermediate`, aplicação contextualizada, comparação ou inferência; `challenge`, combinação de etapas, condições ou leitura crítica. São categorias editoriais provisórias, não medidas de desempenho dos jogadores. O D1 registra a dificuldade; seleção progressiva e embaralhamento de alternativas entram no D2.

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

O sorteio prioriza disciplinas menos oferecidas e nunca repete uma matéria na mesma oferta. Cada questão apresentada é removida da partida, mesmo sem ser escolhida. Com as quatro matérias atuais, cada uma aparece duas vezes nas quatro salas; as primeiras duas salas apresentam todas as matérias. O banco reinicia a cada partida.

O carregador exige pelo menos duas disciplinas e duas questões por disciplina, além de dificuldade válida em cada item. A quantidade de oitenta questões e a distribuição 8/8/4 por matéria são metas de conteúdo verificadas nos testes, não limites fixos do carregador. Alterações de quantidade exigem rever a cobertura e a disponibilidade para quatro salas.

Execute `tools/check.ps1` com o caminho do Godot indicado em `COMO_JOGAR.md`. As onze suítes incluem erros de catálogo/dificuldade, cobertura de temas, distribuição em 50 sequências, esgotamento completo das oitenta questões, quatro recompensas, limite de velocidade, movimento real, consumo único, reset, monstros, encontros, arte e rota científica. `tests/capture_catalog.gd` gera capturas reproduzíveis dos textos extensos em 960×540 e 1280×720.

O preset Windows inclui `data/*.json`. Após editar, exporte novamente: o executável contém uma cópia embutida do catálogo e não usa o JSON externo.
