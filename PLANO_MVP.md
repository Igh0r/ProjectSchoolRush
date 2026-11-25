# School Rush — análise e plano de execução do MVP

Data: 19/10/2026. Proposta de escopo para a equipe, sujeita a playtest.

**Situação atual (25/10/2026):** base anterior aprovada pelo usuário e Igor. **D1–D4 e E1–E6 implementados; candidata 0.3.0-rc6:** oitenta questões para Ensino Médio, progressão fácil → médio → médio → difícil, variedade dentro do nível, combate aprimorado, resumo/revisão, áudio, treino opcional e estudante sem nome próprio com sprites de caminhada e régua. Permanecem seis monstros, duas rotas de quatro salas e quatro pisos. Dezoito suítes aprovadas. **D5 segue aberto para novo playtest, ajustes de balanceamento, revisão pedagógica e teste em outro PC.** Instruções em [COMO_JOGAR.md](COMO_JOGAR.md), análise em [ART_ANALYSIS.md](ART_ANALYSIS.md), integração em [SPRITES.md](SPRITES.md) e registro em [PLAYTEST.md](PLAYTEST.md).

## Preparação para apresentação — 25/11/2026

O usuário confirmou o playtest. Em 25/11, solicitou atualizar e testar o executável para apresentar nas escolas em 26/11. Pull cfde523 recebido; 18 suítes aprovadas, exportação e inicialização verificadas. Evidências, limitações e pacote estão em [VALIDACAO_APRESENTACAO.md](VALIDACAO_APRESENTACAO.md). O próximo bloco de funcionalidades fica para depois da apresentação. Revisão pedagógica por ID e teste no PC das escolas continuam sem confirmação.

## Objetivo e situação atual

### Nova fase — variedade e combate (23/10/2026)

O usuário informou que ele e Igor verificaram o jogo, aprovaram o playtest e solicitaram mais variedade de perguntas e melhorias no combate dos inimigos. Esse aceite permite prosseguir; a proposta anterior de cinco participantes externos passa a ser uma rodada complementar, sem bloquear esta fase. Não foram informados tempos, contagem de partidas ou resultados por item do roteiro.

**Objetivo:** tornar as partidas repetidas mais interessantes, com perguntas de temas e raciocínios diferentes e inimigos que exijam decisões de posicionamento, esquiva e contra-ataque. Preservar as duas rotas, quatro salas, quatro disciplinas, recompensas e controles já aprovados. As metas abaixo orientam a implementação; a coluna de situação distingue entregas e trabalho futuro.

| Bloco | Entrega planejada | Critério de aceite | Situação |
| --- | --- | --- | --- |
| D1 — ampliar o conteúdo | Crescer de 20 para 80 questões, em dois lotes: 40 e depois 80; chegar a 20 por disciplina, com tema e dificuldade identificados | Quatro alternativas distintas, uma resposta correta, explicação útil e variedade real de temas; catálogo validado e revisão por ID registrada | Entregue tecnicamente; onze suítes aprovadas; revisão de Igor pendente por ID |
| D2 — variar a seleção | Priorizar questões ainda não vistas na sessão, variar temas e embaralhar alternativas; introduzir progressão suave de dificuldade | Sem repetição na mesma partida; reiniciar não repete imediatamente as mesmas ofertas quando há opções disponíveis; resposta correta acompanha o embaralhamento | Concluído tecnicamente; doze suítes aprovadas |
| D3 — melhorar os inimigos | Ajustar posicionamento, separação e recuperação dos cinco inimigos comuns, mantendo avisos legíveis | Cada inimigo tem papel reconhecível; há oportunidade de esquiva e contra-ataque; paredes, pausa, morte e limpeza continuam corretas | Concluído tecnicamente; treze suítes aprovadas; sensação final em playtest |
| D4 — ritmo dos encontros e chefe | Coordenar ataques perigosos nas salas mistas e acrescentar um segundo padrão anunciado ao Napoleão | Ataques sobrepostos preservam espaço de fuga; chefe alterna padrões reconhecíveis; ambas as rotas continuam concluíveis sem bônus | Concluído tecnicamente; quatorze suítes aprovadas; dificuldade humana a confirmar |
| D5 — balanceamento e entrega | Comparar com a base aprovada, realizar novo playtest e preparar 0.3.0-rc1 | Regressões aprovadas, feedback da equipe registrado, textos/avisos inspecionados e pacote Windows validado | Entrega técnica preparada; playtest e revisão humana pendentes |
| E1 — resumo e revisão antes do playtest | Mostrar resultado, tempo, salas e respostas; permitir salvar relatório local | Revisão fiel às alternativas embaralhadas, sem repetir recompensas; pausa e telas finais não contam tempo; exportação opcional sem sobrescrever outra partida | Implementado; quinze suítes aprovadas; candidata 0.3.0-rc2 |
| E2 — balanceamento das perguntas | Garantir começo fácil e final difícil; alinhar questões ao esforço esperado | Ambas as opções seguem fácil/médio/médio/difícil, inclusive após reiniciar; novidade e tema não deslocam o nível | Implementado; 6.400 partidas simuladas e cinco questões revisadas |
| E3 — comunicar e acompanhar a curva | Mostrar nível antes da escolha e acertos por dificuldade na revisão/relatório | Mesma classificação na oferta, resposta e revisão; nível não alcançado não conta como erro | Implementado; quinze suítes aprovadas; candidata 0.3.0-rc3 |
| E4 — conforto de áudio | Ajustar música e efeitos pelo menu/pausa e salvar preferências | Volumes independentes, silêncio real em zero, pausa preservada e ajustes restaurados ao reabrir | Implementado; dezesseis suítes aprovadas; candidata 0.3.0-rc4 |
| E5 — treino dos controles | Área opcional para mover, correr, atacar e sair | Ações reais concluem etapas; alvo não ataca; pausa funciona; perguntas, bônus e relatórios não são consumidos | Implementado; dezessete suítes aprovadas; candidata 0.3.0-rc5 |
| E6 — sprites do estudante | Integrar caminhada e régua de `school_rush_player`; personagem sem nome próprio | Transparência, direção, pausa e reinício corretos; física e dano preservados | Implementado; dezoito suítes aprovadas; candidata 0.3.0-rc6 |

#### E6 — estudante sem nome próprio (25/10/2026)

O usuário determinou que o personagem não terá nome e forneceu `school_rush_player` com sprites prontos. Essa decisão substitui o plano anterior de preparar personagens nomeados das pranchas antigas. A documentação trata o protagonista apenas como **estudante**; nomes de integrantes da equipe nas atribuições históricas não se referem ao personagem.

