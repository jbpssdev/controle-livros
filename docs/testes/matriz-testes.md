# Matriz de testes do projeto integrado

Esta matriz complementa o [plano original](../../tests/plano-testes.md), sem substituí-lo. **Os CTs abaixo são identificadores locais desta matriz**. O CT07 original trata saída/quantidades; o CT08 original trata edição. Aqui, CT07 é edição e CT08 é histórico, conforme a tarefa documental. A correspondência está registrada em cada caso para evitar troca de evidências.

Preparação comum: usar uma instalação de estudo identificada, com estrutura importada, categoria disponível e navegador. Dados sugeridos abaixo são **entradas planejadas para teste**, não registros existentes nem resultados. Anotar data, versões, operador e base utilizada no momento da execução. Nunca executar falhas induzidas no acervo de uso real. Resultado obtido e evidência correspondente permanecem em branco; status inicial é pendente, sem aprovação presumida.

## CT01 — Cadastro válido

- **Requisito:** RF01 / RNF02 / RNF03.
- **Objetivo:** persistir cadastro com entrada inicial coerente.
- **Pré-condições:** categorias disponíveis; título de ensaio ainda não cadastrado.
- **Dados de entrada:** título `CT01 — Livro de ensaio`, autor `Pessoa de teste`, categoria existente, ISBN `CT-01`, preço `25,90`, estoque inicial `3`.
- **Procedimento:** abrir cadastro, preencher e enviar; conferir catálogo e histórico filtrado pelo livro.
- **Resultado esperado:** mensagem de sucesso; um livro com preço 25,90 e saldo 3; uma entrada inicial de 3; recarga do GET não repete o cadastro.
- **Correspondência no plano original:** CT01.
- **Evidência planejada:** `05-cadastro-sucesso.png`; complementar com histórico do mesmo livro.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT02 — Cadastro sem título

- **Requisito:** RF01 / RNF02 / RNF03.
- **Objetivo:** verificar obrigatoriedade no navegador e no servidor.
- **Pré-condições:** formulário aberto, sessão e token válidos.
- **Dados de entrada:** dados válidos de CT01 com título vazio ou somente espaços.
- **Procedimento:** tentar envio vazio; depois, em banco de estudo, enviar POST válido de sessão removendo a validação HTML pelo inspetor para atingir a validação do servidor.
- **Resultado esperado:** navegador informa campo obrigatório; servidor rejeita título vazio; demais valores conhecidos são preservados; nenhum livro ou movimento novo.
- **Correspondência no plano original:** CT02.
- **Evidência planejada:** `08-validacao-cadastro.png`, identificando se é validação do navegador ou servidor.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT03 — Pesquisa de livro existente

- **Requisito:** RF02 / RNF01.
- **Objetivo:** localizar por título, autor e ISBN.
- **Pré-condições:** CT01 executado ou livro de estudo conhecido.
- **Dados de entrada:** parte do título; depois autor e ISBN do mesmo livro.
- **Procedimento:** pesquisar separadamente cada termo e conferir os dados retornados.
- **Resultado esperado:** correspondências corretas, categoria/preço/saldo do banco; resumo referente somente aos resultados. Não exigir resultado único quando autor é compartilhado.
- **Correspondência no plano original:** CT03.
- **Evidência planejada:** `06-pesquisa-existente.png`.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT04 — Pesquisa inexistente

- **Requisito:** RF02 / RNF03.
- **Objetivo:** apresentar estado vazio claro.
- **Pré-condições:** catálogo disponível.
- **Dados de entrada:** termo comprovadamente ausente, por exemplo `sem-correspondencia-ct04`.
- **Procedimento:** pesquisar; usar Limpar pesquisa ou Ver todos os livros.
- **Resultado esperado:** “Nenhum livro encontrado”, sem dados fictícios; retorno ao catálogo completo quando limpo o filtro.
- **Correspondência no plano original:** CT04.
- **Evidência planejada:** `07-pesquisa-inexistente.png`.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT05 — Entrada de estoque

- **Requisito:** RF04 / RF05 / RNF05.
- **Objetivo:** aumentar saldo e registrar um movimento.
- **Pré-condições:** livro com saldo conhecido, idealmente 3 do CT01.
- **Dados de entrada:** entrada, quantidade `2`, observação `CT05 — Entrada de ensaio`.
- **Procedimento:** acessar Movimentar pelo livro, registrar e conferir catálogo/histórico; recarregar a página.
- **Resultado esperado:** saldo anterior + 2 (5 se o saldo inicial era 3); uma nova entrada com quantidade/observação corretas; sem repetição pela recarga do GET.
- **Correspondência no plano original:** CT05.
- **Evidência planejada:** `09-entrada-estoque.png`.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT06 — Retirada acima do estoque

