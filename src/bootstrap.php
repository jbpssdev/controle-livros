<?php
declare(strict_types=1);

date_default_timezone_set('America/Fortaleza');
if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    session_set_cookie_params([
        'httponly' => true,
        'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
        'samesite' => 'Lax',
    ]);
    session_start();
}
header('Content-Type: text/html; charset=UTF-8');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');
header("Content-Security-Policy: default-src 'self'; style-src 'self'; script-src 'self'; img-src 'self' data:; form-action 'self'; frame-ancestors 'none'; base-uri 'self'");
header('Cache-Control: no-store');

foreach (['Database', 'Categoria', 'Livro', 'Movimentacao', 'AcervoService'] as $classe) {
    require_once __DIR__ . '/' . $classe . '.php';
}

function e(mixed $valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function texto(array $origem, string $campo): string
{
    return isset($origem[$campo]) && is_string($origem[$campo]) ? trim($origem[$campo]) : '';
}

function inteiro(array $origem, string $campo, int $minimo = 1): int
{
    $valor = filter_var($origem[$campo] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => $minimo, 'max_range' => 2147483647]]);
    if ($valor === false) {
        throw new DomainException('Informe um valor inteiro válido para ' . str_replace('_', ' ', $campo) . '.');
    }
    return $valor;
}

function conexao(): PDO
{
    static $pdo = null;
    return $pdo ??= Database::conectar();
}

function tokenCsrf(): string
{
    return $_SESSION['csrf'] ??= bin2hex(random_bytes(32));
}

function protegerPost(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header('Allow: POST');
        http_response_code(405);
        exit('Método não permitido. Utilize o formulário do sistema.');
    }
    $token = texto($_POST, 'csrf');
    if ($token === '' || !isset($_SESSION['csrf']) || !hash_equals($_SESSION['csrf'], $token)) {
        http_response_code(403);
        exit('O formulário expirou ou é inválido. Volte à página, recarregue e tente novamente.');
    }
}

function mensagem(string $tipo, string $texto): void
{
    $_SESSION['mensagens'][] = ['tipo' => $tipo, 'texto' => $texto];
}

function redirecionar(string $destino): never
{
    header('Location: ' . $destino, true, 303);
    exit;
}

function guardarFormulario(string $chave, array $dados): void
{
    // Apenas campos conhecidos são preservados; tokens nunca são armazenados aqui.
    $_SESSION['formularios'][$chave] = $dados;
}

function recuperarFormulario(string $chave): array
{
    $dados = $_SESSION['formularios'][$chave] ?? [];
    unset($_SESSION['formularios'][$chave]);
    return $dados;
}

function dadosLivro(array $origem): array
{
    $dados = [];
    foreach (['titulo', 'autor', 'categoria_id', 'isbn', 'preco'] as $campo) {
        $dados[$campo] = texto($origem, $campo);
    }
    return $dados;
}

function falhaTecnica(Throwable $e): string
{
    error_log('[controle-livros] ' . get_class($e) . ': ' . $e->getMessage());
    return 'Não foi possível concluir a operação. Verifique se o MySQL do XAMPP está iniciado, se o SQL foi importado e se a conexão local está configurada.';
}

function moeda(string $valor): string
{
    return 'R$ ' . number_format((float) $valor, 2, ',', '.');
}
