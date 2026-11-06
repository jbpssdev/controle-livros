# Funcionalidades documentadas a partir do código

Esta seção explica o cadastro, a consulta e a movimentação de livros a partir do código do projeto. Consulte também [requisitos](../requisitos/requisitos-funcionais.md), [classes](../diagramas/classes.png) e [dicionário](../modelagem/dicionario-dados.md).

## 1. Cadastro de livro — RF01 / CU01

### Participantes e tabelas

| Etapa | Arquivo / responsabilidade | Tabela |
| --- | --- | --- |
| Formulário | [novo-livro.php](../../public/novo-livro.php): consulta categorias, exibe campos e token | categorias |
| Ação | [salvar-livro.php](../../public/actions/salvar-livro.php): POST/CSRF, coleta de campos, inteiro do estoque, mensagem e PRG | acesso indireto pelo serviço |
| Regras | [AcervoService.php](../../src/AcervoService.php): limites, categoria existente, preço, transação | categorias, livros, movimentacoes |
| Persistência | [Categoria.php](../../src/Categoria.php), [Livro.php](../../src/Livro.php), [Movimentacao.php](../../src/Movimentacao.php) | respectivas tabelas |
| Recursos comuns | [bootstrap.php](../../src/bootstrap.php): `dadosLivro`, `inteiro`, `protegerPost`, sessão e mensagens | nenhuma diretamente, salvo obtenção da conexão |

### Recebimento na ação

Trecho real de `public/actions/salvar-livro.php`:

```php
protegerPost();
$dados = dadosLivro($_POST);
try {
    $estoque = inteiro($_POST, 'estoque_inicial', 0);
    (new AcervoService(conexao()))->cadastrarLivro($dados, $estoque);
    mensagem('success', 'Livro cadastrado com sucesso.');
    redirecionar('../index.php');
```

`protegerPost()` encerra métodos diferentes de POST com 405 e tokens inválidos com 403. `dadosLivro()` limita os campos cadastrais aceitos. O inteiro do estoque aceita zero. As exceções de domínio são tratadas como validação; exceções técnicas recebem mensagem genérica. Após rejeição de domínio/técnica, a ação guarda os valores conhecidos e redireciona ao formulário.

### Cadastro e entrada inicial na mesma transação

Trecho real de `AcervoService::cadastrarLivro`:

```php
$validos = $this->validarDados($dados);
$this->pdo->beginTransaction();
try {
    $id = $this->livros->cadastrar($validos);
    if ($estoqueInicial > 0) {
        $this->livros->definirEstoque($id, $estoqueInicial);
        $this->movimentacoes->registrar($id, 'entrada', $estoqueInicial, 'Estoque inicial do cadastro');
    }
    $this->pdo->commit();
    return $id;
} catch (Throwable $e) {
    $this->pdo->rollBack();
    throw $e;
}
```

Antes desse trecho, o método verifica o intervalo do estoque inicial. `validarDados()` confere título/autor, limites em caracteres UTF-8, ISBN opcional, categoria existente e formato do preço; a vírgula é substituída por ponto sem converter o preço para float para persistência. O livro nasce com zero, e a quantidade inicial positiva é aplicada com uma entrada na mesma transação. Falha em qualquer gravação reverte inclusive o próprio cadastro.

Trecho real de `Livro::cadastrar`:

```php
$stmt = $this->pdo->prepare('INSERT INTO livros (categoria_id, titulo, autor, isbn, preco, estoque)
    VALUES (:categoria_id, :titulo, :autor, :isbn, :preco, 0)');
$stmt->execute($dados);
return (int) $this->pdo->lastInsertId();
```

Consultas relevantes: `SELECT 1 FROM categorias WHERE id = :id`; o INSERT acima; `UPDATE livros SET estoque = :estoque, atualizado_em = CURRENT_TIMESTAMP WHERE id = :id`; e `INSERT INTO movimentacoes (livro_id, tipo, quantidade, observacao) VALUES (:livro_id, :tipo, :quantidade, :observacao)`. Os valores são enviados por parâmetros. Não há escrita de estoque no formulário de edição.

### Saída e validação

Sucesso redireciona com HTTP 303 para o catálogo. A renderização aplica `e()` aos dados, inclusive aos valores preservados após validação. O redirecionamento evita repetir o envio ao atualizar a página. Um novo envio do formulário ainda pode gerar outro cadastro.

