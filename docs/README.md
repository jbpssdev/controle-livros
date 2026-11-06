# Documentação do projeto

Materiais do Sistema de Controle de Livros Usados, organizados pelas etapas do trabalho.

| Etapa | Documentos |
| --- | --- |
| Requisitos | [Funcionais](requisitos/requisitos-funcionais.md), [não funcionais](requisitos/requisitos-nao-funcionais.md) e [casos de uso](requisitos/casos-de-uso.md) |
| Modelagem | [Diagramas](diagramas/LEITURA.md) e [dicionário de dados](modelagem/dicionario-dados.md) |
| Prototipagem | [Quatro telas do sistema](prototipos/LEITURA.md) |
| Desenvolvimento | [Cadastro, consulta e movimentação](codigo/funcionalidades-documentadas.md) |
| Testes | [Plano](../tests/plano-testes.md), [matriz de resultados](testes/matriz-testes.md) e [verificações realizadas](testes/verificacoes-executadas.md) |
| Evidências | [Lista das capturas necessárias](evidencias/INSTRUCOES.md) |
| Relatório | [Roteiro](relatorio/roteiro-preenchimento.md) e [referências técnicas](relatorio/fontes-para-conferencia.md) |

Os diagramas estão disponíveis em `.drawio` e PNG. Os protótipos representam a organização das telas; as evidências devem ser capturadas na aplicação em execução. Os resultados dos testes manuais continuam pendentes na matriz.

O plano de testes e a matriz têm numeração própria: o CT07 da matriz corresponde ao CT08 do plano. A correspondência está indicada em cada caso.

## Verificação e pacotes

Execute na raiz do projeto, pelo PowerShell:

```powershell
pwsh -NoProfile -File .\scripts\verificar-projeto.ps1
pwsh -NoProfile -File .\scripts\gerar-pacotes.ps1
```

Os ZIPs são salvos em `dist/`, com o projeto completo e com a documentação separada. A configuração local do banco e os arquivos temporários ficam fora dos pacotes e do Git. Os scripts não alteram o banco.

Para editar e exportar os desenhos, siga o [guia dos diagramas](diagramas/LEITURA.md).
