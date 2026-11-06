# Sistema de Controle de Livros Usados

Aplicação local para estudo de PHP orientado a objetos e controle de um pequeno acervo. Permite cadastrar, pesquisar e editar livros, registrar entradas e saídas e consultar o histórico. Não possui autenticação nem serviços externos.

## Tecnologias e requisitos

- Windows 11, XAMPP com Apache, PHP **8.2+** e MariaDB **10.2.1+** (ou MySQL **8.0.16+**, com CHECK aplicado).
- Extensões PHP: PDO, pdo_mysql, mbstring, session e filter, normalmente disponíveis no XAMPP.
- HTML5, CSS3, JavaScript opcional e **Bootstrap 5.3.3 incluído localmente**. A licença MIT está em `assets/css/bootstrap.LICENSE`.
- Navegador atualizado. VS Code e Git são opcionais para edição e versionamento.
- Não exige Composer, Node.js, instalação de pacotes, APIs, internet, virtual host ou alterações globais no Apache.

## Instalação no XAMPP

1. Copie **a pasta `controle-livros` deste workspace**, com os arquivos da aplicação, para `C:\xampp\htdocs\controle-livros`. **Exclua da cópia a pasta `.runtime`, se presente**: ela contém apenas scripts e banco descartável usados na validação, não faz parte da aplicação e está ignorada no Git. Evite criar uma pasta duplicada `controle-livros\controle-livros`.
2. Abra o **XAMPP Control Panel**. Clique em **Start** ao lado de **Apache** e **MySQL** (o componente MySQL do XAMPP utiliza MariaDB). Aguarde ambos ficarem ativos. Este projeto não altera portas, serviços ou arquivos globais do XAMPP.
3. Abra `http://localhost/phpmyadmin/`. Na aba **Importar**, selecione `C:\xampp\htdocs\controle-livros\sql\estrutura.sql`, mantenha a codificação UTF-8 e execute. O script cria o banco `controle_livros`, as tabelas e cinco categorias de referência. Nenhum livro é criado nessa etapa.
4. Verifique `config/database.php`. A configuração local entregue usa host `localhost`, porta `3306`, banco `controle_livros`, usuário `root` e senha vazia, padrão de uma instalação local do XAMPP. Ajuste apenas esse arquivo se sua instalação for diferente. Não altere a configuração global do XAMPP.
5. **Opcional, somente para demonstração:** importe `sql/exemplos.sql` no phpMyAdmin, após a estrutura. Ele adiciona três livros fictícios com prefixo `[DEMONSTRAÇÃO]` e entradas iniciais coerentes. Não importe se quiser começar com catálogo vazio. Execute uma importação por vez, sem cadastro/edição simultâneos; os ISBNs `DEMO-*` são marcadores reservados. Reimportar não duplica registros nem redefine estoques já movimentados.
6. Abra **`http://localhost/controle-livros/`**. O arquivo raiz redireciona para `public/index.php`.
7. Confira o ambiente em `http://localhost/controle-livros/tests/check-env.php` ou pelo terminal, conforme abaixo.

Os scripts SQL não contêm DROP, DELETE ou TRUNCATE. `CREATE TABLE IF NOT EXISTS` preserva tabelas existentes, mas **não migra esquemas antigos**: se já houver um banco homônimo com outra estrutura, faça backup e use uma instalação separada de estudo antes de importar. Não importe scripts em bancos de outros projetos.

### Configuração em outro computador ou clone do Git

`config/database.php` é local e está ignorado no Git. Ele foi criado neste workspace, mas não acompanha um clone. Na raiz do projeto clonado, execute no PowerShell:

```powershell
Copy-Item -LiteralPath .\config\database.example.php -Destination .\config\database.php
```

Edite os valores em `database.php` para a instalação local. Nunca versione senhas; `database.example.php` contém somente os valores padrão de desenvolvimento com senha vazia. Se você já versionou a configuração em outro repositório, `.gitignore` não remove arquivos anteriormente rastreados.

## Organização

```text
controle-livros/
├── index.php                      # redireciona para public/index.php
├── README.md
├── .gitignore
├── config/
│   ├── database.php                # configuração local, ignorada no Git
│   └── database.example.php
├── src/
│   ├── Database.php                # conexão PDO
│   ├── Livro.php                   # persistência dos livros
│   ├── Categoria.php               # consulta das categorias
│   ├── Movimentacao.php            # persistência do histórico
│   ├── AcervoService.php           # validação, transações e estoque
│   └── bootstrap.php               # sessões, CSRF e helpers compartilhados
├── public/
│   ├── index.php                   # catálogo e pesquisa
│   ├── novo-livro.php
│   ├── editar-livro.php
│   ├── movimentacoes.php           # formulário, filtro e histórico
│   └── actions/
│       ├── salvar-livro.php
│       ├── atualizar-livro.php
│       └── registrar-movimentacao.php
├── layouts/
│   ├── header.php
│   └── footer.php
├── assets/
│   ├── css/
│   │   ├── bootstrap.min.css
│   │   ├── bootstrap.LICENSE
│   │   └── style.css
│   └── js/app.js
├── sql/
│   ├── estrutura.sql
│   └── exemplos.sql
├── docs/
│   ├── README.md                   # índice dos materiais técnicos
│   ├── requisitos/                 # RFs, RNFs e casos de uso
│   ├── diagramas/                  # UML/MER: quatro drawio e quatro PNGs
│   ├── modelagem/                  # dicionário das 17 colunas
│   ├── prototipos/                 # quatro modelos editáveis e exportados
│   ├── codigo/                     # fluxos e trechos reais de PHP/SQL
│   ├── testes/                     # matriz manual e registro automático
│   ├── evidencias/                 # instruções; capturas reais futuras
│   └── relatorio/                  # roteiro, sem relatório acadêmico pronto
├── scripts/                       # verificação, exportação e pacotes
├── tests/
│   ├── check-env.php
│   └── plano-testes.md
└── dist/                          # ZIPs, manifestos e verificações; ignorado no Git
```

