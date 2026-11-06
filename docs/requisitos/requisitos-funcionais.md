# Requisitos funcionais

Fonte: código do projeto, especialmente [AcervoService.php](../../src/AcervoService.php), [Livro.php](../../src/Livro.php), [Movimentacao.php](../../src/Movimentacao.php) e [estrutura.sql](../../sql/estrutura.sql). Os requisitos abaixo descrevem funcionalidades implementadas; sua aceitação manual deve ser registrada na [matriz de testes](../testes/matriz-testes.md).

## RF01 — Cadastrar livros

- **Descrição:** registrar os dados cadastrais e o estoque inicial de um livro em uma categoria existente.
- **Entradas:** título (até 200 caracteres), autor (150), categoria válida, ISBN opcional (20), preço não negativo com até duas casas, estoque inicial inteiro entre 0 e 2147483647 e token CSRF.
- **Resultado esperado:** livro persistido e mensagem de sucesso após redirecionamento ao catálogo. Estoque inicial positivo gera uma entrada identificada como estoque inicial; livro, saldo e movimento são confirmados na mesma transação. Estoque zero não gera movimento.
- **Alternativas:** falta de título/autor, categoria inexistente, preço inválido ou quantidade fora do limite rejeitam a gravação. Falha na persistência reverte a transação. Campos conhecidos são preservados na sessão para nova tentativa.
- **Arquivos:** [formulário](../../public/novo-livro.php), [ação POST](../../public/actions/salvar-livro.php), [serviço](../../src/AcervoService.php), [livros](../../src/Livro.php), [categorias](../../src/Categoria.php), [movimentos](../../src/Movimentacao.php), [helpers de sessão/CSRF](../../src/bootstrap.php).
- **Rastreabilidade:** CU01; matriz CT01 e CT02; tabelas `categorias`, `livros`, `movimentacoes`.

## RF02 — Consultar e pesquisar livros

- **Descrição:** exibir o catálogo e pesquisar parcialmente título, autor ou ISBN, em ordem de título e ID.
- **Entradas:** parâmetro GET `busca`, opcional, de até 200 caracteres. Uma pesquisa vazia lista todos os títulos.
- **Resultado esperado:** título, autor, ISBN se informado, categoria, preço e estoque; resumo limitado aos resultados exibidos e acesso à edição e movimentação. Ausência de resultados gera mensagem apropriada e opção de limpar a pesquisa.
- **Alternativas:** pesquisa longa é rejeitada na página; indisponibilidade do banco apresenta mensagem genérica e HTTP 503. `%`, `_` e `!` são escapados como caracteres literais no LIKE.
- **Arquivos:** [catálogo](../../public/index.php), [Livro::listar](../../src/Livro.php), [helpers de saída](../../src/bootstrap.php).
- **Rastreabilidade:** CU02; matriz CT03 e CT04; tabelas `livros` e `categorias`.

## RF03 — Editar informações cadastrais

- **Descrição:** alterar título, autor, categoria, ISBN e preço de um livro existente, preservando seu saldo e histórico.
- **Entradas:** ID válido, dados cadastrais com os mesmos limites de RF01 e token CSRF. O estoque não faz parte dos campos aceitos por `dadosLivro()`.
- **Resultado esperado:** dados atualizados e redirecionamento com mensagem de sucesso. O estoque é apenas exibido na edição; um link permite ir às movimentações.
- **Alternativas:** ID inexistente na página retorna 404. Validação rejeitada retorna ao formulário com campos conhecidos; falha técnica produz mensagem genérica. Edições cadastrais simultâneas seguem a última gravação.
- **Arquivos:** [edição](../../public/editar-livro.php), [ação POST](../../public/actions/atualizar-livro.php), [AcervoService::atualizarLivro](../../src/AcervoService.php), [Livro::atualizar](../../src/Livro.php), [dadosLivro](../../src/bootstrap.php).
- **Rastreabilidade:** CU03; matriz CT07; tabelas `livros` e `categorias`.

## RF04 — Registrar movimentações de estoque

- **Descrição:** acrescentar ou retirar exemplares, gravando saldo e histórico atomicamente.
- **Entradas:** livro existente, tipo `entrada` ou `saida`, quantidade inteira de 1 a 2147483647, observação opcional de até 255 caracteres e token CSRF.
- **Resultado esperado:** transação iniciada; leitura do livro com `FOR UPDATE`; validação do saldo; UPDATE do estoque; INSERT do histórico; commit e redirecionamento 303 com mensagem de sucesso.
- **Alternativas:** saída superior ao saldo, livro inexistente, quantidade inválida, observação longa ou entrada que ultrapasse o INT são rejeitadas. Falhas após início da transação executam rollback. A página exibe o saldo atual, mas a decisão é tomada novamente no servidor sob bloqueio.
- **Arquivos:** [página](../../public/movimentacoes.php), [ação POST](../../public/actions/registrar-movimentacao.php), [AcervoService::movimentar](../../src/AcervoService.php), [Livro::buscar/definirEstoque](../../src/Livro.php), [Movimentacao::registrar](../../src/Movimentacao.php).
- **Rastreabilidade:** CU04; matriz CT05, CT06, CT09, CT11 e CT12; tabelas `livros` e `movimentacoes`.

## RF05 — Consultar histórico de movimentações

- **Descrição:** consultar entradas e saídas, com filtro opcional por livro e ordem decrescente por data e ID.
- **Entradas:** GET `livro_id`, opcional. Livro inválido no filtro é rejeitado com HTTP 404.
- **Resultado esperado:** data/hora, título do livro, tipo, quantidade e observação; indicação de ausência de registros quando aplicável; opção para voltar a todos os livros.
- **Arquivos:** [página e filtro](../../public/movimentacoes.php), [Movimentacao::listar](../../src/Movimentacao.php), [Livro::listar/buscar](../../src/Livro.php), [escape de HTML](../../src/bootstrap.php).
- **Rastreabilidade:** CU05; matriz CT08; tabelas `movimentacoes` e `livros`.

Não há autenticação, exclusão de livros, edição/exclusão de movimentos, cadastro de categorias pela interface, paginação ou integração externa. Esses itens não integram os requisitos implementados.
