# Casos de uso

Ator principal: **Responsável pelo acervo**, a pessoa que opera o sistema local. Esse ator representa um papel de uso; não existe cadastro de usuário nem autenticação. O [diagrama UML](../diagramas/casos-de-uso.png) associa o ator às cinco operações dentro do limite do sistema, sem relações include/extend artificiais.

## CU01 — Cadastrar livro · RF01

- **Ator:** responsável pelo acervo.
- **Objetivo:** incluir título e quantidade inicial com rastreabilidade.
- **Pré-condições:** sistema acessível, banco com estrutura importada, pelo menos uma categoria existente e formulário obtido na sessão atual.
- **Fluxo principal:** 1. abrir Cadastrar livro; 2. informar título, autor, categoria, ISBN se disponível, preço e estoque inicial; 3. enviar; 4. ação valida POST/CSRF e entradas; 5. serviço valida dados e categoria; 6. transação insere o livro com saldo zero e, se necessário, atualiza o saldo e grava entrada inicial; 7. commit; 8. catálogo apresenta mensagem de sucesso.
- **Alternativas:** campos inválidos retornam ao cadastro com mensagem e valores conhecidos; ausência de categoria desabilita o formulário; CSRF inválido retorna 403 e método indevido 405; erro técnico retorna mensagem genérica e reverte a transação quando iniciada.
- **Pós-condições:** um livro foi persistido; estoque positivo tem movimento inicial correspondente. Em falha transacional, não há cadastro parcial.
- **Referências:** [novo-livro.php](../../public/novo-livro.php), [salvar-livro.php](../../public/actions/salvar-livro.php), [AcervoService.php](../../src/AcervoService.php).

## CU02 — Consultar e pesquisar livros · RF02

- **Ator:** responsável pelo acervo.
- **Objetivo:** localizar livros e conhecer sua disponibilidade.
- **Pré-condições:** sistema e banco disponíveis; catálogo pode estar vazio.
- **Fluxo principal:** 1. abrir Catálogo; 2. opcionalmente preencher título, autor ou ISBN e clicar Pesquisar; 3. página valida o tamanho da busca; 4. consulta parametrizada combina livros e categorias; 5. renderiza os dados escapados e o resumo dos resultados; 6. ator acessa edição ou movimentação se desejar.
- **Alternativas:** termo sem correspondência apresenta estado vazio; Limpar pesquisa restaura todos os livros; busca acima de 200 caracteres apresenta validação; banco indisponível apresenta erro genérico e HTTP 503.
- **Pós-condições:** nenhum registro foi alterado; resultados refletem o banco no momento da consulta.
- **Referências:** [index.php](../../public/index.php), [Livro::listar](../../src/Livro.php).

## CU03 — Editar livro · RF03

- **Ator:** responsável pelo acervo.
- **Objetivo:** corrigir os dados cadastrais mantendo o controle de estoque pelo histórico.
- **Pré-condições:** livro existente, categorias disponíveis e formulário com token da sessão.
- **Fluxo principal:** 1. escolher Editar no catálogo; 2. conferir o saldo somente leitura; 3. alterar dados cadastrais; 4. enviar; 5. ação valida POST/CSRF, ID e extrai apenas campos conhecidos; 6. serviço valida dados e existência do livro; 7. UPDATE altera cadastro e data de atualização; 8. redirecionamento ao catálogo com sucesso.
- **Alternativas:** livro inexistente na página retorna 404; dados inválidos voltam à edição com mensagem; ID inválido na ação volta ao catálogo; erro técnico produz mensagem genérica. Campo `estoque` acrescentado artificialmente ao POST não integra os dados persistidos.
- **Pós-condições:** cadastro atualizado, saldo e movimentações preservados; última edição cadastral prevalece em gravações concorrentes.
- **Referências:** [editar-livro.php](../../public/editar-livro.php), [atualizar-livro.php](../../public/actions/atualizar-livro.php), [Livro::atualizar](../../src/Livro.php).

## CU04 — Registrar movimentação · RF04

- **Ator:** responsável pelo acervo.
- **Objetivo:** acrescentar ou retirar exemplares sem saldo negativo.
- **Pré-condições:** livro existente e formulário válido na sessão; para saída, saldo suficiente no momento do bloqueio.
- **Fluxo principal:** 1. selecionar livro e tipo; 2. informar quantidade e observação opcional; 3. enviar; 4. ação valida POST/CSRF e inteiros; 5. serviço valida tipo, quantidade e observação; 6. inicia transação; 7. repositório consulta livro com `FOR UPDATE`; 8. serviço verifica saldo e limite do INT; 9. atualiza estoque; 10. insere histórico; 11. commit; 12. ação registra mensagem e redireciona ao histórico filtrado.
- **Alternativas:** quantidade inválida falha antes da transação; livro ausente, saída superior ao saldo e overflow geram exceção e rollback dentro da transação; falha técnica também reverte as duas gravações; ação preserva campos e redireciona com mensagem. Método e CSRF indevidos encerram a ação com 405/403.
- **Pós-condições:** saldo e um novo movimento confirmados juntos ou ambos preservados. Operações concorrentes no mesmo livro aguardam o bloqueio.
- **Referências:** [movimentacoes.php](../../public/movimentacoes.php), [registrar-movimentacao.php](../../public/actions/registrar-movimentacao.php), [sequência](../diagramas/sequencia.png).

## CU05 — Consultar histórico · RF05

- **Ator:** responsável pelo acervo.
- **Objetivo:** acompanhar quando e como as quantidades foram alteradas.
- **Pré-condições:** banco disponível; pode não haver movimentos.
- **Fluxo principal:** 1. abrir Movimentações; 2. consultar todos os movimentos ou selecionar livro e Filtrar; 3. página valida o ID quando informado; 4. consulta combina movimentos e título do livro; 5. exibe data, tipo, quantidade e observação em ordem decrescente por data/ID.
- **Alternativas:** ausência de movimentos informa estado vazio; Ver todos os livros remove o filtro; livro inexistente retorna 404; falha técnica retorna 503 e mensagem genérica.
- **Pós-condições:** leitura do histórico sem alteração de dados.
- **Referências:** [movimentacoes.php](../../public/movimentacoes.php), [Movimentacao::listar](../../src/Movimentacao.php).
