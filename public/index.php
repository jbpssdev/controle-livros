<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/src/bootstrap.php';
$pagina = 'catalogo';
$tituloPagina = 'Catálogo de livros';
$busca = texto($_GET, 'busca');
$livros = [];
$erro = null;
try {
    if (mb_strlen($busca, 'UTF-8') > 200) {
        throw new DomainException('A pesquisa deve ter no máximo 200 caracteres.');
    }
    $livros = (new Livro(conexao()))->listar($busca);
} catch (DomainException $e) {
    $erro = $e->getMessage();
} catch (Throwable $e) {
    http_response_code(503);
    $erro = falhaTecnica($e);
}
$exemplares = array_sum(array_column($livros, 'estoque'));
$disponiveis = count(array_filter($livros, static fn (array $livro): bool => (int) $livro['estoque'] > 0));
require dirname(__DIR__) . '/layouts/header.php';
?>
<section class="page-heading">
    <div><p class="eyebrow">SEU ACERVO, BEM CUIDADO</p><h1>Catálogo de livros<span class="title-dot">.</span></h1><p class="page-description">Consulte os títulos e acompanhe cada exemplar do seu acervo.</p></div>
    <a class="btn btn-primary" href="novo-livro.php"><span aria-hidden="true">＋</span> Cadastrar livro</a>
</section>
<?php if ($erro === null): ?>
<section class="stats-grid" aria-label="Resumo <?= $busca !== '' ? 'dos resultados da pesquisa' : 'do acervo' ?>">
    <div class="stat-card"><span class="stat-label"><?= $busca !== '' ? 'Títulos encontrados' : 'Títulos no acervo' ?></span><strong><?= count($livros) ?></strong><span class="stat-note">Livros cadastrados</span></div>
    <div class="stat-card"><span class="stat-label">Exemplares disponíveis</span><strong><?= e($exemplares) ?></strong><span class="stat-note">Soma das quantidades em estoque</span></div>
    <div class="stat-card stat-accent"><span class="stat-label">Títulos com estoque</span><strong><?= $disponiveis ?></strong><span class="stat-note">Com pelo menos um exemplar</span></div>
</section>
<?php endif; ?>
<section class="panel" aria-labelledby="lista-titulo">
    <div class="panel-toolbar"><div><h2 id="lista-titulo">Seu catálogo</h2><p>Encontre o próximo livro em poucos segundos.</p></div>
        <form class="search-form" action="index.php" method="get" role="search">
            <label class="visually-hidden" for="busca">Pesquisar por título, autor ou ISBN</label>
            <input class="form-control" type="search" name="busca" id="busca" maxlength="200" placeholder="Título, autor ou ISBN" value="<?= e($busca) ?>">
            <button class="btn btn-primary" type="submit">Pesquisar</button>
        </form>
    </div>
    <?php if ($busca !== ''): ?><div class="search-summary">Resultados para <strong>“<?= e($busca) ?>”</strong> <a href="index.php">Limpar pesquisa</a></div><?php endif; ?>
    <?php if ($erro !== null): ?>
        <div class="empty-state"><h3>Catálogo indisponível</h3><p>Confira a mensagem acima e tente novamente.</p></div>
    <?php elseif ($livros === []): ?>
        <div class="empty-state"><span class="empty-symbol" aria-hidden="true">≡</span><h3><?= $busca !== '' ? 'Nenhum livro encontrado' : 'Seu acervo começa aqui' ?></h3><p><?= $busca !== '' ? 'Experimente outro título, autor ou ISBN.' : 'Cadastre o primeiro livro para organizar títulos e exemplares.' ?></p><a class="btn btn-outline-primary" href="<?= $busca !== '' ? 'index.php' : 'novo-livro.php' ?>"><?= $busca !== '' ? 'Ver todos os livros' : 'Cadastrar primeiro livro' ?></a></div>
    <?php else: ?>
        <div class="table-responsive" tabindex="0" role="region" aria-label="Livros do catálogo; role horizontalmente em telas pequenas">
        <table class="table align-middle catalog-table"><caption class="visually-hidden">Livros cadastrados com categoria, preço e estoque</caption>
            <thead><tr><th scope="col">Livro / autor</th><th scope="col">Categoria</th><th scope="col">Preço</th><th scope="col">Disponibilidade</th><th scope="col" class="text-end">Ações</th></tr></thead>
            <tbody><?php foreach ($livros as $livro): ?><tr>
                <td><div class="book-cell"><span class="book-spine" aria-hidden="true">L</span><div><strong class="book-title"><?= e($livro['titulo']) ?></strong><span class="secondary-text"><?= e($livro['autor']) ?></span><?php if ($livro['isbn']): ?><small class="isbn">ISBN <?= e($livro['isbn']) ?></small><?php endif; ?></div></div></td>
                <td><span class="category-tag"><?= e($livro['categoria']) ?></span></td><td class="price"><?= e(moeda($livro['preco'])) ?></td>
                <td><span class="stock-badge <?= (int) $livro['estoque'] === 0 ? 'stock-empty' : '' ?>"><?= (int) $livro['estoque'] ?> exemplar(es)</span></td>
                <td><div class="row-actions"><a href="editar-livro.php?id=<?= (int) $livro['id'] ?>" aria-label="Editar <?= e($livro['titulo']) ?>">Editar</a><a href="movimentacoes.php?livro_id=<?= (int) $livro['id'] ?>" aria-label="Movimentar <?= e($livro['titulo']) ?>">Movimentar <span aria-hidden="true">↗</span></a></div></td>
            </tr><?php endforeach; ?></tbody>
        </table></div>
        <div class="panel-bottom"><?= count($livros) ?> título(s) <?= $busca !== '' ? 'encontrado(s)' : 'no catálogo' ?></div>
    <?php endif; ?>
</section>
<?php require dirname(__DIR__) . '/layouts/footer.php'; ?>