- `student_frames.tres` usa os 48 PNGs originais: oito animações de seis quadros, para caminhada e ataque em quatro direções. Sem edição dos pixels. Repouso usa o quadro 0 da caminhada, e a corrida acelera a reprodução junto à velocidade real do movimento.
- `AnimatedSprite2D` em `scenes/player/player.tscn`, filtro Nearest, escala visual 0,28 e posição `(0, -8)`. O corpo continua em escala 1, colisão circular de raio 15, velocidade inicial 230, corrida ×1,4, dano 10, alcance 60 e recarga de 0,4 s. O treino passa a usar o mesmo estudante animado.
- Ataque começa no quadro 3 (quarto quadro, impacto) e usa 3–5 a 15 fps, cerca de 0,2 s de impacto/recuperação visual. Os quadros de antecipação 0–2 permanecem no material fornecido, mas não atrasam o dano instantâneo existente. Avançar a animação nunca aplica dano adicional. Direção visual e arco do golpe ficam fixos na direção do ataque já emitido.
- Diagonais mantêm o cone físico original, usando a vista vertical no empate entre eixos. O pequeno indicador dourado mostra a direção exata e o arco fino mostra o alcance no ataque. Dano tinge o sprite brevemente e mantém um anel durante a invulnerabilidade; derrota congela/escurece o estudante. Pausa congela quadros e recarga; reinício limpa pose, direção e tintura.
- Os arquivos recebidos e seus recursos ficam versionados em `school_rush_player`. A exportação usa os PNGs individuais e o SpriteFrames; `source_generated.png` e o atlas duplicado ficam como referência no projeto, fora do executável. O guia original do pacote permanece preservado.
- Dezoito suítes aprovadas. Nova suíte verifica os 48 quadros, dimensões/transparência, quatro direções, repouso, corrida, diagonal, dano imediato/único, recarga, pausa, derrota e reinício. As suítes de movimento, combate e treino continuam verificando a física real.
- Capturas em `builds/previews/e6-*.png`, geradas por `tests/capture_player.gd`: vistas, caminhada, impacto, diagonal, dano, treino e ginásio redimensionado. Escala e indicadores foram inspecionados em 960×540 e 1280×720.
- Pacote Windows: `builds/SchoolRush-MVP-0.3.0-rc6-windows-x64.zip`; log técnico: `builds/validation-0.3.0-rc6.log`. E5 foi preservado no commit `22904a4` e no pacote rc5.

**Próximo passo:** validar a leitura do estudante e da régua no treino e nas duas rotas, junto da curva de perguntas e do combate de D5. Ajustar alinhamento/escala com feedback concreto, sem alterar a colisão para compensar a arte. Não há seleção de personagem ou nomes próprios no escopo atual.

#### E5 — treino opcional dos controles (24/10/2026)

O usuário autorizou continuar com o próximo bloco. Foi acrescentado **Treinar controles • Área segura** ao menu, para praticar antes de iniciar uma rota. O treino é opcional e não muda os encontros nem a curva das perguntas.

- Quatro etapas guiadas no HUD: chegar ao círculo azul com WASD/setas; correr com Shift até o círculo amarelo, percorrendo ao menos 120 px em corrida; destruir um alvo com a régua; chegar à porta verde e pressionar E. Segurar Shift parado ou contra a parede não cumpre a meta de distância.
- O alvo reutiliza o dado com 30 de vida, mas fica parado/inativo e não causa dano. Os golpes usam o alcance, cone frontal, dano e recarga reais da régua. Com dano inicial 10, são necessários três acertos. A porta abre somente depois de destruir o alvo; E longe da porta não conclui o treino.
- Pausa oferece continuar, áudio, recomeçar treino e voltar ao início. Ajustes de áudio preservam a pausa; sair ou reiniciar limpa alvo e marcadores. A conclusão oferece as duas rotas, repetir treino e início. Começar uma rota restaura atributos e inicia a sala fácil normalmente.
- Treino não oferece questões, não altera o histórico da sessão, não aplica bônus e não registra duração/respostas/resultado como partida. Áudio e preferências continuam os mesmos. O exercício ensina controles; esquiva dos padrões inimigos continua sendo avaliada nas partidas reais.
- Dezessete suítes aprovadas. A nova suíte usa movimento real, corrida contra parede, alcance/direção/recarga de golpes, alvo passivo, pausa com áudio, porta, conclusão, reinício, abandono com alvo e transição para rota. Confere ausência de bônus e de alterações no histórico/relatório.
- Capturas das quatro etapas, menu, pausa e conclusão em 960×540 e 1280×720: `tests/capture_training.gd`; arquivos `builds/previews/e5-*.png`. Os controles do menu e textos foram inspecionados.
- Candidata Windows: `builds/SchoolRush-MVP-0.3.0-rc5-windows-x64.zip`; log: `builds/validation-0.3.0-rc5.log`.

**Continuidade:** E6 foi concluído com o estudante sem nome próprio e o novo pacote fornecido, substituindo a preparação das pranchas antigas. D5 humano segue em paralelo, com revisão pedagógica e playtest das duas rotas; este treino não substitui esse aceite.

#### E4 — ajustes de áudio (24/10/2026)

Com a continuidade autorizada e sem novo retorno humano de D5, este bloco trata do conforto do áudio, item já previsto no roteiro. A música tinha volume fixo e M controlava somente os efeitos. Agora o menu inicial e a pausa oferecem **Áudio**, com volumes independentes de 0 a 100%, em passos de 5%, e opção de silenciar efeitos.

