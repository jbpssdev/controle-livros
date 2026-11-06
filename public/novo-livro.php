<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/src/bootstrap.php';
$pagina = 'cadastro';
$tituloPagina = 'Cadastrar livro';
$categorias = [];
$erro = null;
$dados = recuperarFormulario('novo');
try {
    $categorias = (new Categoria(conexao()))->listar();
} catch (Throwable $e) {
    http_response_code(503);
    $erro = falhaTecnica($e);
}
require dirname(__DIR__) . '/layouts/header.php';
?>
<a class="back-link" href="index.php">← Voltar ao catálogo</a>
<section class="page-heading"><div><p class="eyebrow">MAIS HISTÓRIAS NO ACERVO</p><h1>Cadastrar livro<span class="title-dot">.</span></h1><p class="page-description">Registre os dados do livro e a quantidade inicial de exemplares.</p></div></section>
<div class="row g-4 form-layout"><div class="col-lg-8">
<section class="panel form-panel" aria-labelledby="dados-titulo"><h2 id="dados-titulo">Dados do livro</h2><p class="form-intro">Os campos marcados com <span aria-hidden="true">*</span> são obrigatórios.</p>
<?php if ($erro === null && $categorias === []): ?><div class="alert alert-warning">Nenhuma categoria cadastrada. Importe sql/estrutura.sql conforme o README para carregar as categorias iniciais.</div><?php endif; ?>
<form action="actions/salvar-livro.php" method="post" class="book-form">
    <input type="hidden" name="csrf" value="<?= e(tokenCsrf()) ?>">
    <fieldset <?= $erro !== null || $categorias === [] ? 'disabled' : '' ?>>
    <div class="mb-4"><label class="form-label" for="titulo">Título <span aria-hidden="true">*</span></label><input class="form-control" id="titulo" name="titulo" maxlength="200" value="<?= e($dados['titulo'] ?? '') ?>" required></div>
    <div class="mb-4"><label class="form-label" for="autor">Autor <span aria-hidden="true">*</span></label><input class="form-control" id="autor" name="autor" maxlength="150" value="<?= e($dados['autor'] ?? '') ?>" required></div>
    <div class="row g-4 mb-4"><div class="col-md-6"><label class="form-label" for="categoria_id">Categoria <span aria-hidden="true">*</span></label><select class="form-select" id="categoria_id" name="categoria_id" required><option value="">Selecione uma categoria</option><?php foreach ($categorias as $categoria): ?><option value="<?= (int) $categoria['id'] ?>" <?= (string) ($dados['categoria_id'] ?? '') === (string) $categoria['id'] ? 'selected' : '' ?>><?= e($categoria['nome']) ?></option><?php endforeach; ?></select></div>
    <div class="col-md-6"><label class="form-label" for="isbn">ISBN <span class="optional">(opcional)</span></label><input class="form-control" id="isbn" name="isbn" maxlength="20" value="<?= e($dados['isbn'] ?? '') ?>" aria-describedby="isbn-ajuda"><div class="form-text" id="isbn-ajuda">Identificador da edição, se disponível.</div></div></div>
    <div class="row g-4"><div class="col-md-6"><label class="form-label" for="preco">Preço (R$) <span aria-hidden="true">*</span></label><input class="form-control" type="text" inputmode="decimal" id="preco" name="preco" maxlength="11" pattern="[0-9]{1,8}([.,][0-9]{1,2})?" value="<?= e($dados['preco'] ?? '0,00') ?>" aria-describedby="preco-ajuda" required><div class="form-text" id="preco-ajuda">Use vírgula ou ponto. Ex.: 25,90.</div></div>
    <div class="col-md-6"><label class="form-label" for="estoque_inicial">Estoque inicial <span aria-hidden="true">*</span></label><input class="form-control" type="number" id="estoque_inicial" name="estoque_inicial" min="0" max="2147483647" step="1" value="<?= e($dados['estoque_inicial'] ?? '0') ?>" required><div class="form-text">Quantidade de exemplares disponíveis.</div></div></div>
    <div class="form-actions"><a class="btn btn-light" href="index.php">Cancelar</a><button class="btn btn-primary" type="submit">Cadastrar livro</button></div>
    </fieldset>
</form></section></div>
<aside class="col-lg-4"><div class="note-card"><span class="note-number" aria-hidden="true">01 / ACERVO</span><h2>Todo exemplar tem uma história.</h2><p>Um cadastro completo facilita a pesquisa e mantém o seu acervo organizado.</p><hr><h3>Estoque com histórico</h3><p>Se houver exemplares no cadastro, uma entrada inicial será registrada automaticamente.</p><h3>Depois do cadastro</h3><p>Use a página de movimentações para registrar novas entradas e saídas.</p></div></aside></div>
<?php require dirname(__DIR__) . '/layouts/footer.php'; ?>
