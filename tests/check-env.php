<?php
declare(strict_types=1);

// Diagnóstico mínimo: não utiliza phpinfo nem imprime configuração ou exceções.
$cli = PHP_SAPI === 'cli';
if (!$cli) {
    header('Content-Type: text/plain; charset=UTF-8');
    header('X-Content-Type-Options: nosniff');
    header('Cache-Control: no-store');
}
$ok = true;
$linhas = [];
$informar = static function (string $nome, bool $resultado) use (&$ok, &$linhas): void {
    $linhas[] = ($resultado ? '[OK] ' : '[FALHA] ') . $nome;
    $ok = $ok && $resultado;
};
$informar('PHP 8.2 ou superior', version_compare(PHP_VERSION, '8.2.0', '>='));
foreach (['PDO', 'pdo_mysql', 'mbstring', 'session', 'filter'] as $extensao) {
    $informar('Extensão ' . $extensao, extension_loaded($extensao));
}
$arquivo = dirname(__DIR__) . '/config/database.php';
$informar('Configuração local presente', is_file($arquivo));
$conectado = false;
$estrutura = false;
$utf8 = false;
if ($ok) {
    try {
        require_once dirname(__DIR__) . '/src/Database.php';
        $pdo = Database::conectar();
        $conectado = (int) $pdo->query('SELECT 1')->fetchColumn() === 1;
        $utf8 = $pdo->query('SELECT @@character_set_connection')->fetchColumn() === 'utf8mb4';
        $pdo->query('SELECT l.id, l.categoria_id, l.titulo, l.autor, l.isbn, l.preco, l.estoque,
            l.criado_em, l.atualizado_em, c.id, c.nome, m.id, m.livro_id, m.tipo,
            m.quantidade, m.observacao, m.criado_em FROM livros l
            LEFT JOIN categorias c ON c.id = l.categoria_id
            LEFT JOIN movimentacoes m ON m.livro_id = l.id LIMIT 0');
        $estrutura = true;
    } catch (Throwable) {
        // A mensagem pública intencionalmente não inclui host, usuário ou senha.
    }
}
$informar('Conexão disponível', $conectado);
$informar('Conexão com charset utf8mb4', $utf8);
$informar('Tabelas e colunas esperadas disponíveis', $estrutura);
if (!$cli && !$ok) {
    http_response_code(503);
}
echo implode(PHP_EOL, $linhas) . PHP_EOL . PHP_EOL;
echo ($ok ? 'Ambiente básico disponível. Execute os cenários do plano de testes.' : 'Revise a instalação, a configuração local e a importação de sql/estrutura.sql conforme o README.') . PHP_EOL;
if ($cli) {
    exit($ok ? 0 : 1);
}
