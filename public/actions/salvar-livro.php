<?php
declare(strict_types=1);
require_once dirname(__DIR__, 2) . '/src/bootstrap.php';
protegerPost();
$dados = dadosLivro($_POST);
try {
    $estoque = inteiro($_POST, 'estoque_inicial', 0);
    (new AcervoService(conexao()))->cadastrarLivro($dados, $estoque);
    mensagem('success', 'Livro cadastrado com sucesso.');
    redirecionar('../index.php');
} catch (DomainException $e) {
    mensagem('danger', $e->getMessage());
} catch (Throwable $e) {
    mensagem('danger', falhaTecnica($e));
}
guardarFormulario('novo', $dados + ['estoque_inicial' => texto($_POST, 'estoque_inicial')]);
redirecionar('../novo-livro.php');
