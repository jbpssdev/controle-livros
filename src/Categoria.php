<?php
declare(strict_types=1);

final class Categoria
{
    public function __construct(private PDO $pdo) {}

    public function listar(): array
    {
        return $this->pdo->query('SELECT id, nome FROM categorias ORDER BY nome')->fetchAll();
    }

    public function existe(int $id): bool
    {
        $stmt = $this->pdo->prepare('SELECT 1 FROM categorias WHERE id = :id');
        $stmt->execute(['id' => $id]);
        return (bool) $stmt->fetchColumn();
    }
}
