# Requisitos não funcionais

“Implementado no código” significa inspeção da implementação; não equivale a comprovação por usuário, auditoria ou aprovação de todos os cenários. Consulte o [registro automático desta etapa](../testes/verificacoes-executadas.md) para saber o que foi efetivamente executado.

| ID | Requisito e critério de aceitação | Característica observada no código | Verificação e pendência |
| --- | --- | --- | --- |
| RNF01 | Usabilidade, responsividade e acessibilidade: quatro páginas utilizáveis em desktop e celular; campos rotulados, foco e mensagens perceptíveis por teclado | `lang=pt-BR`, labels, link de salto, `aria-live`, `role=alert/status`, CSS com media queries, tabelas com rolagem e Bootstrap local | Inspeção estática possível. Nesta etapa documental não houve nova execução de navegação, leitor de tela ou auditoria WCAG. Executar CT15 e o CT13 do plano original. Não afirmar conformidade integral |
| RNF02 | Segurança e integridade: rejeitar entradas inválidas e gravações sem POST/CSRF; tratar dados como parâmetros; escapar saídas; evitar estoque negativo | PDO com prepares nativos, limites de campos no serviço, `e()` com `htmlspecialchars`, `protegerPost()`, cookies HttpOnly/SameSite, CSP, InnoDB, CHECK e `FOR UPDATE` | O script confere presença e rastreabilidade de partes da implementação e varre arquivos a publicar. A inspeção não é pentest nem prova de ausência de segredos. Executar CT09 a CT12. Banco local não é modificado nesta etapa |
| RNF03 | Mensagens claras: distinguir sucesso, validação, ausência de registros e indisponibilidade sem expor SQL/credenciais | Mensagens temporárias, campos preservados, redirecionamento 303, erros técnicos no log, 403 para CSRF, 405 para método, 404 para ID inválido e 503 nas páginas indisponíveis | Inspeção dos helpers e ações. Validação de compreensão e capturas reais pendentes em CT01, CT02, CT04 e CT06. Rejeição por método/CSRF encerra a ação diretamente, sem PRG |
| RNF04 | Execução local reproduzível: XAMPP/PHP 8.2+, MariaDB compatível, sem internet para operar o acervo | CSS Bootstrap 5.3.3 distribuído no repositório; JS opcional; PDO; configuração local ignorada no Git | Verificações estáticas e lint são reproduzíveis. Testar instalação no Apache, extensões e conexão no computador de entrega com `tests/check-env.php`. Ferramentas opcionais de desenho são apenas para a documentação |
| RNF05 | Atomicidade do estoque: saldo e histórico confirmados juntos; duas saídas não devem consumir o mesmo exemplar | Cadastro e movimentação controlados por `AcervoService`; transação com bloqueio do livro em `movimentar()`; rollback em exceção | Correspondência entre sequência e código inspecionada. A matriz deixa concorrência e falha induzida pendentes até execução em ambiente apropriado e isolado |

## Limites que não devem ser ocultados no relatório

Não existe autenticação. A aplicação deve permanecer em ambiente local confiável. A edição cadastral não possui controle de versão otimista. O CSRF não torna a operação idempotente. A listagem não é paginada. Edições manuais no banco podem romper a igualdade entre saldo e soma dos movimentos. O scanner de publicação é heurístico e não garante que um documento ou uma captura não contenha informação particular.

## Fontes locais

- [Helpers, sessão e mensagens](../../src/bootstrap.php).
- [Regras e transações](../../src/AcervoService.php).
- [Esquema e restrições](../../sql/estrutura.sql).
- [Cabeçalho compartilhado](../../layouts/header.php), [CSS próprio](../../assets/css/style.css) e [JavaScript opcional](../../assets/js/app.js).
- [Plano original](../../tests/plano-testes.md) e [matriz complementar](../testes/matriz-testes.md).
