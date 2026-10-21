# School Rush — Game Design Document (GDD)

> Documento de design do jogo. Consolidado a partir do GDD original e das definições adicionais de inimigos, cenários, armas e perguntas.

> **Recorte de MVP (19/10/2026):** o [Plano de execução do MVP](PLANO_MVP.md) define o escopo, as regras propostas, os parâmetros iniciais e os critérios de aceite da primeira entrega. Em caso de divergência, usar esse recorte para implementar o MVP. O conteúdo abaixo permanece como visão ampliada do jogo; não representa compromisso de entrega integral na primeira versão. O cronograma de oito semanas abaixo é a referência original, substituída para o MVP pelos marcos do plano.

> **Atualização do MVP (21/10/2026):** público definido como Ensino Médio. A versão 0.1.2 inclui Matemática, História, Ciências e Português, com vinte questões e recompensas descritas no plano. A revisão pedagógica permanece pendente.

## 1. Informações básicas

- **Nome do jogo:** School Rush
- **Gênero:** Roguelike, em fases, ação
- **Plataforma:** PC
- **Resumo do jogo:** Um estudante preso em um livro enfrenta salas de combate e responde perguntas escolares para conquistar melhorias, derrotar Napoleão e voltar ao mundo real.
- **Referências:** *Binding of Isaac*, *Hades*.

## 2. Narrativa

- **História:** Um estudante é transmigrado para dentro de um livro e precisa passar por fases e desafios, enfrentando figuras históricas e aprimorando seu conhecimento para voltar ao mundo real.
- **Personagem principal:** Estudante sem nome.
- **Ambiente:** Diversos ambientes, incluindo salas com temática escolar.

## 3. Mecânicas de jogo

- **Objetivo:** Completar fases e aprimorar os atributos do personagem por meio de recompensas obtidas ao responder perguntas corretamente.
- **Ações principais:** Andar, correr, atacar e interagir.
- **Desafios e obstáculos:** Encontros com personagens históricos e outros monstros; salas com combate, puzzles ou desafios de travessia sem sofrer dano.
- **Sistema de pontuação ou progresso:** A definir. A progressão por salas e andares está descrita na seção 6.

## 4. Interface e HUD

- **Menus:** Início, Configurações e Pausa.
- **Elementos na tela:** Barra de vida, poder selecionado e arma selecionada.
- **Estilo visual:** Pixel art.

## 5. Personagens e itens

- **Personagem jogável:** Estudante sem nome, que representa o jogador.
- **NPC:** Vendedor.
- **Itens, poderes e armas:** Armas relacionadas à disciplina principal do estudante, incluindo as opções detalhadas na seção 12.

## 6. Níveis, fases e progressão

- O jogador começa em um andar, composto por uma quantidade **X de salas** (a definir).
- Para avançar, precisa completar os desafios dos encontros, como eliminar inimigos, resolver um puzzle ou atravessar uma sala sem receber dano.
- **Exemplo:** Uma sala contém três inimigos; após derrotar os três, as portas se abrem e o jogador pode continuar.
- **Dificuldade:** Aumenta com as salas e os andares, por meio de maior quantidade de monstros, inimigos mais fortes e resistentes, puzzles mais difíceis e perguntas mais complexas.
- **Escolha de perguntas:** Antes de entrar em cada sala, o jogador escolhe entre duas ou três perguntas. O sistema está detalhado na seção 13.
- **Recompensa:** É concedida após a conclusão da sala, conforme a mecânica de perguntas e progressão.

## 7. Áudio

- **Trilha sonora geral:** A definir.
- **Trilha da luta contra o chefe final:** Paródia do hino da França, associada ao confronto com Napoleão.
- **Efeitos sonoros:** A definir (ações, inimigos e ambientes).
- **Narração em áudio:** A definir.

## 8. Equipe

| Integrante | Responsabilidade |
| --- | --- |
| Igor | Game design |
| Matheus | Animação |
| Moisés | Programação |
| Eduardo | Imagens e ambientação |

## 9. Cronograma de desenvolvimento

