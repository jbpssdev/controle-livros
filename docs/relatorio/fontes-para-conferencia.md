# Fontes oficiais efetivamente consultadas

As páginas abaixo foram abertas durante esta complementação técnica em **06/11/2026** (data do ambiente do usuário). A data registra a consulta desta etapa; não deve ser apresentada como consulta pessoal do estudante sem que ele a realize. Não foram presumidas datas de publicação nem referências bibliográficas completas. Conferir os requisitos de referência da instituição antes da entrega.

| Organização / material | Endereço consultado | Utilização técnica |
| --- | --- | --- |
| PHP — PDO::prepare | [Manual oficial](https://www.php.net/manual/pt_BR/pdo.prepare.php) | Parâmetros, prepared statements e limites de reutilização de nomes em prepares nativos |
| PHP — Transações e auto-commit | [Manual oficial](https://www.php.net/manual/pt_BR/pdo.transactions.php) | Delimitação de transação, confirmação e reversão; base para ler o serviço existente |
| PHP — htmlspecialchars | [Manual oficial](https://www.php.net/manual/pt_BR/function.htmlspecialchars.php) | Escape dos dados usados em contexto HTML |
| MariaDB — FOR UPDATE | [Documentação oficial](https://mariadb.com/docs/server/reference/sql-statements/data-manipulation/selecting-data/for-update) | Bloqueio de linha em transação InnoDB; liberação do bloqueio ao encerrar a transação |
| MariaDB — CONSTRAINT | [Documentação oficial](https://mariadb.com/docs/server/reference/sql-statements/data-definition/constraint) | PK, FK, UNIQUE e CHECK representados no dicionário e MER |
| MySQL 8.0 — Locking Reads | [Manual oficial](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking-reads.html) | Referência da alternativa de banco prevista pelo projeto; não indica teste desta etapa em MySQL |
| Bootstrap 5.3 — Accessibility | [Documentação oficial](https://getbootstrap.com/docs/5.3/getting-started/accessibility/) | Recursos de acessibilidade exigem implementação e verificação; uso do framework não garante conformidade integral |
| draw.io — Export a diagram to a PNG image | [Manual oficial](https://www.drawio.com/docs/manual/export/export-to-png/) | Exportação real de PNG, escala, borda e inclusão de cópia editável |
| draw.io Desktop — opções de linha de comando, versão 32.6.10 | [Código oficial args.js](https://github.com/jgraph/drawio-desktop/blob/v32.6.10/src/main/args.js) | Opções `--export`, `--scale`, `--size`, `--embed-diagram` e formato PNG; ajuda do executável também consultada |
| draw.io Desktop — distribuição oficial | [Releases do projeto](https://github.com/jgraph/drawio-desktop/releases/tag/v32.6.10) | Distribuição portátil usada somente na geração documental; não é dependência da aplicação |

## Fontes primárias do próprio projeto

- [README](../../README.md), [requisitos inspecionados](../requisitos/requisitos-funcionais.md), [código](../codigo/funcionalidades-documentadas.md), [SQL](../../sql/estrutura.sql) e [plano existente](../../tests/plano-testes.md).
- Commit-base inspecionado: `1b41f900196b0abc582dbba82943d862f41e9f7c`, no [repositório existente](https://github.com/jbpssdev/controle-livros).

Não foram consultados documentos de uma organização usuária, entrevistas, pesquisas de campo ou um template oficial do AVA. Esses materiais não devem ser citados como se existissem.
