<?php
declare(strict_types=1);
require_once dirname(__DIR__) . '/src/bootstrap.php';
$pagina = 'movimentacoes';
$tituloPagina = 'Movimentações';
$erro = null;
$livros = [];
$historico = [];
$filtroId = null;
$selecionado = null;
try {
    if (texto($_GET, 'livro_id') !== '' || isset($_GET['livro_id']) && !is_string($_GET['livro_id'])) {
        $filtroId = inteiro($_GET, 'livro_id');
    }
    $livros = (new Livro(conexao()))->listar();
    if ($filtroId !== null) {
        $selecionado = (new Livro(conexao()))->buscar($filtroId);
        if ($selecionado === null) {
            throw new DomainException('Livro não encontrado. Selecione outro livro no catálogo.');
        }
    }
    $historico = (new Movimentacao(conexao()))->listar($filtroId);
} catch (DomainException $e) {
    http_response_code(404);
    $erro = $e->getMessage();
} catch (Throwable $e) {
    http_response_code(503);
    $erro = falhaTecnica($e);
}
$dados = recuperarFormulario('movimentacao');
if ($filtroId !== null) {
    $dados['livro_id'] = (string) $filtroId;
}
require dirname(__DIR__) . '/layouts/header.php';
?>
<section class="page-heading"><div><p class="eyebrow">CADA EXEMPLAR CONTA</p><h1>Movimentações<span class="title-dot">.</span></h1><p class="page-description">Registre entradas e saídas e acompanhe o histórico do acervo.</p></div><a class="btn btn-outline-primary" href="index.php">Ver catálogo <span aria-hidden="true">↗</span></a></section>
<div class="row g-4 movement-layout"><div class="col-lg-4">
<section class="panel form-panel movement-form" aria-labelledby="registro-titulo"><span class="eyebrow">ESTOQUE</span><h2 id="registro-titulo">Registrar movimentação</h2><p class="form-intro">Todos os campos são obrigatórios, exceto a observação.</p>
<?php if ($erro === null && $livros === []): ?><div class="alert alert-info">Cadastre um livro para registrar movimentações. <a href="novo-livro.php">Cadastrar livro</a></div><?php endif; ?>
<form action="actions/registrar-movimentacao.php" method="post">
    <input type="hidden" name="csrf" value="<?= e(tokenCsrf()) ?>">
    <fieldset <?= $erro !== null || $livros === [] ? 'disabled' : '' ?>>
    <div class="mb-3"><label class="form-label" for="livro_id">Livro</label><select class="form-select" id="livro_id" name="livro_id" required><option value="">Selecione um livro</option><?php foreach ($livros as $livro): ?><option value="<?= (int) $livro['id'] ?>" data-estoque="<?= (int) $livro['estoque'] ?>" <?= (string) ($dados['livro_id'] ?? '') === (string) $livro['id'] ? 'selected' : '' ?>><?= e($livro['titulo']) ?> · <?= (int) $livro['estoque'] ?> em estoque</option><?php endforeach; ?></select><div class="form-text" id="estoque-ajuda" aria-live="polite">A quantidade disponível aparece ao lado do título.</div></div>
    <div class="mb-3"><label class="form-label" for="tipo">Tipo de movimentação</label><select class="form-select" id="tipo" name="tipo" required><option value="entrada" <?= ($dados['tipo'] ?? 'entrada') === 'entrada' ? 'selected' : '' ?>>Entrada de exemplares</option><option value="saida" <?= ($dados['tipo'] ?? '') === 'saida' ? 'selected' : '' ?>>Saída de exemplares</option></select></div>
    <div class="mb-3"><label class="form-label" for="quantidade">Quantidade</label><input class="form-control" type="number" id="quantidade" name="quantidade" min="1" max="2147483647" step="1" value="<?= e($dados['quantidade'] ?? '1') ?>" required></div>
    <div class="mb-4"><label class="form-label" for="observacao">Observação <span class="optional">(opcional)</span></label><textarea class="form-control" id="observacao" name="observacao" rows="3" maxlength="255" aria-describedby="observacao-ajuda"><?= e($dados['observacao'] ?? '') ?></textarea><div class="form-text" id="observacao-ajuda">Até 255 caracteres.</div></div>
    <button class="btn btn-primary w-100" type="submit">Registrar movimentação</button>
    </fieldset>
</form><p class="stock-note">O saldo e o histórico são atualizados juntos a cada registro.</p></section>
</div><div class="col-lg-8">
<section class="panel" aria-labelledby="historico-titulo"><div class="panel-toolbar history-toolbar"><div><h2 id="historico-titulo">Histórico de movimentações</h2><p><?= $selecionado ? e($selecionado['titulo']) : 'Todas as entradas e saídas do acervo.' ?></p></div><?php if ($filtroId !== null): ?><a class="small-link" href="movimentacoes.php">Ver todos os livros</a><?php endif; ?></div>
<form class="history-filter" action="movimentacoes.php" method="get"><label class="visually-hidden" for="filtro-livro">Filtrar histórico por livro</label><select class="form-select" name="livro_id" id="filtro-livro"><option value="">Todos os livros</option><?php foreach ($livros as $livro): ?><option value="<?= (int) $livro['id'] ?>" <?= $filtroId === (int) $livro['id'] ? 'selected' : '' ?>><?= e($livro['titulo']) ?></option><?php endforeach; ?></select><button class="btn btn-outline-primary" type="submit">Filtrar</button></form>
<?php if ($erro !== null): ?><div class="empty-state"><h3>Histórico indisponível</h3><p>Confira a mensagem acima e tente novamente.</p></div>
<?php elseif ($historico === []): ?><div class="empty-state"><span class="empty-symbol" aria-hidden="true">↕</span><h3>Nenhuma movimentação registrada</h3><p>As entradas e saídas aparecerão aqui após o primeiro registro.</p></div>
<?php else: ?>
<div class="table-responsive" tabindex="0" role="region" aria-label="Histórico; role horizontalmente em telas pequenas"><table class="table align-middle history-table"><caption class="visually-hidden">Data, livro, tipo, quantidade e observação das movimentações</caption><thead><tr><th scope="col">Data / livro</th><th scope="col">Tipo</th><th scope="col">Quantidade</th><th scope="col">Observação</th></tr></thead><tbody>
<?php foreach ($historico as $movimentacao): ?><tr><td><time class="movement-date" datetime="<?= e(str_replace(' ', 'T', $movimentacao['criado_em'])) ?>"><?= e(date('d/m/Y H:i', strtotime($movimentacao['criado_em']))) ?></time><strong class="history-book"><?= e($movimentacao['titulo']) ?></strong></td><td><span class="type-badge <?= $movimentacao['tipo'] === 'entrada' ? 'type-in' : 'type-out' ?>"><?= $movimentacao['tipo'] === 'entrada' ? '↙ Entrada' : '↗ Saída' ?></span></td><td class="quantity"><?= (int) $movimentacao['quantidade'] ?></td><td class="observation"><?= $movimentacao['observacao'] !== null ? e($movimentacao['observacao']) : 'Sem observação' ?></td></tr><?php endforeach; ?>
</tbody></table></div><div class="panel-bottom"><?= count($historico) ?> movimentação(ões) registrada(s)</div>
<?php endif; ?></section></div></div>
<?php require dirname(__DIR__) . '/layouts/footer.php'; ?>