- Ajustes aplicados na hora. Música em zero permanece na mesma faixa/posição sem som; efeitos em zero ou silenciados param os canais ativos e impedem novos sons. 100% corresponde aos volumes anteriores, sem ampliar o ganho original. M continua alternando somente os efeitos e sincroniza o controle quando a tela está aberta.
- **Salvar e voltar** grava `user://audio.cfg`; a próxima abertura restaura volumes e silêncio. **Voltar sem salvar** ou Esc preserva os ajustes apenas nesta sessão. **Restaurar padrão** aplica 100% nos dois canais e remove o silêncio; salvar é necessário para conservar esse padrão ao reabrir. Reiniciar uma partida não reinicia preferências de áudio.
- Na pausa, abrir, ajustar e fechar áudio mantém inimigos, perigos e cronômetro parados. Esc volta primeiro à pausa; Continuar/Esc retoma o jogo depois. Arquivo ausente usa o padrão; tipos inválidos/valores fora do intervalo são normalizados; falha de leitura ou salvamento recebe mensagem sem bloquear a partida. Arquivos de relatório e catálogo são independentes.
- Dezesseis suítes aprovadas. A nova suíte usa configuração temporária em `builds`, verifica controles reais, canais independentes, zero/silêncio, M, limites/tipos, leitura/gravação, falha/retentativa, padrão, reinício e pausa sem avanço do tempo. Preferências do jogador não são alteradas pelos testes.
- Capturas em 960×540/1280×720 de menu, áudio, pausa, controles ajustados e aviso de erro; reprodução em `tests/capture_audio.gd`, arquivos `builds/previews/e4-*.png`. Layout compacto oferece mouse, Tab e setas. Conforto auditivo continua dependendo da avaliação da equipe.
- Candidata Windows: `builds/SchoolRush-MVP-0.3.0-rc4-windows-x64.zip`; log: `builds/validation-0.3.0-rc4.log`. As candidatas anteriores permanecem disponíveis.

**Próximo passo:** playtest da candidata atual com as duas rotas, revisão pedagógica e avaliação dos volumes. Registrar ajustes de perguntas/encontros com evidência; a arte do estudante foi integrada posteriormente em E6.

#### E2 e E3 — progressão educacional (24/10/2026)

O usuário solicitou perguntas mais fáceis no começo e mais difíceis no final, autorizando a continuidade dos blocos. A análise encontrou que D2 tratava dificuldade como preferência posterior à novidade e ao tema; isso permitia inverter a curva após reinícios ou em temas repetidos.

- A sala agora determina primeiro o nível das duas opções: **sala 1 fácil; salas 2 e 3 médias; sala 4 difícil**, nas duas rotas. As salas centrais mantêm o mesmo patamar para consolidar conteúdo antes do chefe. Errar não impede progressão e não altera o nível das próximas salas.
- Dentro de matéria/nível, a prioridade é inédita na sessão, depois menos recente; variedade de tema desempata candidatas inéditas. Reiniciar e voltar ao menu preservam o histórico. A exigência de consumir todas as oitenta antes de qualquer repetição global foi substituída por novidade dentro do nível: uma fácil pode repetir antes de um desafio inédito. As oito ofertas da partida continuam sem repetir IDs, e cada matéria aparece duas vezes.
- Se um catálogo futuro não tiver o nível esperado disponível, o fallback usa o nível mais próximo, preferindo o mais fácil no empate. O banco atual de 8 fáceis, 8 médias e 4 difíceis por matéria tem estoque suficiente para garantir a curva. A classificação continua editorial; a percepção real depende do playtest.
- Cinco questões ajustadas, preservando IDs, níveis e letras dos gabaritos: `mat20` acrescenta restrição à contagem; `cie10` combina dois trechos; `por9` relaciona dois referentes; `por15` exige inferir limite do narrador; `por20` combina ironia e descontextualização. Registro em `data/REVISAO_PEDAGOGICA.md`, sem marcar aceite de Igor.
- A oferta mostra **Fácil/Médio/Difícil** antes da escolha, além da sequência das quatro salas. A primeira página de revisão mostra acertos/respondidas por nível; níveis não alcançados aparecem como não respondidos. O JSON acrescenta `difficulty_breakdown` com contagens por nível, preservando respostas e demais campos.
- Quinze suítes aprovadas. A de variedade percorre cem sementes × 64 partidas (6.400), verificando a curva nas duas opções, novidade/menos recente dentro do nível, equilíbrio das matérias, ausência de repetição na partida, acesso às oitenta questões e embaralhamento correto. Cobertura inclui catálogo com nível ausente, empate de fallback, reinício, fluxo real, JSON e derrota antes dos níveis seguintes.
- Capturas das quatro salas e resultados por nível em 960×540/1280×720: `tests/capture_difficulty.gd`, arquivos `builds/previews/e2-*` e `e3-*`. As cinco questões revisadas também foram capturadas por `tests/capture_catalog.gd`, com verificação de largura e acesso à última alternativa. Isso não substitui avaliação de dificuldade por estudantes.
- Pacote Windows: `builds/SchoolRush-MVP-0.3.0-rc3-windows-x64.zip`; log técnico: `builds/validation-0.3.0-rc3.log`. Mantidos os pacotes anteriores como referência.

**Próximos blocos:** D5 humano — jogar ambas as rotas, observar a curva e revisar os cinco IDs alterados junto ao restante do banco; registrar acertos por nível e separar dúvidas de conteúdo de dificuldades do combate. Ajustar textos/classificações/encontros com esse retorno. A arte do estudante foi integrada posteriormente em E6; não acrescentar sistemas grandes antes de validar a curva.

#### E1 — resumo, revisão e apoio ao playtest (23/10/2026)

O usuário autorizou mais um bloco antes dos playtests. A entrega acrescenta valor educacional após a partida e facilita o registro da próxima rodada, sem alterar os parâmetros de combate.

- Vitória e derrota mostram rota, salas concluídas, acertos sobre respostas efetivamente dadas, tempo sem pausas e atributos finais. O tempo inclui escolha, leitura, feedback, combate e caminhada à saída; exclui menu, pausa e telas finais/revisão. O relatório também separa tempo em combate. Reiniciar inicia nova contagem.
- **Rever respostas** permite percorrer apenas as questões respondidas, com ID, matéria, tema, dificuldade, resposta escolhida, gabarito e explicação. Os textos vêm da alternativa apresentada após embaralhar. A revisão é somente leitura e não concede bônus. Recebimento, ausência de efeito no limite e cancelamento por derrota aparecem separadamente.
- **Salvar resumo neste computador** grava um JSON opcional em `user://reports`, com caminho mostrado na tela. Inclui versão, data UTC, rota, tempos, resultado, atributos e respostas; não solicita nome nem envia dados pela rede. Um segundo clique reutiliza o arquivo, partidas no mesmo segundo recebem nomes diferentes e falhas permitem tentar novamente. Reiniciar/fechar descarta o resumo em memória; arquivos já salvos permanecem, sem funcionar como save ou histórico de perguntas.
- Quinze suítes aprovadas, incluindo contagem sem duplicação, alternativas embaralhadas, pausa, revisão sem efeitos, reinício, derrota simultânea, bônus cancelado/sem efeito, cópia imutável do resultado, JSON e falha/retentativa de salvamento. Testes usam arquivos temporários em `builds`, sem escrever relatórios do jogador.
- Capturas de vitória, derrota, confirmação de salvamento e revisão de texto extenso em 960×540/1280×720 em `builds/previews/e1-*.png`; reprodução em `tests/capture_run_report.gd`. Rolagem acompanha a navegação por teclado e cada painel começa no título.
- Candidata Windows: `builds/SchoolRush-MVP-0.3.0-rc2-windows-x64.zip`. Registro técnico da exportação em `builds/validation-0.3.0-rc2.log`. A rc1 permanece como referência da etapa anterior. Este bloco não equivale a aceite humano de D5.