| Semana | Etapa | Atividades | Responsável principal | Entrega esperada |
| --- | --- | --- | --- | --- |
| 1 | Ideação / Pré-produção | Finalizar GDD, definir disciplinas, primeira fase, inimigos, armas, sistema de perguntas e progressão | Igor + equipe | GDD v1 fechado |
| 2 | Protótipo base | Criar projeto, movimentação, corrida, colisões, câmera, salas e transição entre salas | Moisés | Personagem andando pelo mapa |
| 3 | Combate | Sistema de ataque, vida, dano, inimigo básico, morte e reinício da sala | Moisés + Matheus | Primeira sala de combate jogável |
| 4 | Estrutura Roguelike | Gerenciamento das salas, portas, encontros, geração/seleção de salas e progressão entre elas | Moisés + Igor | Pequena sequência de salas funcional |
| 5 | Conhecimento / Perguntas | Perguntas educacionais, respostas, recompensas, atributos e poderes | Moisés + Igor | Loop educacional integrado ao jogo |
| 6 | Arte e conteúdo | Sprites definitivos, animações, cenário, HUD, armas, NPC vendedor e primeiro personagem histórico | Eduardo + Matheus | Primeira fase visualmente completa |
| 7 | Boss + Progressão | Criar chefe, aumentar dificuldade, conclusão do andar, tela de vitória/derrota e progressão | Equipe | Primeiro andar completo |
| 8 | Testes / Finalização | Balanceamento, correção de bugs, áudio, menus, pausa, configurações, build para PC e testes finais | Todos | MVP demonstrável |

## 10. Inimigos

Os inimigos são organizados em categorias conforme seu estilo de combate.

| Categoria | Inimigo | Conceito de ataque |
| --- | --- | --- |
| Melee (corpo a corpo) | Dado flutuante | Ataques corpo a corpo; comportamento específico a definir |
| Melee (corpo a corpo) | Centurião romano | Ataques corpo a corpo; comportamento específico a definir |
| Ranged (à distância) | Nuvem | Lança raios |
| Ranged (à distância) | Babuíno | Lança pedras |
| Special (especial) | Cientista | Arremessa misturas químicas |
| Special (especial) | Planta-cacto | Lança espinhos |
| Chefe final (boss) | Napoleão | Mecânicas e padrões de ataque a definir |

**Chefe final:** Napoleão. A batalha terá uma trilha sonora concebida como paródia do hino da França.

## 11. Cenários

**Temática geral:** Escola.

Quatro modelos de salas comuns:

1. **Sala de aula**
2. **Biblioteca**
3. **Laboratório de ciências**
4. **Pátio com plantas e bancos**

**Sala do chefe final:** Ginásio.

> O ginásio é um cenário específico do boss e não integra a contagem dos quatro modelos de salas comuns.

## 12. Armas

### 12.1. Arma melee — régua

| Nível | Arma |
| --- | --- |
| 1 | Régua de plástico |
| 2 | Régua de madeira |
| 3 | Régua de metal |

### 12.2. Arma ranged — lapiseira

- **Tipo de ataque:** Dispara grafites.
- **Progressão:** Conforme o nível da arma aumenta, mudam a graduação dos grafites e a quantidade disparada.
- **Graduações previstas:** 0,5 mm; 0,7 mm; 0,9 mm.
- **Quantidade de projéteis por nível:** A definir.

## 13. Sistema de perguntas

- **Momento:** Antes de entrar em cada sala.
- **Escolha:** O jogador escolhe entre **duas ou três perguntas** disponíveis.
- **Formato:** Perguntas objetivas de múltipla escolha.
- **Alternativas:** Quatro por pergunta.
- **Banco de questões:** Cinco variações de perguntas para cada matéria, vinculadas à respectiva área do conhecimento.
- **Recompensa:** Concedida **após completar a sala**.
- **Relação com a progressão:** Acertos estão relacionados à melhoria dos atributos do estudante, conforme definido nas mecânicas gerais.

### Pontos pendentes de definição

- Quais serão as matérias e áreas do conhecimento disponíveis.
- Como as perguntas são selecionadas e qual é a diferença entre escolher duas ou três opções.
- Como um acerto ou erro influencia a recompensa recebida após a sala.
- Valores de atributos, dano, vida, velocidade e regras de balanceamento dos inimigos e armas.
- Padrões de ataque e fases do chefe Napoleão.
- Sistema de pontuação ou progresso e quantidade de salas por andar.
