# Dicionário de dados

Fonte única do esquema: [sql/estrutura.sql](../../sql/estrutura.sql). Este documento descreve o esquema declarado, não uma inspeção de dados de produção. Banco `controle_livros`, engine **InnoDB**, charset **utf8mb4**, collation **utf8mb4_unicode_ci**. INT é assinado (não foi declarado UNSIGNED). VARCHAR expressa limite de caracteres; DECIMAL indica precisão e escala. Datas são DATETIME sem precisão fracionária declarada.

## categorias

| Coluna | Tipo SQL | Tamanho / precisão | NULL | Padrão declarado | Chave | Descrição e restrições |
| --- | --- | --- | --- | --- | --- | --- |
| id | INT | inteiro de 32 bits | Não | Sem DEFAULT; AUTO_INCREMENT | PK | Identificador gerado pelo banco |
| nome | VARCHAR(100) | 100 caracteres | Não | Não declarado | UNIQUE | Nome obrigatório; unicidade `uq_categorias_nome`, conforme a collation. O SQL não inclui CHECK de texto não vazio para esta coluna |

Índices: `PRIMARY (id)` e índice único gerado pela constraint `uq_categorias_nome (nome)`. O script inclui cinco categorias de referência com INSERT ON DUPLICATE KEY UPDATE; não há CRUD de categorias na interface.

## livros

| Coluna | Tipo SQL | Tamanho / precisão | NULL | Padrão declarado | Chave | Descrição e restrições |
| --- | --- | --- | --- | --- | --- | --- |
| id | INT | inteiro de 32 bits | Não | Sem DEFAULT; AUTO_INCREMENT | PK | Identificador do livro |
| categoria_id | INT | inteiro de 32 bits | Não | Não declarado | FK | Referência obrigatória a `categorias.id` |
| titulo | VARCHAR(200) | 200 caracteres | Não | Não declarado | — | `ck_livros_titulo`: `CHAR_LENGTH(TRIM(titulo)) > 0` |
| autor | VARCHAR(150) | 150 caracteres | Não | Não declarado | — | `ck_livros_autor`: `CHAR_LENGTH(TRIM(autor)) > 0` |
| isbn | VARCHAR(20) | 20 caracteres | Sim | Não declarado; omissão admite NULL | — | Identificador opcional da edição; não possui UNIQUE nem validação de dígito verificador. A aplicação converte campo vazio para NULL |
| preco | DECIMAL(10,2) | 10 dígitos, 2 decimais | Não | 0.00 | — | `ck_livros_preco`: `preco >= 0`; até 99999999,99 na aplicação |
| estoque | INT | inteiro de 32 bits | Não | 0 | — | `ck_livros_estoque`: `estoque >= 0`; máximo 2147483647 |
| criado_em | DATETIME | data e hora, sem frações declaradas | Não | CURRENT_TIMESTAMP | — | Momento do cadastro; não é editado pela interface |
| atualizado_em | DATETIME | data e hora, sem frações declaradas | Não | CURRENT_TIMESTAMP | — | `ON UPDATE CURRENT_TIMESTAMP`; UPDATEs da aplicação também atribuem CURRENT_TIMESTAMP explicitamente |

Índices declarados: `PRIMARY (id)`, `idx_livros_categoria (categoria_id)`, `idx_livros_titulo (titulo)`, `idx_livros_autor (autor)` e `idx_livros_isbn (isbn)`. Os três últimos não garantem aceleração da busca `%termo%`.

Chave estrangeira: `fk_livros_categoria`, de `categoria_id` para `categorias(id)`, com **ON UPDATE RESTRICT / ON DELETE RESTRICT**.

## movimentacoes

| Coluna | Tipo SQL | Tamanho / precisão | NULL | Padrão declarado | Chave | Descrição e restrições |
| --- | --- | --- | --- | --- | --- | --- |
| id | INT | inteiro de 32 bits | Não | Sem DEFAULT; AUTO_INCREMENT | PK | Identificador do movimento |
| livro_id | INT | inteiro de 32 bits | Não | Não declarado | FK | Referência obrigatória a `livros.id` |
| tipo | ENUM('entrada', 'saida') | dois valores permitidos | Não | Não declarado | — | `ck_movimentacoes_tipo`: `tipo IN ('entrada', 'saida')` |
| quantidade | INT | inteiro de 32 bits | Não | Não declarado | — | `ck_movimentacoes_quantidade`: `quantidade > 0`; limite do INT também é validado na aplicação |
| observacao | VARCHAR(255) | 255 caracteres | Sim | Não declarado; omissão admite NULL | — | Texto opcional; vazio normalizado para NULL pelo serviço |
| criado_em | DATETIME | data e hora, sem frações declaradas | Não | CURRENT_TIMESTAMP | — | Momento de registro; apresentado em dia/mês/ano e hora |

Índices declarados: `PRIMARY (id)`, `idx_movimentacoes_livro_data (livro_id, criado_em, id)` e `idx_movimentacoes_data (criado_em, id)`.

Chave estrangeira: `fk_movimentacoes_livro`, de `livro_id` para `livros(id)`, com **ON UPDATE RESTRICT / ON DELETE RESTRICT**.

## Relacionamentos e integridade

- Uma categoria participa de **zero a muitos livros**; cada livro pertence a **exatamente uma categoria**. A categoria pode existir sem livro.
- Um livro participa de **zero a muitas movimentações**; cada movimentação pertence a **exatamente um livro**. Cadastro com estoque zero pode não ter movimento.
- Não há exclusão em cascata. As FKs impedem referências órfãs; as CHECKs precisam de versão de banco que as aplique (MariaDB 10.2.1+ ou MySQL 8.0.16+ conforme requisito do projeto).
- A igualdade `estoque = soma(entradas) − soma(saídas)` é mantida pelo [serviço e suas transações](../../src/AcervoService.php), não por uma CHECK entre tabelas ou trigger do esquema. Não existem triggers no SQL entregue.
- A conexão define `time_zone = '-03:00'`; o helper PHP usa America/Fortaleza. DATETIME não guarda identificador de fuso. Importações SQL fora da aplicação usam o fuso da sessão de quem importa.
- SQL não declara validação estrutural do ISBN, índice de unicidade em ISBN, usuários ou tabelas de autenticação. O [MER](../diagramas/mer.png) contém somente estas três tabelas e as 17 colunas acima.
