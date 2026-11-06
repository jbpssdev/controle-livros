# Capturas reais a produzir pelo estudante

Esta pasta não contém prints de execução produzidos nesta etapa documental. Os desenhos de `docs/prototipos` e os diagramas não são evidências da aplicação e não devem ser renomeados para atender este checklist.

Antes de capturar: iniciar Apache e MySQL no XAMPP, confirmar qual instalação/banco será utilizado, usar dados autorizados de estudo e executar o cenário correspondente. Registrar data real, ambiente, operador, ID do livro e resultado na [matriz de testes](../testes/matriz-testes.md). Não preencher “aprovado” sem observar o resultado. Uma captura isolada não comprova todas as regras de um caso, principalmente concorrência e atomicidade.

| Feito | Nome esperado | Conteúdo da captura real | Relação com a matriz |
| --- | --- | --- | --- |
| [ ] | `01-catalogo.png` | Catálogo acessado no navegador com dados reais de estudo ou estado vazio legítimo | RF02 / CT03 |
| [ ] | `02-cadastro.png` | Formulário aberto com rótulos e campos | RF01 / CT01 |
| [ ] | `03-edicao.png` | Edição do livro escolhido e saldo somente leitura; documentar também o resultado após salvar | RF03 / CT07 |
| [ ] | `04-movimentacoes.png` | Formulário e histórico efetivamente consultado | RF04, RF05 / CT08 |
| [ ] | `05-cadastro-sucesso.png` | Mensagem real após POST válido e livro resultante | CT01 |
| [ ] | `06-pesquisa-existente.png` | Termo pesquisado e resultado correspondente | CT03 |
| [ ] | `07-pesquisa-inexistente.png` | Busca realmente sem correspondência e estado vazio | CT04 |
| [ ] | `08-validacao-cadastro.png` | Rejeição real de título ausente; indicar se validação HTML ou servidor | CT02 |
| [ ] | `09-entrada-estoque.png` | Mensagem, novo saldo e entrada real no histórico | CT05 |
| [ ] | `10-saida-bloqueada.png` | Rejeição de retirada superior ao saldo; complementar com antes/depois | CT06 |
| [ ] | `11-banco-livros.png` | Consulta de leitura da tabela livros no phpMyAdmin, referente ao mesmo livro de teste | CT01 / CT07 |
| [ ] | `12-banco-movimentacoes.png` | Consulta de leitura dos movimentos do livro utilizado | CT05 / CT08 |

## Cuidados na coleta

- Capturar a execução real, com enquadramento legível e contexto suficiente para identificar a página e a mensagem. Não montar telas, inserir mensagens por edição de imagem ou simular resultados no HTML.
- Não incluir senha, token CSRF, cookie de sessão, dados pessoais, abas privadas ou credenciais do phpMyAdmin. Evite capturar o arquivo de configuração ou a seção de variáveis privadas do inspetor.
- Não alterar os dados diretamente no banco para fabricar um resultado; as duas últimas capturas são de **leitura**. Se detectar erro, documente-o e descreva o que foi observado.
- Um caso pode exigir mais de uma captura. Use sufixos claros (por exemplo, `10-saida-bloqueada-antes.png` e `10-saida-bloqueada-depois.png`) e liste ambos na matriz.
- O campo “Evidência correspondente” só deve receber o nome de arquivo depois de a imagem realmente existir. Não criar arquivos vazios com os nomes acima.

## Repositório e pacotes

O `.gitignore` preserva `INSTRUCOES.md` e `.gitkeep`, mas mantém as capturas fora do Git por padrão. Os pacotes são regeneráveis e incluem capturas PNG/JPEG reais presentes nesta pasta após revisão humana. Revise privacidade e autenticidade antes de gerar ZIPs; o scanner automático não lê conteúdo visual.

Depois de acrescentar as capturas e preencher a matriz, execute `pwsh -NoProfile -File .\scripts\verificar-projeto.ps1` e `pwsh -NoProfile -File .\scripts\gerar-pacotes.ps1` na raiz. Os ZIPs antigos são substituídos pelos novos pacotes, sem alterar a aplicação ou o banco.