## 2. Consulta e pesquisa de livros — RF02 / CU02

### Fluxo e tabelas

1. [public/index.php](../../public/index.php) lê GET `busca`, remove espaços nas extremidades e rejeita mais de 200 caracteres.
2. Obtém PDO por `conexao()` e chama `Livro::listar($busca)`.
3. A consulta junta `livros` com `categorias`, adiciona filtros somente quando a busca não está vazia e ordena por título/ID.
4. A página calcula total de títulos, soma do estoque e títulos com saldo a partir dos resultados retornados.
5. Cabeçalho, tabela e estados vazios usam HTML compartilhado e saída escapada. A consulta não grava dados do acervo.

Trecho real de `Livro::listar`:

```php
$sql = 'SELECT l.*, c.nome AS categoria FROM livros l
        INNER JOIN categorias c ON c.id = l.categoria_id';
$parametros = [];
if ($busca !== '') {
    // Os parâmetros são independentes para funcionar com prepares nativos.
    $sql .= " WHERE l.titulo LIKE :titulo ESCAPE '!' OR l.autor LIKE :autor ESCAPE '!' OR l.isbn LIKE :isbn ESCAPE '!'";
    $termo = '%' . strtr($busca, ['!' => '!!', '%' => '!%', '_' => '!_']) . '%';
    $parametros = ['titulo' => $termo, 'autor' => $termo, 'isbn' => $termo];
}
$stmt = $this->pdo->prepare($sql . ' ORDER BY l.titulo, l.id');
$stmt->execute($parametros);
return $stmt->fetchAll();
```

O SQL estrutural é fixo; o termo não é concatenado ao comando. São utilizados três nomes de parâmetro distintos porque a conexão desabilita emulação de prepares. `strtr()` escapa os curingas SQL e o caractere de escape: a pessoa pode pesquisar `%` ou `_` literalmente. Os `%` acrescentados externamente permitem correspondência parcial. Essa estratégia não fornece busca full-text nem paginação; em grandes bases, os índices por texto podem não ser usados devido ao curinga inicial.

Trecho real da tabela de catálogo:

```php
<strong class="book-title"><?= e($livro['titulo']) ?></strong>
```

A função `e()`, definida em `src/bootstrap.php`, prepara o valor para exibição no HTML:

```php
function e(mixed $valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
```

O título que contenha marcação é exibido como texto no contexto HTML. Nas consultas SQL, os valores são enviados por parâmetros PDO.

Sem resultado, a página apresenta “Nenhum livro encontrado”. Sem cadastro, apresenta “Seu acervo começa aqui”. Em indisponibilidade técnica, a página retorna 503 e mensagem genérica, sem imprimir a exceção.

## 3. Movimentação — RF04 e RF05

Fluxo detalhado no [diagrama de sequência](../diagramas/sequencia.png). A [ação POST](../../public/actions/registrar-movimentacao.php) valida token e inteiros, e o [serviço](../../src/AcervoService.php) valida tipo/quantidade/observação antes da transação. Dentro dela, `Livro::buscar($id, true)` gera `SELECT * FROM livros WHERE id = :id FOR UPDATE`. O saldo é verificado **depois de adquirir o bloqueio**, não apenas pelo saldo mostrado no formulário.

Trecho real de `AcervoService::movimentar`:

```php
$saldo = (int) $livro['estoque'];
if ($tipo === 'saida' && $quantidade > $saldo) {
    throw new DomainException('Saída não permitida: o estoque disponível é de ' . $saldo . ' exemplar(es).');
}
$novoSaldo = $tipo === 'entrada' ? $saldo + $quantidade : $saldo - $quantidade;
if ($novoSaldo > 2147483647) {
    throw new DomainException('A entrada excede o limite de exemplares por livro.');
}
$this->livros->definirEstoque($livroId, $novoSaldo);
$this->movimentacoes->registrar($livroId, $tipo, $quantidade, $observacao === '' ? null : $observacao);
$this->pdo->commit();
```

Uma exceção dentro da transação executa rollback e retorna à ação, que transforma o resultado em mensagem temporária. O histórico usa JOIN entre `movimentacoes` e `livros`, filtro opcional `m.livro_id = :livro_id` e `ORDER BY m.criado_em DESC, m.id DESC`. Não há método para editar ou apagar movimentos.
