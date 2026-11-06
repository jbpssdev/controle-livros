<?php
declare(strict_types=1);

final class Movimentacao
{
    public function __construct(private PDO $pdo) {}

    public function listar(?int $livroId = null): array
    {
        $sql = 'SELECT m.*, l.titulo FROM movimentacoes m INNER JOIN livros l ON l.id = m.livro_id';
        $stmt = $this->pdo->prepare($sql . ($livroId !== null ? ' WHERE m.livro_id = :livro_id' : '') . ' ORDER BY m.criado_em DESC, m.id DESC');
        $stmt->execute($livroId !== null ? ['livro_id' => $livroId] : []);
        return $stmt->fetchAll();
    }

    public function registrar(int $livroId, string $tipo, int $quantidade, ?string $observacao): void
    {
        $stmt = $this->pdo->prepare('INSERT INTO movimentacoes (livro_id, tipo, quantidade, observacao)
            VALUES (:livro_id, :tipo, :quantidade, :observacao)');
        $stmt->execute(['livro_id' => $livroId, 'tipo' => $tipo, 'quantidade' => $quantidade, 'observacao' => $observacao]);
    }
}