**Continuidade:** E2/E3 acima substituíram a candidata rc2 pela rc3. Usar a candidata atual nas duas rotas, salvar os resumos desejados e registrar dúvidas por ID e problemas de ataques por sala no `PLAYTEST.md`. Igor continua com a revisão pedagógica dos oitenta IDs.

#### D1 e D2 — perguntas para Ensino Médio

**Entrega D1 (23/10/2026, 0.3.0-dev1):**

- Primeiro lote de quarenta questões validado no Godot; segundo lote completou oitenta, preservando os vinte IDs originais e todas as recompensas. Vinte questões por disciplina, distribuídas em oito básicas, oito intermediárias e quatro desafios. Exemplos incluem probabilidade condicional, interpretação de fontes, genética, circuitos elétricos, ambiguidades e análise de argumentos.
- Campo obrigatório `difficulty` com valores `basic`, `intermediate` e `challenge`. Carregador rejeita ausência, tipos e valores inválidos. Tema já existente preservado. Dificuldade ainda não influencia sorteio nem aparece como progressão na partida; essa integração pertence ao D2.
- Onze suítes passaram sem falhas. Cobertura ampliada para validação de dificuldade, cobertura temática, enunciados duplicados, acesso às oitenta questões até esgotar o banco e reset completo. As cinquenta sequências de ofertas continuam preservando o equilíbrio das matérias e ausência de repetição dentro da partida.
- Capturas de ofertas, respostas e explicações extensas geradas em 960×540 e 1280×720, com inspeção de amostras. A rolagem existente atende perguntas mais longas; a captura verifica acesso à última alternativa quando necessário. Arquivos locais em `builds/previews/d1/`; reprodução em `tests/capture_catalog.gd`.
- [data/README.md](data/README.md) documenta o esquema e os critérios editoriais. [data/REVISAO_PEDAGOGICA.md](data/REVISAO_PEDAGOGICA.md) acompanha os oitenta IDs com tema, dificuldade, gabarito e campos de resultado/revisor. Todos os aceites pedagógicos continuam pendentes; não foram inferidos a partir do playtest geral.
- Projeto identificado como 0.3.0-dev1; a build Windows 0.2.0-rc2 foi preservada. Testar este bloco pelo projeto no Godot; exportação candidata prevista no D5. O combate continua na base aprovada até D3/D4.

Regras para a continuidade de D1/D2:

**Entrega D2 (23/10/2026):** histórico das ofertas mantido durante a sessão, inclusive ao reiniciar ou voltar ao menu. Inéditas têm prioridade; após esgotar, retorna a menos recente, sem repetir dentro da partida. Entre inéditas, prioriza temas menos apresentados e depois dificuldade: revisão → aplicação → aplicação → desafio. São preferências, com fallback para o conteúdo disponível. Alternativas são embaralhadas com gabarito remapeado em uma cópia; o JSON permanece intacto. A resposta mostra a classificação em linguagem simples. Nova suíte testa cem sementes, doze partidas por semente, as oitenta inéditas nas dez primeiras partidas completas, distribuição das matérias, respostas certas/erradas, esgotamento e fallback. Doze suítes passaram. Próximo trabalho: D3.

- Manter Matemática, História, Ciências e Português. Meta por disciplina: ao menos quatro temas, com questões conceituais, aplicação e interpretação; trocar apenas números ou palavras não conta como variedade suficiente. Ciências deve contemplar Biologia, Física e Química.
- Proposta de distribuição por disciplina: oito questões básicas de revisão, oito intermediárias e quatro de desafio. A classificação deve refletir o raciocínio necessário e ser revisada por Igor; não vincular dificuldade somente ao tamanho do enunciado.
- Dificuldade acrescentada no D1, preservando IDs estáveis e o campo de tema existente; validação e `data/README.md` atualizados. Registrar revisão de enunciado, alternativas, gabarito e explicação por ID, inclusive das vinte questões originais.
- Priorizar questões não apresentadas em partidas anteriores da mesma sessão, contando também as ofertas não escolhidas. Ao esgotar as opções, reutilizar as menos recentes, sempre excluindo as já apresentadas na partida atual. Fechar o jogo encerra esse histórico; save permanente fica fora desta fase.
- Preservar duas matérias diferentes por sala, todas as quatro matérias nas duas primeiras salas e duas aparições de cada matéria por partida. A seleção começa por revisão básica e amplia a presença de questões intermediárias/desafio nas últimas salas, sem travar quando um grupo se esgota.
- Embaralhar alternativas sem alterar o catálogo original, remapeando a resposta correta e o feedback. **Regra atualizada em E2:** regras da partida e disponibilidade → nível da sala → novidade/menos recente dentro do nível → tema. A prioridade anterior de D2 é histórica e foi substituída para garantir o começo fácil e o final difícil.
- Validar sequências com sementes reproduzíveis, esgotamento do banco, reinícios, equilíbrio das matérias e correspondência entre gabarito e alternativas. Inspecionar enunciados e explicações longos em 960×540.

#### D3 e D4 — combate com decisões mais claras

**Entrega D3 (23/10/2026):** dados e centurião usam separação ao aproximar; dados também alternam o lado da aproximação. Nuvem reposiciona a 45 px/s nos últimos 0,65 s da recuperação, buscando a faixa de 180–260 px; cientista reposiciona a 40 px/s nos últimos 1,2 s, buscando 150–230 px. A fuga é curta e mais lenta que o jogador; avisos mantêm origem/mira fixas. Centurião exibe anel e texto ABERTO na recuperação. Cacto alterna leques de ±0,28 e ±0,50 rad, sempre com três espinhos e linhas correspondentes ao padrão seguinte. Vida, dano e tempos de aviso preservados. Treze suítes aprovadas, incluindo movimento real, separação, paredes, recuperação e correspondência entre aviso e disparo. Capturas em 960×540/1280×720 geradas; amostra de leque/recuperação inspecionada. Próximo trabalho: D4, coordenação e segundo padrão do chefe.

