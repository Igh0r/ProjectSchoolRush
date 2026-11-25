# Validação para apresentação — 25/11/2026

Apresentação prevista: 26/11/2026. Código atualizado com `git pull --ff-only`, de c6379a4 para cfde523. Versão interna mantida em 0.3.0-rc6. Novidades recebidas: imagens e músicas de vitória/derrota.

## Resultado

- 18 suítes automatizadas aprovadas, sem falhas, incluindo perguntas, progressão, combate, duas rotas, treino, áudio e sprites.
- Executável Windows x64 reexportado; inicialização headless concluída com código zero.
- Executável iniciado com renderização OpenGL na RTX 3060, sem erros nos logs observados.
- Verificação gráfica por script no projeto: menu, treino, combate, pausa, vitória nas duas rotas, revisão e derrota. Os combates desse roteiro são encerrados programaticamente; não equivalem a uma partida humana.
- Capturas de vitória e derrota inspecionadas. A imagem de vitória ocupa a primeira área do painel em 960×540; rolar para acessar resumo e botões.
- Controle interativo da janela não concluído: autorização da ferramenta expirou. Audição, projetor e computador das escolas não foram validados nesta sessão.

A primeira importação encerrou com código de falha sem diagnóstico; a repetição completa passou. O template de distribuição não aceita `--path` e não executou o roteiro externo; por isso o roteiro gráfico foi realizado no projeto, separado do teste de inicialização do executável.

## Evidências locais

- `builds/validation-presentation-2026-11-25-retry.log`
- `builds/standalone-smoke.log` e `builds/standalone-smoke-errors.log`
- `builds/presentation-native.log` e `builds/presentation-native-errors.log`
- `builds/presentation-source.log` e `builds/presentation-source-errors.log` (o rótulo PACKAGED GAME deste roteiro refere-se aos fluxos; esta execução foi no projeto)
- `builds/previews/presentation-*.png`

## Para levar

Extrair todo o ZIP `SchoolRush-apresentacao-2026-11-26-windows-x64.zip` e abrir `SchoolRush.exe`. O jogo funciona sem Godot instalado e sem conexão à internet. Antes da apresentação, abrir no computador que será usado, conferir som/projeção e experimentar Treinar controles. Nas telas finais, usar a roda do mouse ou Tab para acessar os botões abaixo da imagem.

O usuário já informou que o playtest foi validado. Esse aceite não substitui revisão pedagógica por ID ou confirmação em outro computador, ainda não informadas.