- **Requisito:** RF04 / RNF02 / RNF03 / RNF05.
- **Objetivo:** impedir saldo negativo sem histórico parcial.
- **Pré-condições:** conhecer o saldo S e contar os movimentos antes do envio.
- **Dados de entrada:** saída, quantidade `S + 1` (6 se S = 5), observação de ensaio.
- **Procedimento:** tentar registrar; conferir mensagem, saldo e histórico.
- **Resultado esperado:** mensagem de estoque insuficiente; saldo inalterado; nenhuma saída inserida; campos conhecidos preservados.
- **Correspondência no plano original:** CT06.
- **Evidência planejada:** `10-saida-bloqueada.png`.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT07 — Edição válida

- **Requisito:** RF03 / RNF02.
- **Objetivo:** atualizar cadastro sem alterar estoque/histórico.
- **Pré-condições:** livro existente; anotar saldo e quantidade de movimentos.
- **Dados de entrada:** novo título, autor, categoria, ISBN e preço válidos. Em subteste de servidor, acrescentar `estoque=999` ao POST com token válido.
- **Procedimento:** editar e salvar; conferir o catálogo e histórico. Realizar o subteste somente em livro de estudo.
- **Resultado esperado:** dados atualizados, saldo e histórico iguais aos anteriores; estoque não é um campo editável e o campo extra no POST não é persistido.
- **Correspondência no plano original:** CT08 (numeração diferente).
- **Evidência planejada:** `03-edicao.png`, com registro adicional do resultado se necessário.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT08 — Consulta do histórico

- **Requisito:** RF05 / RNF01.
- **Objetivo:** conferir ordenação e filtro por livro.
- **Pré-condições:** pelo menos dois livros de estudo, um com movimentos; registrar quais IDs foram utilizados.
- **Dados de entrada:** seleção de um livro no filtro; depois Todos os livros.
- **Procedimento:** abrir Movimentações, filtrar, comparar registros e remover o filtro; conferir também um livro sem movimentos, se disponível.
- **Resultado esperado:** data/hora, livro, tipo, quantidade e observação corretos; ordem decrescente por data e ID; filtro restringe apenas ao livro selecionado; estado vazio quando não há registros.
- **Correspondência no plano original:** cenário complementar; amplia a consulta prevista em CT01 e CT05.
- **Evidência planejada:** `04-movimentacoes.png` e `12-banco-movimentacoes.png` para comparação de leitura.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT09 — Quantidades inválidas e saída total

- **Requisito:** RF04 / RNF02.
- **Objetivo:** conferir quantidade inteira positiva e limite do saldo.
- **Pré-condições:** livro de estudo com saldo conhecido.
- **Dados de entrada:** `0`, `-1`, `1,5`, texto, `2147483648`; depois saída exatamente igual ao saldo.
- **Procedimento:** submeter cada valor inválido com token válido, inclusive pelo inspetor quando a validação HTML bloquear; por último retirar exatamente o saldo.
- **Resultado esperado:** entradas inválidas não alteram saldo/histórico; saída total válida deixa zero e gera uma saída; retirada posterior de 1 é rejeitada.
- **Correspondência no plano original:** CT07.
- **Evidência planejada:** capturas complementares nomeadas com CT09, sem substituir as 12 capturas-base.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT10 — Método, CSRF, SQL Injection e XSS

- **Requisito:** RF01 / RF02 / RF04 / RNF02.
- **Objetivo:** verificar rejeição de gravação indevida e tratamento textual das entradas.
- **Pré-condições:** sessão e instalação exclusivamente de estudo.
- **Dados de entrada:** GET às ações, POST sem token/token incorreto; busca `' OR 1=1 --`; título de teste contendo marcação HTML.
- **Procedimento:** executar cada tentativa isoladamente; conferir status HTTP e ausência de gravação nas requisições indevidas; com token válido, conferir que marcação cadastrada aparece literalmente.
- **Resultado esperado:** 405/403 conforme método/token; termo não altera a consulta; HTML armazenado não executa script no catálogo, edição ou histórico. Não é uma auditoria de segurança completa.
- **Correspondência no plano original:** CT09.
- **Evidência planejada:** capturas complementares de CT10 com dados particulares ocultados.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT11 — Saídas concorrentes