| Inimigo | Papel e melhoria proposta | Como verificar |
| --- | --- | --- |
| Dado | Pressão próxima; reduzir amontoamento com separação e aproximações por posições diferentes | Dois dados não permanecem sobrepostos nem empurram o jogador através das paredes; dano por contato respeita os intervalos |
| Nuvem | Ataque à distância; buscar uma faixa de distância e reposicionar entre disparos | Não foge indefinidamente; jogador consegue alcançar e contra-atacar; mira continua fixa durante o aviso |
| Centurião | Ataque frontal forte; melhorar aproximação e tornar a recuperação após errar mais perceptível | Sair do setor evita dano e abre uma janela clara para atacar; golpe não acompanha o jogador durante o aviso |
| Cacto | Controle de espaço; alternar duas aberturas de espinhos, anunciando as trajetórias reais | Ambos os padrões deixam brechas utilizáveis e não geram dano antes do fim do aviso |
| Cientista | Área temporária; reposicionar entre misturas e coordenar sua ativação com outros perigos | Marca permanece fixa após o aviso começar; jogador consegue sair; mistura continua com no máximo um acerto |
| Napoleão | Combinar a investida existente com um golpe frontal de curto alcance, cada um com aviso e recuperação próprios | Padrão é reconhecível antes do dano; não há troca de direção após travar a mira nem sequência sem recuperação |

Começar pelo movimento e pelas janelas de ataque, mantendo vida e dano atuais como referência. Ajustar um comportamento por vez antes de alterar números. Preservar no máximo quatro inimigos simultâneos e entrada protegida; não adicionar novas espécies, ondas ou salas nesta fase.

Para as salas mistas, propor um coordenador simples de ataques: iniciar com no máximo dois ataques especiais em preparação/execução, contando projéteis e áreas ainda ativos como pressão. Calibrar esse limite no playtest; o número sozinho não comprova uma rota de fuga. Inimigos que aguardam continuam se posicionando. Pausa congela a coordenação; morte, fim da sala e reinício liberam reservas para evitar bloqueios. Verificar visualmente os encontros mais carregados, especialmente perto das paredes.

**Entrega D4 (23/10/2026):** no máximo dois ataques especiais por vez, incluindo fontes com tiros/misturas ainda ativos. Uma fila atende os atacantes que aguardam; sair do alcance, morrer, encerrar a sala ou reiniciar remove solicitações. Inimigos móveis continuam reposicionando enquanto aguardam. Pausa congela os ataques e impede concessão de vagas. O teto é por ataque/fonte: os três espinhos de um leque ocupam uma vaga até sumirem; dano de contato dos dados é independente.

Napoleão preserva a investida e ganha VARREDURA: setor de 125 px e ±0,9 rad, mira fixa, aviso de 0,9 s, um acerto de 20, efeito de 0,2 s e recuperação de 1,2 s com ABERTO. Depois da investida, aproxima a 100 px/s por até 1,6 s para tentar varrer; se o jogador continuar distante, anuncia outra investida. Após varrer, volta à investida. Vida e dano anteriores preservados. Dicas e HUD explicam os dois avisos.

Quatorze suítes passaram. A nova suíte verifica teto, espera até sumir o perigo, pausa, morte/limpeza, direção fixa, esquiva, dano único e transições do chefe. Uma simulação real de dez segundos com nuvem, cientista e centurião confirmou ataques recorrentes de todos sem ultrapassar o teto. Capturas dos dois avisos e recuperação do chefe inspecionadas em 960×540/1280×720. Isso não mede diversão nem garante esquiva de todas as combinações; pressão perto das paredes é foco da próxima rodada humana.

#### D5 — evidência e versionamento

**Preparação técnica (23/10/2026, 0.3.0-rc1):**

- Quatorze suítes aprovadas sem falhas; exportação Windows x64 e inicialização standalone aprovadas. Registro local em `builds/validation-0.3.0-rc1.log`.
- Pacote: `builds/SchoolRush-MVP-0.3.0-rc1-windows-x64.zip`. Inclui executável com conteúdo embutido, guia, plano, roteiro, avisos do Godot, referências de arte e a ficha/cópia do catálogo para revisão. O JSON ao lado do executável é uma referência; alterações nele não modificam o jogo exportado.
- Capturas de textos com os novos rótulos, dicas, leques, varredura, investida e recuperação inspecionadas em 960×540/1280×720. Encontro misto junto à parede capturado com avisos e perigos ativos; ainda precisa da avaliação humana de pressão e esquiva.
- Mantidas as quantidades, vida e dano dos inimigos anteriores. Não houve medição humana de duração, taxa de vitória ou dificuldade desta candidata; os testes de fluxo que eliminam inimigos por código não comprovam balanceamento. O alvo de 5–8 minutos continua em avaliação.
- Commits separados para D2, D3 e D4, com pushes. A candidata encerra a entrega técnica desta rodada, sem declarar D5 ou a revisão pedagógica concluídos.

Continuidade de D5:

- Manter as dezoito suítes (incluindo áudio, treino e sprites do estudante) e ampliar a cobertura somente para regras novas. Testes de combate devem simular avisos, esquivas e impactos; eliminar inimigos por código continua servindo apenas para testar progressão.
- Comparar as duas rotas com e sem recompensas. Registrar por partida a versão, rota, duração, sala final, perguntas repetidas/confusas e ataques difíceis de entender ou evitar. O alvo de 5–8 minutos continua uma hipótese de balanceamento.
- Usuário e Igor avaliam se perceberam mais variedade e se os inimigos ficaram mais interessantes e compreensíveis. Registrar ajustes e repetir os encontros afetados; participantes externos são uma ampliação opcional da avaliação.
- Atualizar este plano e o roteiro a cada ajuste, registrando motivo, validações e feedback. Fazer commits e pushes por etapa validada. A 0.3.0-rc6 substitui a rc5 como candidata para esta rodada; promover a versão somente após registrar os aceites correspondentes.

Ficam no backlog: novas disciplinas, Babuíno, loja, armas adicionais, geração procedural e histórico persistente. A preparação das pranchas antigas de personagens foi substituída pelo estudante sem nome próprio integrado em E6. Novos sistemas não são necessários para atender ao feedback atual.

### Histórico das expansões anteriores

Os registros datados abaixo descrevem o estado de cada entrega. Referências a playtest pendente em 19–22/10 são históricas; o aceite interno de 23/10 está registrado acima.

### Expansão autorizada em 22/10/2026 — arte e conteúdo