## Funcionalidades e regras

- **RF01:** cadastro com título, autor, categoria, ISBN opcional, preço e estoque inicial. Saldo inicial positivo gera entrada no histórico na mesma transação; zero não gera movimento.
- **RF02:** catálogo com pesquisa parcial por título, autor ou ISBN, categoria, preço e disponibilidade. `%` e `_` na pesquisa são tratados literalmente. As telas utilizam exclusivamente dados do banco; estados vazios são informados.
- **RF03:** edição dos dados cadastrais; a quantidade não é aceita na atualização. O estoque exibido na edição é somente leitura.
- **RF04:** entradas e saídas inteiras positivas, sem saldo negativo. `SELECT ... FOR UPDATE` bloqueia o livro dentro de uma transação InnoDB; saldo e histórico são confirmados juntos. Saídas concorrentes consultam o saldo após adquirir o bloqueio.
- **RF05:** histórico com data, livro, tipo, quantidade e observação, em ordem da movimentação mais recente; filtro por livro.
- Preços aceitam ponto ou vírgula e até duas casas decimais, de 0 a 99999999,99. Quantidades vão de 0 a 2147483647 no cadastro e de 1 a 2147483647 na movimentação, respeitando o saldo e o limite do INT.
- PDO com prepared statements nativos; saída HTML escapada; proteção CSRF; gravações somente por POST; redirecionamento 303 após processamento; sessão com cookies HttpOnly e SameSite; erros técnicos enviados apenas ao log do PHP.
- Interface responsiva em português, rótulos explícitos, foco visível, navegação por teclado, mensagens acessíveis e link para pular ao conteúdo. Tabelas largas permitem rolagem horizontal. JavaScript apenas melhora a apresentação do saldo; formulários continuam funcionando sem ele.
- Datas da aplicação e da conexão usam o fuso de Fortaleza (UTC−03:00).

## Testes e diagnóstico

No PowerShell, após copiar o projeto para o XAMPP:

```powershell
Set-Location -LiteralPath 'C:\xampp\htdocs\controle-livros'
& 'C:\xampp\php\php.exe' .\tests\check-env.php
Get-ChildItem -Recurse -Filter *.php | ForEach-Object {
    & 'C:\xampp\php\php.exe' -l $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "Erro de sintaxe: $($_.FullName)" }
}
```

`check-env.php` verifica versão, extensões, configuração, conexão, charset e disponibilidade das tabelas e colunas, sem exibir credenciais nem detalhes das exceções. Retorna código 0 no terminal quando todas as verificações passam, 1 caso contrário. Pela web, retorna 503 em caso de falha.

Em seguida, execute os cenários de `tests/plano-testes.md`, incluindo duas sessões independentes para concorrência. Preencha os resultados e coloque **somente capturas reais** em `docs/evidencias/`. Os campos do plano e as pastas de documentação foram deixados preparados para o estudante; não são um relatório acadêmico concluído. A existência do código não comprova execução de testes. Falhas induzidas de banco devem ser testadas apenas em banco descartável separado.

## Limitações conhecidas

- Projeto didático para computador local confiável, sem autenticação; não expor na internet ou em rede pública. Não inclui exclusão, gestão de categorias na interface, recuperação de estoque por inventário, pagamentos ou serviços em nuvem.
- Categorias iniciais vêm de `estrutura.sql`. Outras categorias podem ser cadastradas manualmente no banco, sem alterar o código.
- O catálogo e o histórico não têm paginação e são destinados a acervos pequenos. A pesquisa parcial usa LIKE e pode não aproveitar os índices em grandes bases.
- Alterações manuais diretamente no banco podem quebrar a correspondência entre estoque e histórico; operações da aplicação devem passar pelo serviço. As restrições SQL impedem valores negativos, mas não substituem as transações da aplicação.
- CSRF protege contra requisições indevidas entre sites; não é autenticação nem chave de idempotência. Não envie o mesmo formulário repetidamente. Recarregar após o redirecionamento não repete a gravação.
- Edições simultâneas dos dados cadastrais seguem a última gravação; o bloqueio de estoque é aplicado às movimentações.
- Não há migrações automáticas nem suíte que possa apagar/recriar bancos existentes. Verificações e testes do estudante devem ocorrer na sua própria instalação.
- Bootstrap é distribuído com o projeto; não há requisições a CDN durante o uso.

