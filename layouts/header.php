<?php
declare(strict_types=1);
$pagina = $pagina ?? 'catalogo';
$tituloPagina = $tituloPagina ?? 'Catálogo de livros';
$mensagens = $_SESSION['mensagens'] ?? [];
unset($_SESSION['mensagens']);
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#194e43">
    <title><?= e($tituloPagina) ?> · Controle de Livros Usados</title>
    <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="../assets/css/style.css">
    <script src="../assets/js/app.js" defer></script>
</head>
<body>
<a class="skip-link" href="#conteudo">Pular para o conteúdo</a>
<header class="site-header">
    <div class="container app-nav">
        <a class="brand" href="index.php" aria-label="Controle de Livros Usados — início">
            <span class="brand-mark" aria-hidden="true"><svg viewBox="0 0 32 32" fill="none"><path d="M16 9c-4-3-8-3-12-2v18c4-1 8-1 12 2 4-3 8-3 12-2V7c-4-1-8-1-12 2Z" stroke="currentColor" stroke-width="1.8"/><path d="M16 9v18M8 12h4m-4 5h4m8-5h4m-4 5h4" stroke="currentColor" stroke-width="1.5"/></svg></span>
            <span>livros usados<small>CONTROLE DO ACERVO</small></span>
        </a>
        <nav class="main-nav" aria-label="Navegação principal">
            <a href="index.php" <?= $pagina === 'catalogo' ? 'class="active" aria-current="page"' : '' ?>>Catálogo</a>
            <a href="novo-livro.php" <?= $pagina === 'cadastro' ? 'class="active" aria-current="page"' : '' ?>>Cadastrar livro</a>
            <a href="movimentacoes.php" <?= $pagina === 'movimentacoes' ? 'class="active" aria-current="page"' : '' ?>>Movimentações</a>
        </nav>
        <span class="local-label"><span aria-hidden="true"></span> Acervo local</span>
    </div>
</header>
<main id="conteudo" class="container main-content" tabindex="-1">
    <?php foreach ($mensagens as $mensagem): ?>
        <div class="alert <?= $mensagem['tipo'] === 'success' ? 'alert-success' : 'alert-danger' ?>" role="<?= $mensagem['tipo'] === 'success' ? 'status' : 'alert' ?>"><?= e($mensagem['texto']) ?></div>
    <?php endforeach; ?>
    <?php if (!empty($erro)): ?>
        <div class="alert alert-danger" role="alert"><?= e($erro) ?></div>
    <?php endif; ?>
