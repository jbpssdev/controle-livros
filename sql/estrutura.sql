-- MariaDB 10.2.1+ ou MySQL 8.0.16+: CHECK deve ser efetivamente aplicado.
-- Não remove nem substitui dados existentes. Não é uma migração de esquemas antigos.
CREATE DATABASE IF NOT EXISTS controle_livros
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE controle_livros;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS categorias (
    id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_categorias_nome UNIQUE (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS livros (
    id INT NOT NULL AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NULL,
    preco DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estoque INT NOT NULL DEFAULT 0,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_livros_categoria (categoria_id),
    INDEX idx_livros_titulo (titulo),
    INDEX idx_livros_autor (autor),
    INDEX idx_livros_isbn (isbn),
    CONSTRAINT fk_livros_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ck_livros_titulo CHECK (CHAR_LENGTH(TRIM(titulo)) > 0),
    CONSTRAINT ck_livros_autor CHECK (CHAR_LENGTH(TRIM(autor)) > 0),
    CONSTRAINT ck_livros_preco CHECK (preco >= 0),
    CONSTRAINT ck_livros_estoque CHECK (estoque >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS movimentacoes (
    id INT NOT NULL AUTO_INCREMENT,
    livro_id INT NOT NULL,
    tipo ENUM('entrada', 'saida') NOT NULL,
    quantidade INT NOT NULL,
    observacao VARCHAR(255) NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_movimentacoes_livro_data (livro_id, criado_em, id),
    INDEX idx_movimentacoes_data (criado_em, id),
    CONSTRAINT fk_movimentacoes_livro FOREIGN KEY (livro_id) REFERENCES livros (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ck_movimentacoes_tipo CHECK (tipo IN ('entrada', 'saida')),
    CONSTRAINT ck_movimentacoes_quantidade CHECK (quantidade > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categorias de referência: permitem cadastrar livros sem importar demonstrações.
INSERT INTO categorias (nome) VALUES
    ('Literatura'), ('História'), ('Ciências'), ('Tecnologia'), ('Outros')
ON DUPLICATE KEY UPDATE nome = VALUES(nome);
