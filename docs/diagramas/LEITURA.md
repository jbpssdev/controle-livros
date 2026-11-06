# Diagramas do sistema

| Figura | Editável | Imagem | Conteúdo |
| --- | --- | --- | --- |
| F01 — Casos de uso | [drawio](casos-de-uso.drawio) | [PNG](casos-de-uso.png) | Responsável pelo acervo e as cinco operações do sistema |
| F02 — Classes | [drawio](classes.drawio) | [PNG](classes.png) | Classes PHP, atributos, métodos e dependências |
| F03 — MER | [drawio](mer.drawio) | [PNG](mer.png) | Três tabelas, 17 colunas e relacionamentos |
| F04 — Sequência | [drawio](sequencia.drawio) | [PNG](sequencia.png) | Registro de uma movimentação e rejeição por estoque insuficiente |

Os desenhos seguem os [casos de uso](../requisitos/casos-de-uso.md), as classes de [acesso ao acervo](../../src/AcervoService.php) e o [SQL](../../sql/estrutura.sql).

## Como ler

- **Classes:** `+` indica método público, `−` indica atributo ou método privado, sublinhado indica método estático e `{leaf}` corresponde a uma classe `final` do PHP.
- **MER:** PK é chave primária, FK é chave estrangeira e UQ indica valor único. `1` significa exatamente um e `0..*`, zero ou vários. Consulte os detalhes no [dicionário](../modelagem/dicionario-dados.md).
- **Sequência:** as linhas verticais mostram os participantes; as setas indicam chamadas e retornos. O quadro `alt` separa o caso de estoque insuficiente da movimentação válida.

## Editar e exportar

Abra o `.drawio` no draw.io Desktop. Após editar, exporte os PNGs com o comando abaixo, ajustando o caminho do programa:

```powershell
pwsh -NoProfile -File .\scripts\exportar-modelos.ps1 -DrawioPath 'C:\Program Files\draw.io\draw.io.exe'
```

O script exporta os quatro diagramas e os quatro protótipos em escala 2, com o modelo editável embutido no PNG. Depois, execute `pwsh -NoProfile -File .\scripts\verificar-projeto.ps1` e confira se os textos e as setas estão legíveis. Use uma página própria ou paisagem para as figuras maiores.

O [gerador de modelos](../../scripts/gerar-modelos.py) permite recriar os desenhos iniciais com Python 3. Reexecutá-lo substitui as fontes, por isso use-o apenas se quiser recriar os modelos, sem preservar edições manuais.
