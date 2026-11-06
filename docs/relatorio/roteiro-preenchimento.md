# Roteiro para preenchimento pelo estudante

Este é um guia de organização técnica. **Não é o modelo oficial do AVA** e não é um relatório pronto. O roteiro institucional completo e o template de entrega ainda precisam ser conferidos pelo estudante. Os nomes de figuras e tabelas abaixo são sugestões de organização; ajuste numeração, formatação e referências ao modelo que a instituição fornecer.

## 1. Capa e sumário

- **Consultar:** modelo oficial da instituição quando disponível e [índice técnico](../README.md).
- **Figuras/tabelas:** nenhuma obrigatória nesta seção técnica; seguir o template institucional.
- **Elementos a preencher:** instituição, curso, disciplina, nome real do estudante, orientação se exigida, local e ano real; sumário coerente com as páginas finais.
- **Orientação:** não presumir nomes, matrículas, autoria exclusiva ou identificação de orientador. Não usar este guia como se fosse a capa do AVA.

## 2. Apresentação do tema

- **Consultar:** [README do sistema](../../README.md) e [requisitos funcionais](../requisitos/requisitos-funcionais.md).
- **Figuras:** opcionalmente F01 (casos de uso).
- **Tabela:** T01, síntese do problema, objetivo e limites do sistema, elaborada com base nos requisitos.
- **Elementos:** contexto do pequeno acervo, objetivo de estudo, tecnologias realmente utilizadas e escopo local sem autenticação.
- **Orientação:** descrever com suas palavras por que escolheu o tema e qual problema pretende estudar. Não inventar entrevista com responsável, levantamento de campo ou demanda de organização que não existiu.

## 3. Fase 1 — Requisitos

- **Consultar:** [RFs](../requisitos/requisitos-funcionais.md), [RNFs](../requisitos/requisitos-nao-funcionais.md) e [casos de uso](../requisitos/casos-de-uso.md).
- **Figura:** F01 — [casos de uso](../diagramas/casos-de-uso.png).
- **Tabelas:** T02 — RF01 a RF05; T03 — RNFs com critérios e estado de verificação; T04 — descrição dos casos de uso, se exigida.
- **Elementos:** ator, entradas/saídas, pré-condições, alternativas e limites do escopo.
- **Orientação:** explicar decisões que você efetivamente analisou; diferenciar requisito, implementação inspecionada e comportamento testado. Sem entrevistas fictícias ou aceitação não realizada.

## 4. Fase 2 — Modelagem

- **Consultar:** [leitura dos diagramas](../diagramas/LEITURA.md), [dicionário](../modelagem/dicionario-dados.md), [SQL](../../sql/estrutura.sql) e classes PHP.
- **Figuras:** F02 — [classes](../diagramas/classes.png); F03 — [MER](../diagramas/mer.png); F04 — [sequência](../diagramas/sequencia.png).
- **Tabela:** T05 — dicionário das 17 colunas, mais índices/FKs/CHECKs se o template separar essas informações.
- **Elementos:** responsabilidade das cinco classes, distinção entre classe e tabela, cardinalidades 1 para 0..*, chaves e fluxo transacional de movimentação com rollback.
- **Orientação:** conferir cada nome no código antes de inserir uma figura. Explique o bloqueio do livro com base no que compreendeu e testou; não alegue auditoria de concorrência sem execução.

## 5. Fase 3 — Prototipagem

- **Consultar:** [guia dos protótipos](../prototipos/LEITURA.md) e as quatro páginas de `public`.
- **Figuras:** F05 — [catálogo](../prototipos/catalogo.png); F06 — [cadastro](../prototipos/cadastro.png); F07 — [edição](../prototipos/edicao.png); F08 — [movimentações](../prototipos/movimentacoes.png).
- **Tabela:** T06 — campos, ações, estados condicionais e requisito de cada tela.
- **Elementos:** identificação explícita como protótipos; fluxo de navegação; campo de estoque somente leitura na edição; observação opcional e filtro do histórico.
- **Orientação:** descrever suas decisões e eventuais ajustes reais. Não apresentar esses desenhos como screenshots do sistema em execução.

## 6. Fase 4 — Desenvolvimento

- **Consultar:** [funcionalidades documentadas](../codigo/funcionalidades-documentadas.md), [AcervoService](../../src/AcervoService.php), [Livro](../../src/Livro.php), ações e [conexão PDO](../../src/Database.php).
- **Figuras:** F04 pode apoiar a explicação da transação; capturas reais de páginas somente depois da coleta.
- **Tabela:** T07 — responsabilidade de página, ação, serviço, repositório e tabela por funcionalidade.
- **Elementos:** pelo menos cadastro e consulta completos, trechos reais de código, SQL parametrizado, sessão/CSRF, escape HTML, PRG e limites conhecidos.
- **Orientação:** selecionar trechos pequenos e explicar sua finalidade. Conferir origem e assistência utilizada conforme as regras da instituição; não assumir autoria exclusiva ou experiências de programação que não vivenciou. Nunca anexar configuração com senha.

## 7. Fase 5 — Testes

- **Consultar:** [matriz](../testes/matriz-testes.md), [plano original](../../tests/plano-testes.md), [verificações automáticas](../testes/verificacoes-executadas.md) e [checklist de evidências](../evidencias/INSTRUCOES.md).
- **Figuras:** somente as 12 capturas reais listadas no checklist e complementos realmente produzidos; atribuir nova numeração após F08 se adequado.
- **Tabelas:** T08 — matriz com dados, procedimentos e resultados realmente obtidos; T09 — ambiente e comandos automáticos efetivamente executados.
- **Elementos:** data real, versões, base de estudo, resultados, falhas, status e evidências correspondentes; diferença entre lint/verificação documental e teste funcional.
- **Orientação:** executar os casos e preencher campos vazios. Deixar pendente o que não foi executado. Não transformar saída automática de arquivo existente em aprovação de todos os RFs ou RNFs.

## 8. Considerações finais

- **Consultar:** requisitos, matriz preenchida, limitações do README e observações pessoais registradas durante a atividade.
- **Figuras/tabelas:** nenhuma obrigatória; pode referenciar T08, sem criar resultados novos.
- **Elementos:** objetivos efetivamente alcançados, limitações observadas e próximos passos compatíveis com o escopo.
- **Orientação:** escrever a própria avaliação, os aprendizados e as dificuldades reais. Não inventar implantação, satisfação de usuários, ganho percentual ou conclusão de testes que ficaram pendentes.

## 9. Referências

- **Consultar:** [fontes para conferência](fontes-para-conferencia.md), materiais da disciplina e normas fornecidas pela instituição.
- **Figuras/tabelas:** listas separadas se o modelo oficial exigir; referências a todas as figuras/tabelas citadas.
- **Elementos:** apenas fontes realmente utilizadas; títulos, URLs e dados bibliográficos conferidos; data de acesso real do estudante quando exigida.
- **Orientação:** a lista técnica registra consultas desta complementação. Ela não prova que o estudante consultou pessoalmente cada fonte. Não inventar DOI, edição, local, data de publicação ou acesso.

## Conferência antes da entrega

- [ ] Obter e conferir modelo oficial e critérios do AVA.
- [ ] Conferir todas as figuras com os editáveis e o código atual.
- [ ] Executar e preencher resultados reais, sem status presumidos.
- [ ] Inserir capturas reais, com privacidade revisada.
- [ ] Conferir texto, citações, referências, sumário, legendas e numeração final.
- [ ] Regenerar os pacotes, revisar manifestos e testar a extração.
