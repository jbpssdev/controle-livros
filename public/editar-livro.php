<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/src/bootstrap.php';
$pagina = 'catalogo';
$tituloPagina = 'Editar livro';
$erro = null;
$livro = null;
$categorias = [];
try {
    $id = inteiro($_GET, 'id');
    $livro = (new Livro(conexao()))->buscar($id);
    if ($livro === null) {
        throw new DomainException('Livro não encontrado. Volte ao catálogo e selecione um livro válido.');
    }
    $categorias = (new Categoria(conexao()))->listar();
} catch (DomainException $e) {
    http_response_code(404);
    $erro = $e->getMessage();
} catch (Throwable $e) {
    http_response_code(503);
    $erro = falhaTecnica($e);
}
$dados = $livro ? array_replace($livro, recuperarFormulario('editar-' . $livro['id'])) : [];
require dirname(__DIR__) . '/layouts/header.php';
?>
<a class="back-link" href="index.php">← Voltar ao catálogo</a>
<section class="page-heading"><div><p class="eyebrow">INFORMAÇÕES EM DIA</p><h1>Editar livro<span class="title-dot">.</span></h1><p class="page-description">Atualize as informações cadastrais do seu acervo.</p></div></section>
<?php if ($livro !== null && $erro === null): ?>
<div class="row g-4 form-layout"><div class="col-lg-8"><section class="panel form-panel" aria-labelledby="dados-titulo"><h2 id="dados-titulo">Dados do livro</h2><p class="form-intro">Os campos marcados com <span aria-hidden="true">*</span> são obrigatórios.</p>
<form action="actions/atualizar-livro.php" method="post" class="book-form">
    <input type="hidden" name="csrf" value="<?= e(tokenCsrf()) ?>"><input type="hidden" name="id" value="<?= (int) $livro['id'] ?>">
    <div class="mb-4"><label class="form-label" for="titulo">Título <span aria-hidden="true">*</span></label><input class="form-control" id="titulo" name="titulo" maxlength="200" value="<?= e($dados['titulo']) ?>" required></div>
    <div class="mb-4"><label class="form-label" for="autor">Autor <span aria-hidden="true">*</span></label><input class="form-control" id="autor" name="autor" maxlength="150" value="<?= e($dados['autor']) ?>" required></div>
    <div class="row g-4 mb-4"><div class="col-md-6"><label class="form-label" for="categoria_id">Categoria <span aria-hidden="true">*</span></label><select class="form-select" id="categoria_id" name="categoria_id" required><option value="">Selecione uma categoria</option><?php foreach ($categorias as $categoria): ?><option value="<?= (int) $categoria['id'] ?>" <?= (string) $dados['categoria_id'] === (string) $categoria['id'] ? 'selected' : '' ?>><?= e($categoria['nome']) ?></option><?php endforeach; ?></select></div>
    <div class="col-md-6"><label class="form-label" for="isbn">ISBN <span class="optional">(opcional)</span></label><input class="form-control" id="isbn" name="isbn" maxlength="20" value="<?= e($dados['isbn']) ?>"></div></div>
    <div class="row g-4"><div class="col-md-6"><label class="form-label" for="preco">Preço (R$) <span aria-hidden="true">*</span></label><input class="form-control" type="text" inputmode="decimal" id="preco" name="preco" maxlength="11" pattern="[0-9]{1,8}([.,][0-9]{1,2})?" value="<?= e(str_replace('.', ',', $dados['preco'])) ?>" aria-describedby="preco-ajuda" required><div class="form-text" id="preco-ajuda">Use vírgula ou ponto. Ex.: 25,90.</div></div>
    <div class="col-md-6"><span class="form-label d-block">Estoque atual</span><div class="readonly-stock"><?= (int) $livro['estoque'] ?> exemplar(es)</div><div class="form-text">Para alterar, <a href="movimentacoes.php?livro_id=<?= (int) $livro['id'] ?>">registre uma movimentação</a>.</div></div></div>
    <div class="form-actions"><a class="btn btn-light" href="index.php">Cancelar</a><button class="btn btn-primary" type="submit">Salvar alterações</button></div>
</form></section></div>
<aside class="col-lg-4"><div class="note-card"><span class="note-number" aria-hidden="true">02 / CADASTRO</span><h2>Dados certos, acervo organizado.</h2><p>Altere título, autor, categoria, ISBN e preço sempre que necessário.</p><hr><h3>A quantidade tem seu lugar</h3><p>O estoque é alterado somente por entradas e saídas. Assim, cada exemplar mantém seu histórico.</p><a href="movimentacoes.php?livro_id=<?= (int) $livro['id'] ?>">Ver movimentações →</a></div></aside></div>
<?php endif; ?>
<?php require dirname(__DIR__) . '/layouts/footer.php'; ?>
