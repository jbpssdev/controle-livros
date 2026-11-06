<?php
declare(strict_types=1);
require_once dirname(__DIR__, 2) . '/src/bootstrap.php';
protegerPost();
$dados = dadosLivro($_POST);
$id = null;
try {
    $id = inteiro($_POST, 'id');
    (new AcervoService(conexao()))->atualizarLivro($id, $dados);
    mensagem('success', 'Dados do livro atualizados com sucesso.');
    redirecionar('../index.php');
} catch (DomainException $e) {
    mensagem('danger', $e->getMessage());
} catch (Throwable $e) {
    mensagem('danger', falhaTecnica($e));
}
if ($id !== null) {
    guardarFormulario('editar-' . $id, $dados);
    redirecionar('../editar-livro.php?id=' . $id);
}
redirecionar('../index.php');
