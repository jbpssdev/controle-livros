# Referências técnicas

Documentação oficial consultada em **06/11/2026**. Para o relatório, selecione as fontes utilizadas e ajuste as referências ao padrão da instituição.

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

## Arquivos do projeto

Consulte também o [código documentado](../codigo/funcionalidades-documentadas.md), a [estrutura do banco](../../sql/estrutura.sql) e o [plano de testes](../../tests/plano-testes.md).
