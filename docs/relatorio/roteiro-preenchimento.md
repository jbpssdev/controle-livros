# Roteiro do relatório

Organize o texto conforme as seções abaixo e ajuste a formatação ao modelo da instituição. A numeração de figuras e tabelas é uma sugestão.

## 1. Capa e sumário

Inclua instituição, curso, disciplina, identificação, local e ano. Atualize o sumário depois de finalizar o documento, seguindo o modelo oficial.

## 2. Apresentação do tema

Apresente o controle de um pequeno acervo, o objetivo do sistema e as tecnologias usadas. Explique a escolha do tema e os limites do projeto. Consulte o [README](../../README.md) e os [requisitos funcionais](../requisitos/requisitos-funcionais.md).

Sugestão de tabela: resumo do objetivo e das funcionalidades.

## 3. Fase 1 — Requisitos

Descreva RF01 a RF05, os requisitos não funcionais e o responsável pelo acervo. Use as tabelas de [requisitos](../requisitos/requisitos-funcionais.md), [requisitos não funcionais](../requisitos/requisitos-nao-funcionais.md) e os [casos de uso](../requisitos/casos-de-uso.md).

Figura F01: [diagrama de casos de uso](../diagramas/casos-de-uso.png). Explique o que cada operação permite fazer.

## 4. Fase 2 — Modelagem

Apresente as classes PHP, as três tabelas e seus relacionamentos. Explique como uma movimentação atualiza o saldo e o histórico. Consulte o [dicionário de dados](../modelagem/dicionario-dados.md) e o [SQL](../../sql/estrutura.sql).

Figuras: F02 — [classes](../diagramas/classes.png); F03 — [MER](../diagramas/mer.png); F04 — [sequência](../diagramas/sequencia.png). Use o dicionário como tabela de campos, tipos e restrições.

## 5. Fase 3 — Prototipagem

Apresente os campos e as ações de cada tela, conforme o [guia dos protótipos](../prototipos/LEITURA.md).

Figuras: F05 — [catálogo](../prototipos/catalogo.png); F06 — [cadastro](../prototipos/cadastro.png); F07 — [edição](../prototipos/edicao.png); F08 — [movimentações](../prototipos/movimentacoes.png). Identifique essas figuras como protótipos. Uma tabela pode relacionar tela, campos e botões.

## 6. Fase 4 — Desenvolvimento

Explique pelo menos o cadastro e a consulta de livros. Mostre trechos curtos do código e descreva a função da página, da ação PHP e das classes envolvidas. Use a [documentação das funcionalidades](../codigo/funcionalidades-documentadas.md).

Inclua uma tabela relacionando funcionalidade, arquivos e tabelas do banco. A figura de sequência pode apoiar a explicação do estoque. Referencie código e recursos utilizados conforme as orientações de autoria e citação da instituição.

## 7. Fase 5 — Testes

Execute os casos da [matriz](../testes/matriz-testes.md), registre ambiente, dados, resultados e status, e acrescente as [capturas necessárias](../evidencias/INSTRUCOES.md). Consulte também o [plano de testes](../../tests/plano-testes.md) e o [registro de verificações](../testes/verificacoes-executadas.md).

Use a matriz como tabela de resultados e numere as capturas como novas figuras. Diferencie verificação de arquivos e sintaxe dos testes feitos na aplicação. Mantenha pendente o que não foi executado.

## 8. Considerações finais

Retome os objetivos, descreva os resultados observados, as limitações e o aprendizado durante a atividade. Baseie essa avaliação nos requisitos e na matriz preenchida.

## 9. Referências

Liste as fontes utilizadas no texto, com os dados exigidos pela instituição. Confira as [referências técnicas](fontes-para-conferencia.md), as legendas e a numeração das figuras e tabelas.

## Antes de entregar

- [ ] Conferir o modelo oficial, a formatação e o sumário.
- [ ] Revisar o texto e as referências.
- [ ] Preencher os testes executados e inserir as capturas correspondentes.
- [ ] Conferir os diagramas e as legendas.
- [ ] Gerar novamente os pacotes após as alterações.
