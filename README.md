# Sistema de Controle de Livros Usados

Projeto acadêmico para controlar um pequeno acervo de livros usados. O sistema permite cadastrar livros, consultar o estoque e registrar entradas e saídas de exemplares.

## Funcionalidades

- Cadastro de livros com título, autor, categoria, ISBN, preço e estoque inicial.
- Pesquisa por título, autor ou ISBN.
- Edição dos dados cadastrais.
- Registro de entradas e saídas, sem permitir estoque negativo.
- Consulta do histórico de movimentações, com filtro por livro.

O estoque é alterado pelas movimentações. Quando o cadastro tem uma quantidade inicial, o sistema registra a entrada no histórico.

## Tecnologias

- PHP 8.2 ou superior, com PDO e extensão mbstring.
- MariaDB 10.2.1+ ou MySQL 8.0.16+.
- HTML, CSS, JavaScript e Bootstrap 5.3.
- XAMPP para execução local.

O Bootstrap está incluído no projeto. Não é necessário instalar pacotes ou usar internet para acessar o sistema localmente.

## Como executar

1. Copie o projeto para `C:\xampp\htdocs\controle-livros`, sem as pastas `.git`, `.runtime` e `dist`.
2. No painel do XAMPP, inicie **Apache** e **MySQL**.
3. Acesse [phpMyAdmin](http://localhost/phpmyadmin/) e importe `sql/estrutura.sql`. O script cria o banco `controle_livros`, as tabelas e as categorias iniciais.
4. Se `config/database.php` ainda não existir, faça uma cópia de `config/database.example.php` com esse nome.
5. Confira a conexão em `config/database.php`: host `localhost`, porta `3306`, banco `controle_livros`, usuário `root` e senha vazia. Ajuste os valores se o seu XAMPP usar outra configuração.
6. Abra [http://localhost/controle-livros/](http://localhost/controle-livros/).

Para carregar livros de exemplo, importe também `sql/exemplos.sql`. Os registros são identificados como demonstração e essa importação é opcional. Se já houver um banco com o mesmo nome, confira sua estrutura e faça backup antes de importar.

O arquivo `config/database.php` fica fora do Git para preservar a configuração local.

## Pastas do projeto

| Pasta | Conteúdo |
| --- | --- |
| `config/` | Configuração da conexão com o banco |
| `src/` | Classes PHP e funções compartilhadas |
| `public/` | Páginas e ações dos formulários |
| `layouts/` | Cabeçalho e rodapé |
| `assets/` | CSS, JavaScript e Bootstrap |
| `sql/` | Estrutura do banco e dados de exemplo |
| `tests/` | Diagnóstico do ambiente e plano de testes |
| `docs/` | Documentação do trabalho |
| `scripts/` | Verificação do projeto, exportação dos desenhos e geração de ZIPs |

## Testes e documentação

Confira a instalação pelo [diagnóstico do ambiente](http://localhost/controle-livros/tests/check-env.php). Depois, siga o [plano de testes](tests/plano-testes.md) e registre os resultados na [matriz](docs/testes/matriz-testes.md).

Os requisitos, diagramas, protótipos e orientações para o relatório estão no [índice da documentação](docs/README.md). As capturas da aplicação devem ser salvas conforme as [instruções de evidências](docs/evidencias/INSTRUCOES.md).

## Limitações

- Uso local, sem login de usuários.
- Categorias cadastradas pelo SQL, sem gerenciamento pela interface.
- Catálogo e histórico sem paginação, voltados a um acervo pequeno.
