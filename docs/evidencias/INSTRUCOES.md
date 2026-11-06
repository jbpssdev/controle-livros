# Evidências dos testes

Capture as telas durante a execução da aplicação no XAMPP e registre os resultados na [matriz](../testes/matriz-testes.md). Os protótipos são desenhos das telas; esta pasta deve receber as capturas da aplicação.

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

## Orientações

- Deixe a página, os dados usados e a mensagem do teste legíveis.
- Não inclua senhas, cookies, tokens ou dados pessoais nas imagens.
- Nas capturas do phpMyAdmin, use consultas de leitura dos mesmos livros utilizados nos testes.
- Preencha o resultado e o status depois de executar o caso. Se precisar de mais de uma captura, acrescente um sufixo ao nome e registre os arquivos na matriz.

As imagens ficam fora do Git por padrão, mas entram nos ZIPs ao executar `pwsh -NoProfile -File .\scripts\gerar-pacotes.ps1`. Confira o conteúdo antes de distribuir os pacotes.
