# Catálogo educacional

`curriculum.json` é a fonte de disciplinas, recompensas e questões. O público atual é Ensino Médio, com vinte questões autorais de revisão introdutória (cinco por matéria). O conteúdo ainda precisa de revisão pedagógica da equipe; não há alinhamento certificado a uma série ou currículo específico.

## Editar questões

Cada item de `questions` contém:

| Campo | Conteúdo |
| --- | --- |
| `id` | Identificador único e estável, como `cie1` |
| `subject` | ID de uma disciplina: `math`, `history`, `science` ou `portuguese` |
| `topic` | Tema mostrado acima do enunciado |
| `prompt` | Enunciado completo |
| `options` | Exatamente quatro alternativas diferentes e não vazias |
| `correct` | Índice inteiro de 0 a 3: A = 0, B = 1, C = 2, D = 3 |
| `explanation` | Explicação curta exibida após qualquer resposta |

Mantenha o JSON em UTF-8 e sem comentários. Revise correção, clareza, dificuldade e legibilidade antes de distribuir. A validação automática verifica a estrutura, não a correção pedagógica.

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

O carregador exige pelo menos duas disciplinas e duas questões por disciplina. Mantenha as quatro disciplinas com cinco questões para preservar o escopo atual e a cobertura dos testes. Alterações de quantidade exigem rever os testes e a disponibilidade para quatro salas.

Execute `tools/check.ps1` com o caminho do Godot indicado em `COMO_JOGAR.md`. As nove suítes incluem erros de catálogo, distribuição em 50 sequências, quatro recompensas, limite de velocidade, movimento real, consumo único, reset, monstros e encontros. Rode também as capturas para conferir textos longos.

O preset Windows inclui `data/*.json`. Após editar, exporte novamente: o executável contém uma cópia embutida do catálogo e não usa o JSON externo.