O usuário solicitou continuar a expansão e disponibilizou os pacotes em `art/`. Esta autorização substitui a orientação anterior de aguardar playtest antes de ampliar conteúdo. B5 continua aberto; os novos blocos não representam aceite humano.

| Bloco | Escopo | Situação |
| --- | --- | --- |
| C1 — arte selecionada | Analisar os pacotes, integrar sprites dos monstros existentes e registrar o que exige preparação | Concluído; dez suítes e inspeção visual aprovadas |
| C2 — conteúdo | Cacto e cientista, nova rota de encontros e cenários visuais a partir do material disponível | Concluído; onze suítes e capturas aprovadas |
| C3 — entrega | Testes de arte/perigos/rotas, inspeção visual, guia e nova build candidata | Concluído tecnicamente; 0.2.0-rc2 exportada, onze suítes aprovadas |

Entrega C1: coleção inventariada em [ART_ANALYSIS.md](ART_ANALYSIS.md); sprites dos quatro monstros existentes configurados, com cópias de produção e recursos reproduzíveis. Quadros isolados de efeitos foram excluídos das animações de corpo do cacto/cientista. Dez suítes passaram; escala, avisos e silhuetas inspecionados em capturas renderizadas. Os pacotes de jogador, HUD, armas e tiles são referências e precisam de preparação adicional. A música adicionada pela equipe foi preservada.

Entrega C2:

- Menu oferece a rota clássica e a expedição científica. Ambas preservam quatro salas, perguntas e recompensas; reinício mantém a rota escolhida e limpa os atributos. O menu permite trocar de rota.
- Expedição: dois dados na sala de aula; dado, cacto e nuvem no pátio; dado, centurião, cientista e nuvem no laboratório; Napoleão no ginásio. Nunca há mais de quatro inimigos simultâneos.
- Cacto: 35 de vida, imóvel, três espinhos a ±0,28 rad, aviso fixo de 0,95 s e recuperação de 1,6 s. Espinhos causam 8 de dano, viajam a 170 px/s por até 2,5 s e somem em colisão ou morte da fonte.
- Cientista: 35 de vida, aproximação a 55 px/s, marca um círculo de raio 42 px próximo à posição do jogador. A posição fica fixa; aviso de 1 s e área ativa por 1,2 s, com no máximo um acerto de 10 por mistura. Recuperação de 2,2 s. Marca limitada à arena, respeita invulnerabilidade e desaparece na morte da fonte/transições.
- Quatro pisos visuais reutilizados dos cenários individuais, com brilho reduzido e sem móveis decorativos usados como obstáculos falsos. Colisões e espaço seguro da entrada foram preservados.
- Onze suítes aprovadas: inclui a rota completa, avisos/esquiva, espinhos, área ativa, pausa, morte, reset e limpeza. Capturas do menu, dicas, quatro ambientes, ataques e escala em 960×540/1280×720 inspecionadas. Os testes de progressão eliminam inimigos por código; não medem dificuldade humana.

Entrega C3:

- Candidata 0.2.0-rc2 exportada em Godot 4.7.2, com sprites, cenários, músicas e catálogo embutidos. Inicialização standalone headless terminou com código 0; onze suítes passaram sem erros ou avisos. Registro local: `builds/validation-0.2.0-rc2.log`.
- Pacote Windows: `builds/SchoolRush-MVP-0.2.0-rc2-windows-x64.zip`, com executável, guia, roteiro de playtest, análise da arte, avisos do Godot e identificação do commit. Originais em `art/` não são necessários para executar a build.
- Guia e roteiro atualizados para as duas rotas. A clássica soma 425 de vida inimiga/44 golpes mínimos em alvo único sem bônus; a científica soma 435/46. Esses cálculos não substituem medição de dificuldade ou duração.
- Sprites do jogador, HUD, armas e efeitos permanecem pendentes de preparação das folhas de referência. Não houve playtest humano, revisão pedagógica nem validação em outro computador nesta entrega.

### Expansão 0.2 — blocos de execução

A expansão será entregue em blocos, preservando o ciclo de quatro salas. Os marcos M1–M5 abaixo registram a base 0.1.0.

| Bloco | Escopo | Situação |
| --- | --- | --- |
| B1 — vida do jogador | Barra com valor numérico, indicação de dano/cura/vida baixa, vida máxima independente e reset | Concluído; testes e inspeção visual aprovados |
| B2 — disciplinas | Ciências e Português, cinco questões por matéria, ofertas variadas e recompensas configuráveis | Concluído; vinte questões para Ensino Médio, sete suítes aprovadas |
| B3 — monstros | Nuvem com ataque à distância e centurião com golpe frontal anunciado; cenas preparadas para sprites | Concluído; oito suítes aprovadas, integração dos encontros em B4 |
| B4 — encontros | Apresentar inimigos gradualmente e misturar comportamentos nas salas | Concluído; nove suítes aprovadas |
| B5 — validação | Balanceamento, playtest e nova build da versão 0.2 completa | Entrega técnica sucedida pela 0.2.0-rc2; playtest interno aprovado em 23/10; acompanhamento pedagógico e de distribuição abaixo |

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

Entrega B4 (21/10/2026):

- Sala 1: dois dados. Sala 2: dois dados e uma nuvem. Sala 3: dois dados, uma nuvem e um centurião. Sala 4: Napoleão. Composições e dicas ficam em `room.gd`, mantendo quatro salas e no máximo quatro inimigos simultâneos.
- Feedback da pergunta apresenta como reconhecer e evitar a nova ameaça antes do combate. Spawns preservam distância mínima de 160 px da entrada.
- Telas de dicas e encontros da segunda e terceira salas inspecionadas em 960×540; texto e botão de entrada no combate cabem no painel.
- Nove suítes aprovadas. A nova integração verifica cenas corretas em cada sala, saída bloqueada com inimigos vivos, sequência completa após erros, limpeza de projéteis na conclusão/derrota/menu e reinício a partir da pausa.
- A verificação de fluxo derrota inimigos por código; comprova progressão sem recompensas, mas não substitui avaliação humana da dificuldade do combate.

B5 — preparação da candidata (21/10/2026):

