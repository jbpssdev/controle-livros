<?php
declare(strict_types=1);

final class Livro
{
    public function __construct(private PDO $pdo) {}

    public function listar(string $busca = ''): array
    {
        $sql = 'SELECT l.*, c.nome AS categoria FROM livros l
                INNER JOIN categorias c ON c.id = l.categoria_id';
        $parametros = [];
        if ($busca !== '') {
            // Os parâmetros são independentes para funcionar com prepares nativos.
            $sql .= " WHERE l.titulo LIKE :titulo ESCAPE '!' OR l.autor LIKE :autor ESCAPE '!' OR l.isbn LIKE :isbn ESCAPE '!'";
            $termo = '%' . strtr($busca, ['!' => '!!', '%' => '!%', '_' => '!_']) . '%';
            $parametros = ['titulo' => $termo, 'autor' => $termo, 'isbn' => $termo];
        }
        $stmt = $this->pdo->prepare($sql . ' ORDER BY l.titulo, l.id');
        $stmt->execute($parametros);
        return $stmt->fetchAll();
    }

    public function buscar(int $id, bool $bloquear = false): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM livros WHERE id = :id' . ($bloquear ? ' FOR UPDATE' : ''));
        $stmt->execute(['id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public function cadastrar(array $dados): int
    {
        $stmt = $this->pdo->prepare('INSERT INTO livros (categoria_id, titulo, autor, isbn, preco, estoque)
            VALUES (:categoria_id, :titulo, :autor, :isbn, :preco, 0)');
        $stmt->execute($dados);
        return (int) $this->pdo->lastInsertId();
    }

    public function atualizar(int $id, array $dados): void
    {
        $stmt = $this->pdo->prepare('UPDATE livros SET categoria_id = :categoria_id, titulo = :titulo,
            autor = :autor, isbn = :isbn, preco = :preco, atualizado_em = CURRENT_TIMESTAMP WHERE id = :id');
        $stmt->execute($dados + ['id' => $id]);
    }

    public function definirEstoque(int $id, int $estoque): void
    {
        if ($estoque < 0) {
            throw new DomainException('O estoque não pode ser negativo.');
        }
        $stmt = $this->pdo->prepare('UPDATE livros SET estoque = :estoque, atualizado_em = CURRENT_TIMESTAMP WHERE id = :id');
        $stmt->execute(['estoque' => $estoque, 'id' => $id]);
    }
}
