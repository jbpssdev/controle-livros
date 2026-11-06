<?php
declare(strict_types=1);
require_once dirname(__DIR__, 2) . '/src/bootstrap.php';
protegerPost();
$dados = [];
foreach (['livro_id', 'tipo', 'quantidade', 'observacao'] as $campo) {
    $dados[$campo] = texto($_POST, $campo);
}
$livroId = null;
try {
    $livroId = inteiro($_POST, 'livro_id');
    $quantidade = inteiro($_POST, 'quantidade');
    (new AcervoService(conexao()))->movimentar($livroId, $dados['tipo'], $quantidade, $dados['observacao']);
    mensagem('success', 'Movimentação registrada com sucesso. O estoque foi atualizado.');
    redirecionar('../movimentacoes.php?livro_id=' . $livroId);
} catch (DomainException $e) {
    mensagem('danger', $e->getMessage());
} catch (Throwable $e) {
    mensagem('danger', falhaTecnica($e));
}
guardarFormulario('movimentacao', $dados);
redirecionar('../movimentacoes.php' . ($livroId !== null ? '?livro_id=' . $livroId : ''));