- Balanceamento inicial mantém a primeira sala e o chefe. Vida total passa de 420 para 425; mínimo teórico de golpes sem bônus e em alvo único passa de 42 para 44. Isso controla o aumento de resistência, mas não mede o impacto dos novos ataques na dificuldade.
- No máximo uma nuvem e um centurião por sala. Avisos com direção fixa e recuperação dão oportunidade de esquiva e contra-ataque. Não houve ajuste baseado em jogadores, pois ainda não há resultados de playtest.
- [PLAYTEST.md](PLAYTEST.md) registra composição, parâmetros, roteiro para cinco pessoas/duas partidas, ficha de observação, revisão das vinte questões e critérios para promover a candidata à versão final.
- Versão 0.2.0-rc1 exportada com guia e roteiro de playtest. Nove suítes aprovadas sem falhas; catálogo, cenas dos novos monstros e projéteis incluídos no executável. Inicialização standalone headless concluída com código 0. Registro local em `builds/validation-0.2.0-rc1.log`; pacote em `builds/SchoolRush-MVP-0.2.0-rc1-windows-x64.zip`.
- Os testes automatizados comprovam regras e transições; as capturas comprovam a apresentação nos estados inspecionados. Nenhum deles comprova diversão, duração real ou aceite pedagógico. B5 permanece aberto até os aceites humanos do roteiro.

**Próxima etapa:** concluir a avaliação humana de D5 com a 0.3.0-rc6, incluindo o estudante animado, e ajustar questões e encontros apontados no retorno. A revisão de Igor acompanha os oitenta IDs de conteúdo. O personagem não terá nome próprio; seleção de outros personagens permanece fora do escopo.

Validar se alternar perguntas escolares e combate de ação cria uma partida divertida, compreensível e repetível. A entrega é uma partida completa para PC Windows, com início, progressão, derrota, reinício e vitória. Não basta demonstrar movimentação.

Na análise inicial, o repositório continha apenas movimentação e arena. O estado atualizado e as validações por etapa estão registrados no fim deste documento. O alvo técnico usado é Godot 4.7.2, com formas geométricas provisórias.

Na revisão inicial foram adicionados corrida com Shift, proteção contra registro duplicado dos controles e câmera fixa no centro da arena. A câmera antes seguia o jogador e deixava partes da sala fora da tela. O cache `.godot/` foi excluído do versionamento via `.gitignore`; arquivos `.gd.uid` devem ser mantidos. A exclusão de README já presente no diretório não foi revertida.

## Escopo da base e atualização da expansão

A tabela registra o recorte atual. B2 ampliou as disciplinas; B3/B4 adicionaram inimigos e encontros; C1/C2 integraram arte e uma rota opcional. Cada partida continua com quatro salas, sem sistemas de loja.

| Incluído no MVP | Adiado para depois da validação |
| --- | --- |
| Duas rotas à escolha, cada uma com três salas comuns e um chefe | Múltiplos andares e geração procedural |
| Pisos de sala de aula, pátio, laboratório e ginásio | Biblioteca e cenários completos com objetos/colisões próprios |
| Movimento, corrida sem stamina e régua de plástico | Lapiseira, níveis de arma, poderes e inventário |
| Dado, nuvem, centurião, cacto e cientista | Babuíno, NPC vendedor e loja |
| Napoleão com investida e varredura anunciadas | Fases adicionais, invocações e novos chefes |
| Matemática, História, Ciências e Português, vinte questões por matéria no projeto D1 | Outras matérias, puzzles e travessias especiais |
| Vida, sala atual, resultado da pergunta e recompensa no HUD | Pontuação competitiva e metaprogressão |
| Início, pausa, derrota, vitória e reinício | Save, narração e configurações avançadas |
| Sprites do estudante sem nome próprio, seis monstros, pisos selecionados e músicas da equipe | Outras armas, HUD e efeitos preparados |

Tempo-alvo de uma partida: 5–8 minutos, a confirmar com jogadores. Público definido: Ensino Médio. Igor deve revisar as oitenta questões quanto à correção e adequação antes do aceite pedagógico, usando a ficha por ID.

## Regras que removem as ambiguidades do GDD

1. Ao iniciar, oferecer duas perguntas de matérias diferentes, priorizando as menos apresentadas. Mostrar enunciado e recompensa antes da escolha. A pergunta escolhida abre quatro alternativas e admite uma única resposta.
2. Exibir resultado e explicação curta, com botão para continuar. Durante pergunta e feedback, o combate permanece bloqueado.
3. Acerto reserva uma recompensa; ela só é aplicada após eliminar todos os inimigos da sala. Matemática concede +2 de dano da régua; História recupera 20 de vida, limitada ao máximo; Ciências amplia o máximo em 10 e recupera 10; Português soma 5% da velocidade inicial, com limite acumulado de 20%. Exibir os valores na interface.
4. Erro mostra a resposta correta e não reserva bônus. O jogador ainda pode concluir a sala e avançar. Não retirar vida nem repetir a pergunta como punição.
5. A porta permanece fechada durante o combate. Ao limpar a sala, aplicar o bônus uma vez e permitir avançar com E perto da porta. Avançar abre a escolha da próxima sala; não usar transição automática por contato.
6. Repetir o fluxo antes das quatro salas, incluindo o chefe. Uma questão apresentada sai do conjunto da partida mesmo se não for escolhida: quatro salas consomem oito das oitenta questões. Reiniciar restaura os atributos e a disponibilidade da partida, preservando o histórico da sessão para priorizar inéditas; só fechar o jogo limpa esse histórico. Embaralhar alternativas preserva resposta correta e explicação.
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
| Nuvem | 25 de vida; tiro de 12 de dano a 230 px/s; mira fixa 0,8 s; recuperação 1,2 s |
| Centurião | 45 de vida; golpe de 18 de dano até 105 px; aviso 0,75 s; recuperação 1,1 s |
| Salas comuns | 2 dados; 2 dados + nuvem; 2 dados + nuvem + centurião; spawns a pelo menos 160 px da entrada |
| Napoleão | 150 de vida; investida de 20 de dano |
| Ciclo do chefe | Mira fixa com aviso de 0,8 s, investida de até 0,5 s a 420 px/s, recuperação de 1,2 s |

A investida de Napoleão termina ao atingir parede; não reposiciona a mira durante o aviso. Na versão atual, o chefe não invoca inimigos nem dispara projéteis; nuvem e cacto usam projéteis. Na sala liberada e nas interfaces não ocorre dano. Ataques de régua e centurião têm área frontal, para que posicionamento seja relevante. Na fase D, comparar duração e dificuldade com a base aprovada.

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

Caminho crítico da base: movimento → combate → perguntas/recompensas → salas → chefe/finais → exportação. Caminho atual: D1 → D2 → D3 → D4 → D5, com o playtest interno da base aprovado em 23/10. As janelas M0–M5 acima pertencem ao planejamento inicial; a nova fase será acompanhada por entregas, sem novas datas prometidas.

