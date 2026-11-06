# Documentação técnica do acervo

Materiais de referência para estudo e reprodução do sistema existente. Não constituem relatório acadêmico, comprovação de autoria ou evidências de execução manual.

## Navegação

| Material | Arquivo |
| --- | --- |
| Requisitos funcionais e rastreabilidade | [requisitos-funcionais.md](requisitos/requisitos-funcionais.md) |
| Requisitos não funcionais e limites de verificação | [requisitos-nao-funcionais.md](requisitos/requisitos-nao-funcionais.md) |
| Descrições dos cinco casos de uso | [casos-de-uso.md](requisitos/casos-de-uso.md) |
| UML, MER e sequência: fontes e leitura | [LEITURA.md](diagramas/LEITURA.md) |
| Todas as colunas, índices e restrições | [dicionario-dados.md](modelagem/dicionario-dados.md) |
| Quatro protótipos e suas ações | [LEITURA.md](prototipos/LEITURA.md) |
| Fluxos técnicos e trechos reais | [funcionalidades-documentadas.md](codigo/funcionalidades-documentadas.md) |
| Matriz de execução manual | [matriz-testes.md](testes/matriz-testes.md) |
| Registro das verificações automáticas desta etapa | [verificacoes-executadas.md](testes/verificacoes-executadas.md) |
| Checklist das capturas futuras | [INSTRUCOES.md](evidencias/INSTRUCOES.md) |
| Orientações para o relatório do estudante | [roteiro-preenchimento.md](relatorio/roteiro-preenchimento.md) |
| Fontes oficiais efetivamente consultadas | [fontes-para-conferencia.md](relatorio/fontes-para-conferencia.md) |

## Escopo e versão inspecionada

Base: commit `1b41f900196b0abc582dbba82943d862f41e9f7c` da branch `main`. Foram inspecionados README, classes e helpers, páginas e ações, configurações (sem divulgar valores privados), SQL e testes. O repositório estava sem alterações locais no início desta etapa. Nenhum arquivo PHP operacional ou SQL foi alterado para produzir os documentos.

O código foi inspecionado em `D:\CODE\Projeto Integrado (Faculdade)\controle-livros`, cópia do workspace com `.git` e `origin` já configurados. O caminho de instalação previsto continua sendo `C:\xampp\htdocs\controle-livros`; a existência ou funcionamento dessa outra cópia não é presumida nesta documentação.

Os diagramas representam a implementação; os protótipos são desenhos de modelagem, com marcadores de campos e dados, nunca capturas reais. Use os PNGs como figuras técnicas e as fontes `.drawio` para editar. O gerador auxiliar e a exportação estão descritos em [LEITURA dos diagramas](diagramas/LEITURA.md).

## Divergências e decisões documentais

- Os identificadores CT07 e CT08 do [plano original](../tests/plano-testes.md) descrevem, respectivamente, quantidades/saída e edição. A nova matriz solicitou CT07 para edição e CT08 para histórico. O plano original foi preservado; a matriz registra a correspondência e declara seu próprio escopo de identificação.
- As classes `Livro`, `Categoria` e `Movimentacao` são classes de acesso aos dados, não entidades com propriedades de título ou saldo. O diagrama de classes representa os atributos PDO efetivamente declarados; o MER representa as colunas SQL separadamente.
- `Database` expõe um método estático e não declara atributo de conexão. `conexao()` mantém um PDO em variável estática local no helper; isso não foi convertido em atributo fictício.
- Categorias de referência são inseridas por `estrutura.sql`. Os livros fictícios dependem da importação opcional de `exemplos.sql`; não são parte obrigatória das telas.
- Não foram detectadas divergências que justificassem mudar a aplicação nesta etapa. Acessibilidade completa, instalação no Apache e testes manuais desta matriz continuam sujeitos à execução e ao registro do estudante.

## Reprodução

Na raiz do projeto, execute `pwsh -NoProfile -File .\scripts\verificar-projeto.ps1` e depois `pwsh -NoProfile -File .\scripts\gerar-pacotes.ps1`. Não há escrita no banco por esses scripts. Resultados automáticos não aprovam os casos manuais. ZIPs, manifestos de distribuição e temporários ficam em `dist/`, ignorado no Git.
