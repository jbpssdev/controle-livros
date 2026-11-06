# Plano de testes — Controle de Livros Usados

Execute em uma instalação de estudo com `estrutura.sql` importado, Apache e MariaDB iniciados. Use dados próprios de teste. O SQL de demonstração é opcional. Os campos de resultado e evidência ficam vazios para preenchimento pelo estudante após execução real. Uma evidência pode ser salva em `docs/evidencias/`.

## CT01 — Cadastro válido

- Condições: categoria disponível; título de teste ainda não cadastrado.
- Procedimento: abrir Cadastrar livro; preencher título, autor, categoria, preço `25,90` e estoque inicial `3`; enviar.
- Resultado esperado: redirecionamento ao catálogo com sucesso; livro com 3 exemplares; histórico com uma entrada inicial de 3.
- Resultado obtido:
- Evidência:

## CT02 — Cadastro sem título

- Condições: formulário de cadastro aberto.
- Procedimento: preencher os demais campos e deixar título vazio; enviar. Repetir enviando o POST sem título pelo inspetor, com token CSRF válido, para verificar também o servidor.
- Resultado esperado: navegador indica campo obrigatório; servidor rejeita a requisição manipulada com mensagem clara; nenhum livro ou movimento gravado; outros valores preservados.
- Resultado obtido:
- Evidência:

## CT03 — Pesquisa de livro existente

- Condições: livro do CT01 cadastrado.
- Procedimento: pesquisar uma parte do título; repetir com autor e ISBN, se preenchido.
- Resultado esperado: livro correspondente, categoria, preço e quantidade corretos; resumo referente aos resultados.
- Resultado obtido:
- Evidência:

## CT04 — Pesquisa de livro inexistente

- Condições: catálogo disponível.
- Procedimento: buscar um texto que não corresponda a nenhum título, autor ou ISBN.
- Resultado esperado: mensagem “Nenhum livro encontrado”; opção para ver todos os livros; nenhum registro fictício.
- Resultado obtido:
- Evidência:

## CT05 — Entrada de exemplares

- Condições: livro com 3 exemplares.
- Procedimento: abrir Movimentar pelo catálogo, selecionar Entrada, informar 2 e uma observação; registrar; recarregar a página.
- Resultado esperado: estoque 5; exatamente uma entrada adicional de 2 com data e observação; recarregar não repete o POST.
- Resultado obtido:
- Evidência:

## CT06 — Saída superior ao estoque disponível

- Condições: livro com 5 exemplares.
- Procedimento: tentar registrar saída de 6.
- Resultado esperado: mensagem de estoque insuficiente; saldo permanece 5; nenhuma saída registrada; campos preservados.
- Resultado obtido:
- Evidência:

## CT07 — Saída válida, zero e valores inválidos

- Condições: livro com 5 exemplares.
- Procedimento: retirar 5; depois tentar saída de 1. Tentar quantidade zero, negativa, fracionária, texto e superior a 2147483647 manipulando o POST com token válido.
- Resultado esperado: primeira saída deixa saldo 0 e gera um movimento; demais operações rejeitadas sem alteração do saldo ou histórico.
- Resultado obtido:
- Evidência:

## CT08 — Edição sem alteração de estoque

- Condições: livro e movimentações existentes.
- Procedimento: editar título, autor, categoria, ISBN e preço. Acrescentar `estoque=999` ao POST com token válido.
- Resultado esperado: dados cadastrais atualizados; estoque e histórico preservados; edição não oferece campo de estoque editável.
- Resultado obtido:
- Evidência:

## CT09 — CSRF, métodos, SQL Injection e XSS

- Condições: sessão de navegador válida.
- Procedimento: chamar ações por GET; enviar POST sem token e com token incorreto; pesquisar `' OR 1=1 --`; cadastrar título `<script>alert(1)</script>` com token válido e demais campos corretos.
- Resultado esperado: GET retorna 405, POST sem token ou com token inválido retorna 403; nenhum desses pedidos grava; pesquisa tratada como texto; título renderizado literalmente sem executar JavaScript em catálogo, edição e histórico.
- Resultado obtido:
- Evidência:

## CT10 — Duas saídas concorrentes

- Condições: livro com 1 exemplar; dois navegadores/sessões independentes com formulários válidos. Para concorrência real usar Apache do XAMPP, não o servidor PHP de desenvolvimento de um único processo.
- Procedimento: enviar ao mesmo tempo duas saídas de 1 para o mesmo livro.
- Resultado esperado: apenas uma saída confirmada; outra rejeitada por falta de estoque após aguardar o bloqueio; saldo 0; uma única saída no histórico.
- Resultado obtido:
- Evidência:

## CT11 — Atomicidade diante de falha

- Condições: banco descartável separado, nunca um acervo com dados importantes.
- Procedimento: em ambiente de teste, provocar falha na inserção do histórico (por exemplo, trigger temporária que execute SIGNAL) e tentar uma entrada; remover a condição de falha após o teste.
- Resultado esperado: operação rejeitada; atualização de estoque revertida pelo rollback; nenhum histórico parcial. Repetir no cadastro com estoque inicial para verificar reversão do próprio cadastro.
- Resultado obtido:
- Evidência:

## CT12 — SQL de demonstração e coerência

- Condições: banco de estudo vazio com estrutura importada.
- Procedimento: importar exemplos.sql duas vezes; conferir quantidades; movimentar um livro demonstrativo e importar novamente.
- Resultado esperado: 3 livros demonstrativos; 2 entradas iniciais; nenhuma duplicação; saldos posteriores preservados. Para cada livro, estoque corresponde à soma de entradas menos saídas.
- Resultado obtido:
- Evidência:

## CT13 — Responsividade, teclado e funcionamento offline

- Condições: Bootstrap local presente; sistema carregado no XAMPP.
- Procedimento: testar largura de 360px e desktop; navegar com Tab; pesquisar, cadastrar e movimentar sem internet e com JavaScript desabilitado; acessar edição com ID inexistente e parar o MariaDB para verificar tratamento de erro.
- Resultado esperado: navegação e formulários utilizáveis; foco visível; tabelas com rolagem horizontal; dados e controles acessíveis; mensagens adequadas para livro inexistente e indisponibilidade do banco, sem credenciais ou SQL.
- Resultado obtido:
- Evidência:
