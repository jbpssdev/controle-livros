# Verificações executadas nesta etapa

Execuções realizadas em **06/11/2026**, na cópia `D:\CODE\Projeto Integrado (Faculdade)\controle-livros`. Base da aplicação: commit `1b41f900196b0abc582dbba82943d862f41e9f7c`, branch `main`, origin preservado. Este registro cobre a complementação documental atual; não transforma as verificações da implementação feitas em uma etapa anterior em aprovação manual desta matriz.

## Ambiente efetivamente utilizado

- Windows do ambiente fornecido pelo usuário; versão reportada pelo runtime: `Microsoft Windows NT 10.0.26300.0`.
- PowerShell **7.6.9**; PHP CLI **8.2.12**, executável do XAMPP `C:\xampp\php\php.exe`.
- Python **3.15.2**, usando somente `pathlib`, `html` e `xml.etree.ElementTree` na geração dos modelos.
- draw.io Desktop **32.6.10**, distribuição portátil obtida do [repositório oficial](https://github.com/jgraph/drawio-desktop/releases/tag/v32.6.10). Executável dentro de `.runtime/ferramentas/drawio`; não incluído nos pacotes e não exigido pela aplicação.
- PNGs decodificados com System.Drawing no Windows; modelos embutidos descompactados com DeflateStream e comparados como XML.
- Nenhuma conexão com banco de dados aberta por estes scripts; nenhum SQL de importação, INSERT, UPDATE, DELETE ou alteração de estrutura executado nesta etapa.

## Comandos executados e resultados

Comandos na raiz do projeto, em PowerShell:

```powershell
python .\scripts\gerar-modelos.py
& .\scripts\exportar-modelos.ps1
& .\scripts\verificar-projeto.ps1
& .\scripts\gerar-pacotes.ps1
& .\scripts\testar-validadores.ps1
git diff --check
git diff --name-only -- src public config sql tests assets layouts index.php
git status --short --branch
git remote -v
git rev-parse HEAD
```

| Verificação real | Resultado observado | Alcance e limite |
| --- | --- | --- |
| Geração de fontes | Oito arquivos `.drawio` com células, textos e conexões | São modelos editáveis; não imagens de evidência |
| Exportação oficial | Oito PNGs produzidos pelo draw.io; escala 2, borda 20, página completa, tema claro e XML embutido | Exportação real da ferramenta, não bitmap substituto |
| Árvore obrigatória | 61 arquivos exigidos pelo verificador e 14 diretórios presentes | A configuração privada não é exigida em uma distribuição |
| PHP | 19 arquivos lintados, sem erro de sintaxe, incluindo configuração local quando presente | `php -l` não executa a aplicação nem prova o banco |
| PowerShell | Cinco scripts `.ps1` aceitos pelo parser, incluindo a rotina de ensaio dos validadores | Exportação, verificação, empacotamento e ensaio também foram efetivamente executados |
| Rastreabilidade | RF01–RF05 vinculados às páginas, ações e métodos existentes | Conferência estrutural; não é aceitação funcional pelo usuário |
| Classes e esquema | Cinco classes, métodos declarados, 17 colunas/tipos e nomes de índices/constraints encontrados na documentação correspondente | Cardinalidades, visibilidades e a ordem da sequência também foram comparadas com código/SQL durante a revisão documental |
| Referências | Links Markdown locais, includes estáticos reconhecidos, destinos de formulários e assets existentes | Não valida automaticamente todos os destinos calculados por qualquer expressão PHP nem disponibilidade futura de URLs externas |
| Imagens | Oito PNGs decodificados e modelo XML embutido idêntico ao `.drawio` correspondente | Não é comprovação de funcionamento das telas |
| Publicação | 64 arquivos publicáveis selecionados, sem configuração local, runtime, `.git`, `.env`, ZIPs ou SQL fora da lista permitida | Scanner textual heurístico sem padrões sensíveis reconhecidos; não é prova de inexistência de informações particulares |
| Pacotes | Dois ZIPs criados; todas as entradas lidas e comparadas por tamanho/SHA-256; extração real comparada aos manifestos | Conteúdo na raiz, sem encapsulamento redundante; manifesto interno conferido com o externo |
| Preservação | Diff vazio para PHP operacional, SQL, assets e testes originais; HEAD e origin mantidos | Apenas documentação, scripts, README e regras de exclusão compõem esta complementação |
| Git | `git diff --check` sem erros; mudanças ainda não commitadas nem enviadas | Nenhum push, force push, reset ou troca de remote nesta etapa |

O resultado final do verificador da cópia completa é **zero falhas objetivas e três categorias NAO_VERIFICADO**. O JSON reproduzível é gerado em `dist/verificacao-projeto.json`; o resumo dos pacotes, seus tamanhos e hashes ficam em `dist/pacotes.json`. Esses arquivos são artefatos gerados e não são versionados. O script não usa “aprovado” para substituir verificações que não executa.

## Ensaios específicos dos validadores

Foi executado [testar-validadores.ps1](../../scripts/testar-validadores.ps1), após gerar os pacotes:

1. Uma sequência sintética com prefixo reconhecível foi detectada pelo scanner; o texto limpo não produziu achado. O valor de ensaio não é uma credencial válida e não é publicado.
2. Um rótulo do `.drawio` foi alterado **somente na cópia extraída em dist**, mantendo o PNG anterior. O verificador rejeitou a divergência com `FALHA`. A cópia foi restaurada em `finally`; a fonte original não foi alterada pelo ensaio.
3. Um caminho inexistente de PHP foi informado explicitamente. O lint foi marcado **NAO_VERIFICADO**, sem aprovação presumida. Os logs e JSONs de ensaio ficam em `dist/testes-validadores`.

Esses ensaios testam os scripts documentais, não RFs de cadastro ou estoque. A cópia extraída foi novamente atualizada e conferida quando os pacotes finais foram regenerados.

## Revisão visual efetivamente feita

As oito imagens foram abertas e inspecionadas nesta etapa: nomes, legibilidade, alinhamento, bordas, campos e setas. Foram ajustadas as posições dos rótulos das mensagens da sequência para não ocultarem as setas, e as exportações foram repetidas. Os protótipos usam marcadores simbólicos, sem apresentar registros fictícios como dados reais.

| Modelo | Dimensões reais do PNG |
| --- | --- |
| Casos de uso | 2922 × 2262 px |
| Classes | 3802 × 2602 px |
| MER | 4102 × 2042 px |
| Sequência | 4022 × 3882 px |
| Catálogo, cadastro, edição e movimentações | 3002 × 2622 px cada |

A categoria visual permanece NAO_VERIFICADO no script porque ele não realiza revisão visual por si próprio. A revisão assistida aqui registrada não substitui a conferência final do estudante no tamanho em que cada figura será inserida no relatório.

## Pendências reais

- **Testes funcionais/manuais desta matriz:** não executados nesta etapa; resultados obtidos e evidências permanecem em branco e status pendente.
- **Banco local e instalação final no Apache:** não consultados nem alterados nesta complementação. A informação de que a aplicação funciona localmente foi fornecida pelo usuário, não revalidada aqui.
- **Acessibilidade completa, teclado/leitor de tela, operação offline:** nova execução manual pendente; análise de HTML/CSS não comprova conformidade integral.
- **Capturas reais:** os 12 nomes previstos são um checklist, não arquivos PNG produzidos nesta pasta de evidências.
- **Privacidade em imagens, autenticidade de evidências e URLs externas futuras:** revisão humana/consulta específica necessária; não existe OCR nem verificação de rede nos scripts.
- **Modelo oficial do AVA e relatório final:** ainda dependem do fornecimento/conferência e preenchimento pessoal do estudante.
