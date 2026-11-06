<?php
declare(strict_types=1);

final class AcervoService
{
    private Livro $livros;
    private Categoria $categorias;
    private Movimentacao $movimentacoes;

    public function __construct(private PDO $pdo)
    {
        $this->livros = new Livro($pdo);
        $this->categorias = new Categoria($pdo);
        $this->movimentacoes = new Movimentacao($pdo);
    }

    private function validarDados(array $dados): array
    {
        $limites = ['titulo' => 200, 'autor' => 150, 'isbn' => 20];
        $nomes = ['titulo' => 'Título', 'autor' => 'Autor', 'isbn' => 'ISBN'];
        $validos = [];
        foreach ($limites as $campo => $limite) {
            if (!isset($dados[$campo]) || !is_string($dados[$campo])) {
                throw new DomainException('Preencha os dados do livro corretamente.');
            }
            $valor = trim($dados[$campo]);
            if (!mb_check_encoding($valor, 'UTF-8') || mb_strlen($valor, 'UTF-8') > $limite) {
                throw new DomainException($nomes[$campo] . ' deve ter no máximo ' . $limite . ' caracteres válidos.');
            }
            if ($campo !== 'isbn' && $valor === '') {
                throw new DomainException($nomes[$campo] . ' é obrigatório.');
            }
            $validos[$campo] = $valor === '' ? null : $valor;
        }
        $categoria = filter_var($dados['categoria_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'max_range' => 2147483647]]);
        if ($categoria === false || !$this->categorias->existe($categoria)) {
            throw new DomainException('Selecione uma categoria válida.');
        }
        $preco = $dados['preco'] ?? null;
        if (!is_string($preco) || !preg_match('/\A\d{1,8}(?:[.,]\d{1,2})?\z/', trim($preco))) {
            throw new DomainException('Informe um preço entre 0 e 99999999,99, com até duas casas decimais.');
        }
        $validos['preco'] = str_replace(',', '.', trim($preco));
        $validos['categoria_id'] = $categoria;
        return $validos;
    }

    public function cadastrarLivro(array $dados, int $estoqueInicial): int
    {
        if ($estoqueInicial < 0 || $estoqueInicial > 2147483647) {
            throw new DomainException('Informe um estoque inicial válido, maior ou igual a zero.');
        }
        $validos = $this->validarDados($dados);
        $this->pdo->beginTransaction();
        try {
            $id = $this->livros->cadastrar($validos);
            if ($estoqueInicial > 0) {
                $this->livros->definirEstoque($id, $estoqueInicial);
                $this->movimentacoes->registrar($id, 'entrada', $estoqueInicial, 'Estoque inicial do cadastro');
            }
            $this->pdo->commit();
            return $id;
        } catch (Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }

    public function atualizarLivro(int $id, array $dados): void
    {
        $validos = $this->validarDados($dados);
        if ($this->livros->buscar($id) === null) {
            throw new DomainException('Livro não encontrado.');
        }
        $this->livros->atualizar($id, $validos);
    }

    public function movimentar(int $livroId, string $tipo, int $quantidade, ?string $observacao): void
    {
        if (!in_array($tipo, ['entrada', 'saida'], true)) {
            throw new DomainException('Selecione entrada ou saída.');
        }
        if ($quantidade < 1 || $quantidade > 2147483647) {
            throw new DomainException('Informe uma quantidade inteira maior que zero.');
        }
        $observacao = $observacao === null ? null : trim($observacao);
        if ($observacao !== null && (!mb_check_encoding($observacao, 'UTF-8') || mb_strlen($observacao, 'UTF-8') > 255)) {
            throw new DomainException('A observação deve ter no máximo 255 caracteres válidos.');
        }

        $this->pdo->beginTransaction();
        try {
            // O bloqueio é mantido até o commit; requisições concorrentes aguardam.
            $livro = $this->livros->buscar($livroId, true);
            if ($livro === null) {
                throw new DomainException('Livro não encontrado.');
            }
            $saldo = (int) $livro['estoque'];
            if ($tipo === 'saida' && $quantidade > $saldo) {
                throw new DomainException('Saída não permitida: o estoque disponível é de ' . $saldo . ' exemplar(es).');
            }
            $novoSaldo = $tipo === 'entrada' ? $saldo + $quantidade : $saldo - $quantidade;
            if ($novoSaldo > 2147483647) {
                throw new DomainException('A entrada excede o limite de exemplares por livro.');
            }
            $this->livros->definirEstoque($livroId, $novoSaldo);
            $this->movimentacoes->registrar($livroId, $tipo, $quantidade, $observacao === '' ? null : $observacao);
            $this->pdo->commit();
        } catch (Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }
}