- **Requisito:** RF04 / RNF05.
- **Objetivo:** impedir duas retiradas do mesmo último exemplar.
- **Pré-condições:** Apache com concorrência real, duas sessões independentes, livro de estudo com saldo 1.
- **Dados de entrada:** duas saídas de 1 para o mesmo livro, cada uma com token da própria sessão.
- **Procedimento:** enviar simultaneamente; comparar mensagens, saldo e histórico. O servidor PHP de um único processo não comprova concorrência HTTP.
- **Resultado esperado:** somente uma saída confirmada; a outra consulta saldo zero após obter o bloqueio e é rejeitada; saldo final 0 e uma saída.
- **Correspondência no plano original:** CT10.
- **Evidência planejada:** par de capturas com identificação das sessões e leitura do histórico.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT12 — Atomicidade em falha

- **Requisito:** RF01 / RF04 / RNF05.
- **Objetivo:** comprovar rollback quando a inserção do histórico falha.
- **Pré-condições:** banco **descartável separado**, nunca o acervo existente; planejamento e reversão da falha pelo responsável.
- **Dados de entrada:** cadastro com estoque positivo e entrada em livro de teste, sob falha controlada no INSERT do histórico.
- **Procedimento:** induzir falha somente no banco descartável; tentar ambas as operações; comparar contagens/saldos antes e depois; desfazer a condição de falha no mesmo ambiente.
- **Resultado esperado:** nem cadastro parcial nem atualização parcial de saldo; nenhuma nova movimentação confirmada; erro técnico apresentado genericamente.
- **Correspondência no plano original:** CT11.
- **Evidência planejada:** registros de antes/depois e identificação do ambiente descartável, sem dados reais.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT13 — Dados demonstrativos idempotentes

- **Requisito:** RF01 / RF04 / RNF04.
- **Objetivo:** conferir repetição controlada do SQL opcional.
- **Pré-condições:** banco de estudo vazio, com a estrutura; nenhuma operação simultânea.
- **Dados de entrada:** `sql/exemplos.sql`.
- **Procedimento:** importar duas vezes; conferir os três títulos; movimentar um demonstrativo e importar uma terceira vez.
- **Resultado esperado:** três livros demonstrativos, sem duplicação de entradas iniciais ou redefinição de saldos já movimentados. Não importar no acervo real para produzir evidência artificial.
- **Correspondência no plano original:** CT12.
- **Evidência planejada:** comparação de contagens e saldos no ambiente de estudo.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT14 — Diagnóstico e falha de conexão

- **Requisito:** RNF03 / RNF04.
- **Objetivo:** conferir diagnóstico sem divulgação de credenciais.
- **Pré-condições:** ambiente de estudo em que parar o banco não interrompa outros projetos; preferir instância isolada.
- **Dados de entrada:** acesso a `tests/check-env.php`, páginas válidas e ID inexistente.
- **Procedimento:** executar diagnóstico com conexão disponível; verificar ID inexistente; em ambiente isolado, interromper a conexão e repetir páginas/diagnóstico.
- **Resultado esperado:** diagnóstico informa o estado real; ID ausente retorna 404; falha técnica nas páginas retorna 503 com mensagem genérica. Pelo terminal, diagnóstico retorna 0/1 conforme disponibilidade.
- **Correspondência no plano original:** parte de CT13; diagnóstico também é roteiro do README.
- **Evidência planejada:** registro textual do diagnóstico sem configuração privada.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**

## CT15 — Responsividade, teclado e operação offline

- **Requisito:** RNF01 / RNF04.
- **Objetivo:** conferir operação das quatro páginas em diferentes condições de uso.
- **Pré-condições:** instalação XAMPP; internet pode ser desligada sem interromper localhost.
- **Dados de entrada:** largura de 360 px e desktop, teclado, navegador sem JS.
- **Procedimento:** navegar com Tab, usar link de salto, pesquisar e preencher formulários; conferir rótulos/foco e rolagem das tabelas; repetir offline e sem JS.
- **Resultado esperado:** operações essenciais continuam utilizáveis, sem recursos remotos obrigatórios; sem sobreposição de campos; foco perceptível e mensagens disponíveis. Registrar limitações encontradas; não inferir conformidade WCAG completa.
- **Correspondência no plano original:** CT13.
- **Evidência planejada:** capturas complementares de desktop/celular e observações do operador.
- **Resultado obtido:**
- **Status:** Pendente de execução manual.
- **Evidência correspondente:**
