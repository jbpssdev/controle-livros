# Diagramas técnicos e exportação

| Figura | Editável | Imagem | Fonte da modelagem |
| --- | --- | --- | --- |
| F01 — Casos de uso | [casos-de-uso.drawio](casos-de-uso.drawio) | [PNG](casos-de-uso.png) | [Casos de uso textuais](../requisitos/casos-de-uso.md); cinco operações, um ator e limite do sistema |
| F02 — Classes | [classes.drawio](classes.drawio) | [PNG](classes.png) | [src](../../src/AcervoService.php); cinco classes reais, atributos privados, métodos públicos/privados e dependências |
| F03 — MER lógico | [mer.drawio](mer.drawio) | [PNG](mer.png) | [estrutura.sql](../../sql/estrutura.sql); três tabelas, 17 colunas e duas FKs |
| F04 — Sequência | [sequencia.drawio](sequencia.drawio) | [PNG](sequencia.png) | [ação](../../public/actions/registrar-movimentacao.php), serviço e repositórios; sucesso e estoque insuficiente |

## Convenções

Casos de uso: ator externo e associações simples sem setas, sem include/extend artificiais. Classes: `+` público, `−` privado, método sublinhado estático, `{leaf}` para classes `final` em PHP. Linhas tracejadas com ponta aberta representam dependência de criação/uso pelo serviço. A biblioteca PDO é identificada como infraestrutura; os atributos PDO indicam a conexão compartilhada. Não se infere composição nem herança inexistente. `bootstrap.php` tem funções livres, não uma classe.

MER: modelo lógico, não diagrama de classes. PK identifica chave primária, FK a estrangeira e UQ a unicidade; cardinalidades também estão escritas junto às extremidades. Categoria pode ter zero livros; livro pode ter zero movimentos. Cada filho referencia exatamente um pai, com FK NOT NULL. Os índices e as expressões completas das restrições estão no [dicionário](../modelagem/dicionario-dados.md).

Sequência: retângulos identificam participantes, linhas verticais tracejadas são linhas de vida, ponta preenchida representa chamada síncrona e retorno é tracejado. O fragmento `alt` distingue saída sem saldo de operação válida. Repositórios aparecem porque são eles que emitem SQL. `PDO / MariaDB` resume o acesso à infraestrutura, sem sugerir que o serviço contém o SQL dos repositórios. O GET após o redirecionamento é uma nova requisição; sua consulta completa não foi expandida no cenário POST. Erros de método/CSRF precedem o serviço; erro SQL e outros erros transacionais estão anotados.

## Editar e exportar novamente

As oito fontes (diagramas e protótipos) foram produzidas em XML draw.io descomprimido, com textos, formas e conexões editáveis. Os PNGs são exportações reais do **draw.io Desktop 32.6.10**, não arquivos vazios, redesenhos bitmap ou capturas de navegador. O XML está embutido nas imagens com `--embed-diagram`; o verificador compara o modelo embutido com o editável.

Abra um `.drawio` no draw.io Desktop para ajustar o desenho. Se editar manualmente, **não reexecute o gerador Python**, pois ele recria as fontes de referência. Para recriar intencionalmente os modelos originais, use `python .\scripts\gerar-modelos.py`; ele depende somente da biblioteca padrão, não da aplicação PHP.

Para exportar os oito arquivos, na raiz:

```powershell
pwsh -NoProfile -File .\scripts\exportar-modelos.ps1 -DrawioPath 'C:\Program Files\draw.io\draw.io.exe'
```

O executável não é distribuído nos ZIPs. Nesta etapa, usou-se uma distribuição portátil oficial em `.runtime\ferramentas\drawio\draw.io.exe`, sem instalação global. No mesmo workspace, o comando pode omitir `-DrawioPath`, pois o script também procura nesse caminho. Em outro computador, instale/obtenha a ferramenta oficial ou informe sua localização.

Exemplo direto equivalente para um arquivo (adapte o caminho do executável):

```powershell
& 'C:\Program Files\draw.io\draw.io.exe' --export --format png --scale 2 --border 20 --size page --theme light --embed-diagram --output '.\docs\diagramas\classes.png' '.\docs\diagramas\classes.drawio'
```

O script usa processo oculto, aguarda o término de cada exportação, registra logs em `dist/logs-exportacao` e falha se não houver PNG. A escala 2 oferece imagens com milhares de pixels, adequadas como fonte para figuras A4. Para preservar a leitura, use página paisagem ou uma página própria para classes, MER e sequência; não reduza todos a miniaturas em uma única página.

Depois de exportar, execute [verificar-projeto.ps1](../../scripts/verificar-projeto.ps1), abra todas as imagens e confira rótulos, cortes, alinhamento e setas. A validação automática de PNG/XML não substitui revisão visual. As [fontes oficiais consultadas](../relatorio/fontes-para-conferencia.md) explicam o formato e o mecanismo de exportação.
