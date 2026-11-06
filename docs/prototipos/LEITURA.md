# Protótipos das quatro páginas

Estes são modelos editáveis baseados no HTML/CSS existente. **Não são capturas do sistema funcionando** e não podem preencher a pasta de evidências. Os marcadores `〈...〉` representam dados vindos do banco; valores padrão zero e um reproduzem os valores iniciais dos formulários, não registros do acervo.

| Figura | Arquivos | Finalidade, campos e ações reais |
| --- | --- | --- |
| F05 — Catálogo | [editável](catalogo.drawio) / [PNG](catalogo.png) | Resumo de títulos/saldos, GET `busca`, botão Pesquisar, link Cadastrar livro e tabela com livro/autor/ISBN, categoria, preço, disponibilidade, Editar e Movimentar. A pesquisa altera também o conjunto contado nos resumos |
| F06 — Cadastro | [editável](cadastro.drawio) / [PNG](cadastro.png) | Título, autor, categoria, ISBN opcional, preço e estoque inicial; botões Cancelar e Cadastrar livro; link Voltar ao catálogo; bloco de orientação sobre entrada inicial |
| F07 — Edição | [editável](edicao.drawio) / [PNG](edicao.png) | Os mesmos dados cadastrais; estoque somente leitura e link para movimentação; Cancelar e Salvar alterações; ID e CSRF são ocultos e não desenhados como campos visuais |
| F08 — Movimentações | [editável](movimentacoes.drawio) / [PNG](movimentacoes.png) | Livro com saldo, tipo entrada/saída, quantidade, observação opcional e Registrar movimentação; GET do filtro por livro; histórico com data/livro, tipo, quantidade e observação; Filtrar e Ver catálogo |

## Relação com as páginas existentes

Fontes: [catálogo](../../public/index.php), [cadastro](../../public/novo-livro.php), [edição](../../public/editar-livro.php), [movimentações](../../public/movimentacoes.php), [cabeçalho](../../layouts/header.php) e [CSS](../../assets/css/style.css). A paleta verde/papel, a hierarquia de títulos, a navegação e a organização em painéis seguem a interface implementada. Os textos auxiliares foram abreviados em alguns pontos para permitir leitura do modelo; campos e ações são os reais.

Os modelos mostram o arranjo de desktop. Em telas pequenas, a implementação reorganiza colunas, empilha cartões de resumo e permite rolagem horizontal das tabelas. Isso deve ser conferido na aplicação, não inferido apenas destes desenhos.

## Estados condicionais que devem ser conferidos na aplicação

- Catálogo vazio, pesquisa sem resultados, pesquisa com Limpar pesquisa e falha de conexão têm mensagens próprias; não há registros fixos embutidos no HTML.
- Cadastro sem categorias desabilita campos e orienta importar a estrutura. Mensagens de validação/sucesso são temporárias, não textos fixos no protótipo.
- ID de edição inexistente produz 404 e não exibe formulário válido.
- Sem livros, a movimentação é desabilitada. Filtro específico oferece Ver todos os livros. Sem histórico, aparece estado vazio.
- A saída acima do saldo é rejeitada pelo servidor. O protótipo não simula uma retirada nem comprova a regra.

Para editar e exportar, siga [a instrução comum dos diagramas](../diagramas/LEITURA.md). Para evidências reais, siga [o checklist separado](../evidencias/INSTRUCOES.md).
