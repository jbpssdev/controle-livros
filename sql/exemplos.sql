-- OPCIONAL: somente para estudo. Todos os livros são fictícios e identificados.
-- Execute depois de estrutura.sql, uma importação por vez, sem edições simultâneas.
-- Reexecuções preservam os livros existentes e seus saldos, inclusive movimentações posteriores.
-- Os identificadores DEMO-* são reservados a este script, não são ISBNs comerciais.
USE controle_livros;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO categorias (nome) VALUES ('Literatura'), ('História'), ('Tecnologia')
ON DUPLICATE KEY UPDATE nome = VALUES(nome);

INSERT INTO livros (categoria_id, titulo, autor, isbn, preco, estoque)
SELECT id, '[DEMONSTRAÇÃO] Caminhos de Papel', 'Autora Fictícia', 'DEMO-LIVRO-001', 25.90, 3
FROM categorias WHERE nome = 'Literatura'
AND NOT EXISTS (SELECT 1 FROM livros WHERE isbn = 'DEMO-LIVRO-001');
SET @demo_livro_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);
INSERT INTO movimentacoes (livro_id, tipo, quantidade, observacao)
SELECT @demo_livro_id, 'entrada', 3, '[DEMONSTRAÇÃO] Estoque inicial fictício'
WHERE @demo_livro_id IS NOT NULL;

INSERT INTO livros (categoria_id, titulo, autor, isbn, preco, estoque)
SELECT id, '[DEMONSTRAÇÃO] Memórias de uma Cidade', 'Autor Fictício', 'DEMO-LIVRO-002', 18.50, 2
FROM categorias WHERE nome = 'História'
AND NOT EXISTS (SELECT 1 FROM livros WHERE isbn = 'DEMO-LIVRO-002');
SET @demo_livro_id = IF(ROW_COUNT() = 1, LAST_INSERT_ID(), NULL);
INSERT INTO movimentacoes (livro_id, tipo, quantidade, observacao)
SELECT @demo_livro_id, 'entrada', 2, '[DEMONSTRAÇÃO] Estoque inicial fictício'
WHERE @demo_livro_id IS NOT NULL;

INSERT INTO livros (categoria_id, titulo, autor, isbn, preco, estoque)
SELECT id, '[DEMONSTRAÇÃO] Primeiros Passos em Sistemas', 'Pessoa Autora Fictícia', 'DEMO-LIVRO-003', 32.00, 0
FROM categorias WHERE nome = 'Tecnologia'
AND NOT EXISTS (SELECT 1 FROM livros WHERE isbn = 'DEMO-LIVRO-003');

COMMIT;
SET @demo_livro_id = NULL;
