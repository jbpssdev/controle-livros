# Requisitos não funcionais

| ID | Requisito | Implementação |
| --- | --- | --- |
| RNF01 | Interface clara, responsiva e acessível | Páginas em português, campos com rótulos, foco visível e layout adaptável a telas menores |
| RNF02 | Validação e segurança dos dados | Validação no servidor, consultas PDO com parâmetros, escape de HTML e token CSRF nos formulários |
| RNF03 | Mensagens claras | Retorno de sucesso, validação, ausência de resultados e erro de conexão sem mostrar credenciais |
| RNF04 | Funcionamento local | Execução no XAMPP, com Bootstrap incluído no projeto e sem serviços externos |
| RNF05 | Consistência do estoque | Atualização do saldo e registro do histórico na mesma transação, com bloqueio do livro durante a movimentação |

## Verificação

Os recursos acima foram conferidos no código. O [registro de verificações](../testes/verificacoes-executadas.md) apresenta os testes automáticos realizados. A avaliação das telas, das mensagens e das operações na aplicação deve ser registrada na [matriz](../testes/matriz-testes.md), incluindo o uso por teclado e em celular.

O sistema é destinado a uso local, sem autenticação e sem paginação. As alterações de estoque devem ser feitas pela interface de movimentações.

## Arquivos relacionados

- [Sessão, validações HTTP e mensagens](../../src/bootstrap.php).
- [Regras do acervo e transações](../../src/AcervoService.php).
- [Tabelas e restrições](../../sql/estrutura.sql).
- [Cabeçalho](../../layouts/header.php) e [CSS](../../assets/css/style.css).