## Controle de versão

Antes de adicionar arquivos, confira `git status --ignored` e confirme que `config/database.php` aparece ignorado. Não publique credenciais nem evidências com dados pessoais. Nenhum push, publicação ou deploy é necessário para executar o sistema.

## Documentação técnica e modelagem

O [índice documental](docs/README.md) reúne requisitos, cinco casos de uso, UML de classes, MER, sequência transacional, dicionário de dados, quatro protótipos, documentação de funcionalidades e orientações para o relatório. Os desenhos refletem as classes, métodos e tabelas reais. Os PNGs foram renderizados pelo draw.io Desktop com o modelo editável embutido; **protótipos não são capturas de execução**.

A [matriz complementar](docs/testes/matriz-testes.md) contém 15 casos com resultados manuais pendentes. O [plano original](tests/plano-testes.md) foi preservado: CT07/CT08 têm numeração diferente na nova matriz, conforme a correspondência documentada. Consulte o [registro de verificações realmente executadas](docs/testes/verificacoes-executadas.md) para não confundir inspeção/lint com teste funcional.

As 12 capturas reais previstas devem ser produzidas posteriormente conforme [INSTRUCOES.md](docs/evidencias/INSTRUCOES.md). Não existem evidências de navegador fabricadas. O [roteiro do relatório](docs/relatorio/roteiro-preenchimento.md) orienta o estudante a relatar suas decisões, experiências e resultados; o modelo oficial do AVA ainda precisa ser fornecido/conferido.

## Verificação e distribuição

Na raiz, pelo PowerShell (os comandos abaixo utilizam `pwsh`):

```powershell
pwsh -NoProfile -File .\scripts\verificar-projeto.ps1
pwsh -NoProfile -File .\scripts\gerar-pacotes.ps1
```

Depois de gerar os pacotes, `pwsh -NoProfile -File .\scripts\testar-validadores.ps1` executa ensaios do scanner, da comparação PNG/editável (em cópia extraída) e do estado não verificado quando o PHP está ausente. A fonte original e o banco não são alterados.

Se o PHP estiver em outro caminho, acrescente `-PhpPath 'C:\caminho\php.exe'`. O verificador inspeciona a árvore, os links locais, assinaturas e rastreabilidade estrutural, sintaxe PHP/PowerShell, tipos/colunas do dicionário, seleção de arquivos, padrões reconhecíveis de credenciais e as oito imagens com XML embutido. Itens não automatizados são marcados **NAO_VERIFICADO**. Não executa ações da aplicação nem abre conexão com o banco.

Os pacotes são gerados em `dist/controle-livros-projeto.zip` e `dist/controle-livros-documentacao.zip`, com arquivos diretamente na raiz, sem duplicar a pasta principal. Cada um contém `MANIFESTO-SHA256.csv`; manifestos externos, hashes SHA-256 e resumo `pacotes.json` também ficam em `dist/`. O manifesto lista todos os arquivos de conteúdo, exceto ele próprio. O script confere os bytes descompactados e realiza uma extração real para comparar hashes.

São excluídos `.git`, `.runtime`, `dist`, `.env`, a configuração privada, temporários, ZIPs aninhados e SQL não autorizado. O pacote documental contém docs, plano de testes e scripts; links ao código devem ser consultados no pacote completo/repositório. As capturas reais que forem adicionadas depois entram nos pacotes ao regenerá-los, após revisão humana. O scanner textual não audita informações particulares em imagens.

`dist/` e `.runtime/` não devem ser copiados para o servidor local. `dist/` é ignorado no Git; `docs/evidencias/INSTRUCOES.md` é versionável e as capturas continuam ignoradas por padrão.

Para editar/exportar diagramas, consulte [LEITURA.md](docs/diagramas/LEITURA.md). Somente a manutenção dos desenhos usa draw.io Desktop; o gerador original opcional usa Python 3 e biblioteca padrão. **A aplicação continua sem dependência dessas ferramentas.** Após editar um `.drawio`, reexporte os PNGs antes de verificar/empacotar. Não reexecute o gerador se quiser preservar edições manuais nos modelos.

## Revisar e publicar a complementação

Nenhum commit ou push é feito pelos scripts. Revise antes de publicar:

```powershell
git status --short
git diff --check
git diff -- README.md .gitignore
git add -- README.md .gitignore docs scripts
git diff --cached --stat
git diff --cached --check
git status --short
git commit -m "Documenta requisitos, modelagem e validacao do projeto"
git push origin main
```

Confirme que somente os arquivos desejados estão preparados e que ZIPs, runtime e configuração local estão ausentes do commit. Esses comandos usam o repositório existente e não reescrevem o histórico.
