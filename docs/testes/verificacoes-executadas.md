# Registro de verificações

Verificações realizadas em **06/11/2026**, sobre a aplicação do commit-base `1b41f900196b0abc582dbba82943d862f41e9f7c`. Este registro trata dos arquivos, scripts e materiais técnicos. Os testes manuais da matriz permanecem pendentes.

## Ambiente

Windows 11 (versão reportada: 10.0.26300.0), PHP 8.2.12 do XAMPP, PowerShell 7.6.9, Python 3.15.2 e draw.io Desktop 32.6.10. Python e draw.io foram usados apenas nos desenhos; não são necessários para executar o sistema.

## Resultados

| Verificação | Resultado |
| --- | --- |
| Estrutura | 61 arquivos obrigatórios e 14 diretórios presentes |
| Sintaxe PHP | 19 arquivos sem erros, incluindo a configuração local |
| Sintaxe PowerShell | Cinco scripts sem erros de análise |
| Requisitos e código | RF01 a RF05 relacionados às páginas, ações e métodos existentes |
| Classes e banco | Cinco classes e 17 colunas conferidas com o código, o MER e o dicionário |
| Referências locais | Links, includes reconhecidos, formulários e recursos encontrados |
| Desenhos | Oito PNGs exportados pelo draw.io e abertos para revisão; modelo embutido igual ao editável |
| Arquivos para publicação | 64 arquivos selecionados, excluindo configuração local, temporários e pacotes; nenhum padrão de credencial encontrado nos textos |
| Pacotes | Dois ZIPs gerados, extraídos e conferidos por tamanho e SHA-256 |

O verificador terminou com **zero falhas e três grupos não verificados**: operações no banco, avaliação visual/acessibilidade e conferência de URLs externas ou informações em imagens. Esses itens dependem de testes ou revisão separados. As imagens foram abertas para revisão, mas essa leitura não é feita automaticamente pelo script.

Também foram testados os validadores: uma amostra sintética foi detectada pelo scanner; uma diferença entre PNG e editável foi rejeitada em cópia de teste; e a ausência de PHP foi informada como não verificada. A aplicação e o banco não foram alterados por esses testes.

## Comandos executados

Na raiz do projeto, pelo PowerShell:

```powershell
python .\scripts\gerar-modelos.py
& .\scripts\exportar-modelos.ps1
& .\scripts\verificar-projeto.ps1
& .\scripts\gerar-pacotes.ps1
& .\scripts\testar-validadores.ps1
git diff --check
```

Os resultados detalhados são gerados em `dist/verificacao-projeto.json` e `dist/pacotes.json`. Os PNGs têm resolução entre 2922 × 2262 e 4102 × 2042 pixels; o de sequência tem 4022 × 3882 pixels e os quatro protótipos, 3002 × 2622 pixels cada.

## Pendências

- Executar e preencher os testes manuais da [matriz](matriz-testes.md).
- Conferir a instalação final no Apache, a navegação por teclado e o uso em celular.
- Acrescentar as 12 capturas descritas nas [instruções de evidências](../evidencias/INSTRUCOES.md).
- Conferir as figuras no relatório e a formatação exigida pela instituição.