## Verificação e definição de pronto

Por marco, executar importação headless e abertura da cena no editor. Headless detecta erros de scripts/recursos, mas não comprova sensação de combate, visibilidade ou usabilidade.

Checklist manual obrigatório da entrega:

- WASD/setas e Shift funcionam; diagonal não é mais rápida; paredes seguram o jogador mesmo correndo.
- Um golpe não causa múltiplos danos no mesmo inimigo; contato respeita invulnerabilidade; inimigos mortos param de atacar.
- Todas as questões têm quatro alternativas, índice correto válido e explicação revisada; escolher/responder repetidamente não duplica eventos.
- Acerto aplica um bônus após a sala; erro aplica zero; cura não excede o máximo atual; morte antes de limpar cancela bônus. Ciências amplia o limite e Português respeita o teto de velocidade.
- A porta só abre sem inimigos; interagir repetidamente não pula salas; chefe só aparece na quarta sala.
- Pausar interrompe movimento, dano e temporizadores; retomar não deixa o jogo congelado.
- Vitória/derrota bloqueiam combate; reiniciar três vezes não mantém bônus ou inimigos anteriores. Histórico de perguntas persiste intencionalmente na sessão, sem impedir novas ofertas.
- Redimensionar a janela preserva HUD e alternativas; texto é legível; feedback de acerto/erro usa texto além de cor.
- Build Windows abre numa máquina sem Godot e completa uma partida sem erro bloqueante.

Automatizar, quando esses sistemas existirem, os testes de consumo único de recompensa, seleção sem repetição e reset de partida. Evitar testes que apenas reproduzam os valores escritos no código.

Rodada externa complementar proposta: cinco pessoas, duas partidas cada. Registrar tempo, salas alcançadas, mortes, acertos e dúvidas, sem telemetria obrigatória. Meta de observação: pelo menos quatro entendem a relação pergunta → combate → bônus sem explicação verbal. Esse protocolo não invalida o aceite interno nem bloqueia a fase D. Investigar derrotas recorrentes antes da segunda sala e ataques percebidos como inevitáveis; não exigir que todos vençam na primeira tentativa.

## Riscos e decisões de corte

- Escopo: seis inimigos, quatro cenários, duas armas e loja comprometem a entrega. Manter apenas o conjunto incluído neste documento.
- Conteúdo: D1 ampliou para vinte questões por matéria e D2 reduz repetição entre partidas. Revisar correção, dificuldade e variedade percebida no próximo playtest.
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

### Aceites e acompanhamento após o playtest de 23/10/2026

| Item | Responsável | Situação / evidência esperada |
| --- | --- | --- |
| Playtest interno da base | Usuário + Igor | Aprovado conforme relato do usuário em 23/10; base aceita para evolução |
| Ampliar variedade e melhorar combate | Moisés + Igor | Solicitado no retorno do playtest; entregas e critérios D1–D5 |
| Revisar questões atuais e novas para Ensino Médio | Igor | Revisão por ID ainda não confirmada; acompanhar os lotes do D1 |
| Medir duração, repetições e dificuldade | Equipe | Coletar na próxima rodada; relato atual não contém métricas |
| Detalhar avaliação de áudio e controles | Matheus + equipe | Registrar na próxima rodada; não houve resultado individual por item |
| Testar a pasta exportada em outro PC sem Godot | Equipe | Execução externa não confirmada; verificar vitória, derrota e reinício na próxima entrega |
| Ampliar avaliação com participantes externos | Equipe | Rodada complementar opcional, conforme disponibilidade |

O aceite interno da base autorizou a evolução. A 0.3.0-rc6 está preparada para uma nova rodada; sua promoção a versão final deve registrar revisão pedagógica, retorno do combate e validação de distribuição, sem presumir que o relato anterior confirmou os novos comportamentos.

### Histórico de versionamento

Trabalho na branch existente `master`, com pushes para `origin/master` após cada etapa validada:

- `c26ebc9`: plano e base inicial.
- `c2a2a84`: M1 — combate, inimigos, vida e reinício.
- `43fa130`: M2/M3 — perguntas, bônus e três salas.
- `8e9fdea`: M4 — Napoleão, pausa e partida completa.
- `9e6a086`: M5 — áudio, exportação, verificações e plano atualizado.
- `aed10a2`: B1 — barra de vida, limite máximo e versão 0.1.1.
- `a400b8a`: B2 — disciplinas de Ensino Médio, catálogo, recompensas e versão 0.1.2.
- `1b35dc4`: B3 — monstros com avisos, projéteis e cenas preparadas para sprites.
- `6339c21`: B4 — encontros progressivos e dicas por sala.
- B5: preparação da versão 0.2.0-rc1, roteiro de playtest e exportação (consultar `git log` para o hash desta entrega).
- `8525cdf`: C1 — sprites de monstros, recursos reproduzíveis e análise dos pacotes de arte.
- `be2482c`: C2 — expedição científica, cacto, cientista, quatro pisos e testes.
- `f87f4d4`: C3 — versão 0.2.0-rc2, roteiro de duas rotas e pacote Windows.
- `ca8e59b`: aceite interno registrado e fase D1–D5 planejada.
- `08caf92`: D1 — oitenta questões, dificuldade, revisão por ID, testes e capturas; projeto 0.3.0-dev1.
- `bc8daed`: D2 — histórico na sessão, preferências de tema/dificuldade e alternativas embaralhadas.
- `9925a60`: D3 — separação, reposicionamento, recuperação visível e leques do cacto.
- `8c14cf9`: D4 — coordenação de ataques especiais e varredura do Napoleão.
- D5 técnico: candidata 0.3.0-rc1, guia, roteiro e pacote para a próxima rodada (consultar `git log` para o hash).
- E1: resumo, revisão de respostas e relatório local opcional; candidata 0.3.0-rc2 (consultar `git log` para o hash).
- E2/E3: dificuldade por sala, cinco questões revisadas e acertos por nível; candidata 0.3.0-rc3 (consultar `git log` para o hash).
- E4: volumes independentes no menu/pausa e preferências locais; candidata 0.3.0-rc4 (consultar `git log` para o hash).
- E5: treino opcional de movimento, corrida, régua e saída; candidata 0.3.0-rc5 (consultar `git log` para o hash).
- E6: estudante sem nome próprio, animações de caminhada/régua fornecidas e documentação revisada; candidata 0.3.0-rc6 (consultar `git log` para o hash).
