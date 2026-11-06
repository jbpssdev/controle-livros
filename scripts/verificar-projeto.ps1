[CmdletBinding()]
param(
    [string]$PhpPath,
    [string]$RelatorioJson
)

$ErrorActionPreference = 'Stop'
$raizProjeto = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'ProjetoTools.ps1')
$resultados = New-Object 'System.Collections.Generic.List[object]'
function Registrar {
    param([string]$Item, [ValidateSet('VERIFICADO','FALHA','NAO_VERIFICADO')][string]$Status, [string]$Detalhe)
    $resultados.Add([pscustomobject]@{ Item=$Item; Status=$Status; Detalhe=$Detalhe })
    Write-Output "[$Status] $Item — $Detalhe"
}
function Ler { param([string]$Relativo) [IO.File]::ReadAllText((Join-Path $raizProjeto $Relativo)) }

$obrigatorios = @(
    'index.php','README.md','.gitignore','config/database.example.php',
    'src/Database.php','src/Livro.php','src/Categoria.php','src/Movimentacao.php','src/AcervoService.php','src/bootstrap.php',
    'public/index.php','public/novo-livro.php','public/editar-livro.php','public/movimentacoes.php',
    'public/actions/salvar-livro.php','public/actions/atualizar-livro.php','public/actions/registrar-movimentacao.php',
    'layouts/header.php','layouts/footer.php','assets/css/style.css','assets/css/bootstrap.min.css','assets/css/bootstrap.LICENSE','assets/js/app.js',
    'sql/estrutura.sql','sql/exemplos.sql','tests/check-env.php','tests/plano-testes.md',
    'docs/README.md','docs/requisitos/requisitos-funcionais.md','docs/requisitos/requisitos-nao-funcionais.md','docs/requisitos/casos-de-uso.md',
    'docs/modelagem/dicionario-dados.md','docs/codigo/funcionalidades-documentadas.md','docs/testes/matriz-testes.md','docs/testes/verificacoes-executadas.md',
    'docs/evidencias/INSTRUCOES.md','docs/relatorio/roteiro-preenchimento.md','docs/relatorio/fontes-para-conferencia.md',
    'docs/diagramas/LEITURA.md','docs/prototipos/LEITURA.md',
    'scripts/ProjetoTools.ps1','scripts/verificar-projeto.ps1','scripts/gerar-pacotes.ps1','scripts/exportar-modelos.ps1','scripts/gerar-modelos.py'
)
$modelos = @('docs/diagramas/casos-de-uso','docs/diagramas/classes','docs/diagramas/mer','docs/diagramas/sequencia','docs/prototipos/catalogo','docs/prototipos/cadastro','docs/prototipos/edicao','docs/prototipos/movimentacoes')
foreach ($modelo in $modelos) { $obrigatorios += $modelo+'.drawio'; $obrigatorios += $modelo+'.png' }
$ausentes = @($obrigatorios | Where-Object { -not (Test-Path -LiteralPath (Join-Path $raizProjeto $_) -PathType Leaf) })
Registrar 'Arquivos obrigatórios de código/documentação' $(if($ausentes.Count){'FALHA'}else{'VERIFICADO'}) $(if($ausentes.Count){$ausentes -join ', '}else{"$($obrigatorios.Count) arquivos presentes; configuração privada não é exigida em uma distribuição."})
$pastas = @('src','public/actions','config','sql','tests','docs/requisitos','docs/diagramas','docs/modelagem','docs/prototipos','docs/codigo','docs/testes','docs/evidencias','docs/relatorio','scripts')
$pastasAusentes = @($pastas | Where-Object { -not (Test-Path -LiteralPath (Join-Path $raizProjeto $_) -PathType Container) })
Registrar 'Diretórios' $(if($pastasAusentes.Count){'FALHA'}else{'VERIFICADO'}) $(if($pastasAusentes.Count){$pastasAusentes -join ', '}else{"$($pastas.Count) diretórios presentes."})
if ($ausentes.Count) { throw 'Corrija arquivos obrigatórios ausentes antes das demais verificações.' }
$arquivos = @(Get-ArquivosPublicaveis -Raiz $raizProjeto)

foreach ($script in ($arquivos | Where-Object { $_.Relativo -like '*.ps1' })) {
    $tokens = $null; $erros = $null
    [Management.Automation.Language.Parser]::ParseFile($script.Caminho, [ref]$tokens, [ref]$erros) | Out-Null
    Registrar ('Sintaxe PowerShell: '+$script.Relativo) $(if($erros.Count){'FALHA'}else{'VERIFICADO'}) $(if($erros.Count){($erros | ForEach-Object Message) -join '; '}else{'Parser sem erros.'})
}

if (-not $PhpPath) {
    $comando = Get-Command php -ErrorAction SilentlyContinue
    if ($comando) { $PhpPath = $comando.Source }
    elseif (Test-Path -LiteralPath 'C:\xampp\php\php.exe') { $PhpPath = 'C:\xampp\php\php.exe' }
}
$versaoPhp = $null
if ($PhpPath -and (Test-Path -LiteralPath $PhpPath -PathType Leaf)) {
    $versaoPhp = (& $PhpPath -r 'echo PHP_VERSION;') -join ''
    $falhasPhp = @()
    $phpArquivos = @($arquivos | Where-Object { $_.Relativo -like '*.php' })
    # A configuração privada é somente lintada quando presente; seu conteúdo não é lido nem publicado.
    $privado = Join-Path $raizProjeto 'config/database.php'
    $caminhosPhp = @($phpArquivos | ForEach-Object Caminho)
    if (Test-Path -LiteralPath $privado) { $caminhosPhp += $privado }
    foreach ($caminho in $caminhosPhp) {
        $saidaLint = & $PhpPath -l $caminho 2>&1
        if ($LASTEXITCODE -ne 0) { $falhasPhp += [IO.Path]::GetFileName($caminho) }
    }
    Registrar 'Sintaxe PHP' $(if($falhasPhp.Count){'FALHA'}else{'VERIFICADO'}) $(if($falhasPhp.Count){$falhasPhp -join ', '}else{"$($caminhosPhp.Count) arquivos; PHP $versaoPhp. Lint não executa regras nem banco."})
} else { Registrar 'Sintaxe PHP' 'NAO_VERIFICADO' 'Executável PHP não encontrado; informe -PhpPath.' }

$rf = Ler 'docs/requisitos/requisitos-funcionais.md'
$cu = Ler 'docs/requisitos/casos-de-uso.md'
foreach ($mapa in (Get-RastreabilidadeProjeto)) {
    $codigoClasse = Ler ('src/'+$mapa.Classe+'.php')
    $codigoAcionador = Ler $(if($mapa.Acao){$mapa.Acao}else{$mapa.Pagina})
    $valido = $rf.Contains($mapa.RF) -and $cu.Contains($mapa.CU) -and $rf.Contains($mapa.Pagina) -and
        $codigoClasse -match ('function\s+'+[regex]::Escape($mapa.Metodo)+'\s*\(') -and
        $codigoAcionador.Contains('->'+$mapa.Metodo+'(')
    Registrar ('Rastreabilidade estrutural '+$mapa.RF+' / '+$mapa.CU) $(if($valido){'VERIFICADO'}else{'FALHA'}) ($mapa.Pagina+' → '+$mapa.Classe+'::'+$mapa.Metodo)
}
$classesXml = Read-XmlSeguro (Ler 'docs/diagramas/classes.drawio')
$rotulosClasse = [Net.WebUtility]::HtmlDecode(($classesXml.SelectNodes('//mxCell[@value]') | ForEach-Object { $_.GetAttribute('value') }) -join ' ')
$metodosAusentes = @()
foreach ($classe in @('Database','Livro','Categoria','Movimentacao','AcervoService')) {
    if (-not $rotulosClasse.Contains($classe)) { $metodosAusentes += $classe }
    foreach ($metodo in [regex]::Matches((Ler ('src/'+$classe+'.php')), 'function\s+(\w+)\s*\(')) {
        if (-not $rotulosClasse.Contains($metodo.Groups[1].Value+'(')) { $metodosAusentes += ($classe+'::'+$metodo.Groups[1].Value) }
    }
}
Registrar 'Métodos reais presentes no UML' $(if($metodosAusentes.Count){'FALHA'}else{'VERIFICADO'}) $(if($metodosAusentes.Count){$metodosAusentes -join ', '}else{'Cinco classes e todos os métodos declarados encontrados nos rótulos.'})

$sql = Ler 'sql/estrutura.sql'
$dicionario = Ler 'docs/modelagem/dicionario-dados.md'
$merXml = Read-XmlSeguro (Ler 'docs/diagramas/mer.drawio')
$mer = [Net.WebUtility]::HtmlDecode(($merXml.SelectNodes('//mxCell[@value]') | ForEach-Object { $_.GetAttribute('value') }) -join ' ')
$problemasModelo = @(); $colunas = 0
foreach ($tabela in [regex]::Matches($sql, '(?ms)CREATE TABLE IF NOT EXISTS (\w+)\s*\((.*?)\) ENGINE=')) {
    $nomeTabela = $tabela.Groups[1].Value
    $secao = [regex]::Match($dicionario, '(?ms)^## '+[regex]::Escape($nomeTabela)+'\s*$(.*?)(?=^## |\z)').Value
    foreach ($coluna in [regex]::Matches($tabela.Groups[2].Value, '(?m)^\s{4}(\w+)\s+(ENUM\([^\r\n]+?\)|(?:VARCHAR|DECIMAL)\([^)]*\)|INT|DATETIME)')) {
        $nome = $coluna.Groups[1].Value; $tipo = $coluna.Groups[2].Value; $colunas++
        if (-not $secao.Contains('| '+$nome+' | '+$tipo+' |') -or -not $mer.Contains($nome+' : '+$tipo)) { $problemasModelo += ($nomeTabela+'.'+$nome) }
    }
}
foreach ($restricao in [regex]::Matches($sql,'(?:CONSTRAINT|INDEX)\s+(\w+)')) {
    if (-not $dicionario.Contains($restricao.Groups[1].Value)) { $problemasModelo += $restricao.Groups[1].Value }
}
if ($colunas -ne 17) { $problemasModelo += "Esperadas 17 colunas; extraídas $colunas. Rever parser/esquema." }
Registrar 'SQL, dicionário e MER' $(if($problemasModelo.Count){'FALHA'}else{'VERIFICADO'}) $(if($problemasModelo.Count){$problemasModelo -join ', '}else{'17 colunas, tipos, índices e constraints nomeadas conferidos estruturalmente.'})

$quebradas = @()
foreach ($doc in ($arquivos | Where-Object { $_.Relativo -like '*.md' })) {
    $textoDoc = [regex]::Replace([IO.File]::ReadAllText($doc.Caminho), '(?ms)^```.*?^```[^\r\n]*', '')
    foreach ($link in [regex]::Matches($textoDoc, '\[[^\]\r\n]*\]\((<[^>]+>|[^)\s]+)\)')) {
        $destino = $link.Groups[1].Value.Trim('<','>')
        if ($destino -match '^(https?://|mailto:|#)') { continue }
        $destino = [Uri]::UnescapeDataString(($destino -split '[?#]')[0])
        $caminho = Join-Path (Split-Path -Parent $doc.Caminho) $destino
        if (-not (Test-Path -LiteralPath $caminho)) { $quebradas += ($doc.Relativo+' → '+$destino) }
    }
}
Registrar 'Links locais Markdown' $(if($quebradas.Count){'FALHA'}else{'VERIFICADO'}) $(if($quebradas.Count){$quebradas -join '; '}else{'Todos os destinos locais reconhecidos existem; exemplos em blocos de código são ignorados.'})

$referencias = @()
foreach ($arquivo in ($arquivos | Where-Object { $_.Relativo -like '*.php' })) {
    $textoPhp = [IO.File]::ReadAllText($arquivo.Caminho)
    $diretorioPhp = Split-Path -Parent $arquivo.Caminho
    foreach ($inc in [regex]::Matches($textoPhp,'require(?:_once)?\s+(dirname\(__DIR__(?:,\s*(\d+))?\)|__DIR__)\s*\.\s*[''"]([^''"]+\.php)[''"]')) {
        $base = $diretorioPhp
        if ($inc.Groups[1].Value.StartsWith('dirname')) {
            $n = if($inc.Groups[2].Success){[int]$inc.Groups[2].Value}else{1}
            for($i=0;$i -lt $n;$i++){ $base = Split-Path -Parent $base }
        }
        $destino = Join-Path $base $inc.Groups[3].Value.TrimStart('/','\')
        if (-not (Test-Path -LiteralPath $destino -PathType Leaf)) { $referencias += ($arquivo.Relativo+' → include '+$inc.Groups[3].Value) }
    }
    $baseHttp = if($arquivo.Relativo.StartsWith('layouts/')){Join-Path $raizProjeto 'public'}else{$diretorioPhp}
    foreach ($ref in [regex]::Matches($textoPhp,'(?:href|src|action)="([^"]+)"|redirecionar\([''"]([^''"]+)[''"]')) {
        $destino = if($ref.Groups[1].Success){$ref.Groups[1].Value}else{$ref.Groups[2].Value}
        $destino = ($destino -split '[?#]')[0]
        if (-not $destino -or $destino -match '^(https?://|data:)' -or $destino.Contains('<')) { continue }
        if (-not (Test-Path -LiteralPath (Join-Path $baseHttp $destino) -PathType Leaf)) { $referencias += ($arquivo.Relativo+' → '+$destino) }
    }
}
Registrar 'Includes, formulários e recursos locais reconhecidos' $(if($referencias.Count){'FALHA'}else{'VERIFICADO'}) $(if($referencias.Count){$referencias -join '; '}else{'Destinos estáticos existentes; conjunto dinâmico de classes conferido na árvore obrigatória.'})

try { Add-Type -AssemblyName System.Drawing -ErrorAction Stop; $desenhoDisponivel = $true } catch { $desenhoDisponivel = $false }
foreach ($modelo in $modelos) {
    try {
        $xml = Read-XmlSeguro (Ler ($modelo+'.drawio'))
        if ($xml.SelectNodes('//diagram').Count -ne 1 -or $xml.SelectNodes('//mxCell').Count -lt 10) { throw 'Modelo sem página/células esperadas.' }
        $embutido = Get-ModeloPng (Join-Path $raizProjeto ($modelo+'.png'))
        if ($xml.SelectSingleNode('//mxGraphModel').OuterXml -ne $embutido.SelectSingleNode('//mxGraphModel').OuterXml) { throw 'XML do PNG diferente do editável; reexporte.' }
        if ($desenhoDisponivel) {
            $imagem = [Drawing.Image]::FromFile((Join-Path $raizProjeto ($modelo+'.png')))
            try {
                if ($imagem.Width -lt 2000 -or $imagem.Height -lt 1000) { throw 'Resolução insuficiente.' }
                $dimensoes = "$($imagem.Width) × $($imagem.Height)"
                # Forçar decodificação dos pixels; assinatura sozinha não basta.
                $bitmap = New-Object Drawing.Bitmap($imagem)
                try { $pixel = $bitmap.GetPixel([int]($bitmap.Width/2), [int]($bitmap.Height/2)) } finally { $bitmap.Dispose() }
            } finally { $imagem.Dispose() }
            Registrar ('PNG / fonte: '+$modelo) 'VERIFICADO' ($dimensoes+'; imagem decodificada; modelo embutido idêntico.')
        } else { Registrar ('PNG / fonte: '+$modelo) 'NAO_VERIFICADO' 'XML embutido coincide; decodificação visual indisponível sem System.Drawing.' }
    } catch { Registrar ('PNG / fonte: '+$modelo) 'FALHA' $_.Exception.Message }
}

$suspeitas = @(Find-CredenciaisPublicaveis -Arquivos $arquivos)
Registrar 'Varredura heurística de credenciais publicáveis' $(if($suspeitas.Count){'FALHA'}else{'VERIFICADO'}) $(if($suspeitas.Count){($suspeitas | ForEach-Object { $_.Arquivo+' ('+$_.Regra+')' }) -join '; '}else{'Nenhum padrão reconhecido nos textos selecionados. Valores privados excluídos da seleção.'})
$indevidos = @($arquivos | Where-Object { $_.Relativo -match '(^|/)(\.git|\.runtime|dist|\.env)(/|$)|^config/database\.php$|\.zip$' })
Registrar 'Seleção para publicação/pacotes' $(if($indevidos.Count){'FALHA'}else{'VERIFICADO'}) "$($arquivos.Count) arquivos selecionados; sem configuração local, runtime, .env, ZIPs ou .git."
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git -and (Test-Path -LiteralPath (Join-Path $raizProjeto '.git'))) {
    $ignora = & $git.Source -C $raizProjeto check-ignore -- config/database.php .runtime/arquivo.tmp dist/arquivo.zip
    Registrar 'Exclusões do Git' $(if(@($ignora).Count -eq 3){'VERIFICADO'}else{'FALHA'}) 'Conferência de configuração privada, runtime e dist com git check-ignore.'
} else { Registrar 'Exclusões efetivas do Git' 'NAO_VERIFICADO' 'Git/repositório não disponível nesta cópia; seleção dos pacotes continua restrita.' }
Registrar 'Testes funcionais e banco local' 'NAO_VERIFICADO' 'Este script não abre conexão nem executa gravações; executar a matriz manual em ambiente de estudo.'
Registrar 'Revisão visual, acessibilidade integral e autenticidade de evidências' 'NAO_VERIFICADO' 'Dependem de inspeção humana; imagens válidas não comprovam cenários manuais.'
Registrar 'URLs externas e segredos em imagens' 'NAO_VERIFICADO' 'Não há consulta de rede ou OCR; revisão humana continua necessária.'

if (-not $RelatorioJson) { $RelatorioJson = Join-Path $raizProjeto 'dist/verificacao-projeto.json' }
New-Item -ItemType Directory -Path (Split-Path -Parent $RelatorioJson) -Force | Out-Null
$falhas = @($resultados | Where-Object Status -eq 'FALHA').Count
$pendentes = @($resultados | Where-Object Status -eq 'NAO_VERIFICADO').Count
[ordered]@{
    ExecutadoEm = (Get-Date).ToString('o'); PowerShell = $PSVersionTable.PSVersion.ToString(); PHP = $versaoPhp
    ArquivosSelecionados = $arquivos.Count; Falhas = $falhas; NaoVerificados = $pendentes; Resultados = $resultados.ToArray()
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $RelatorioJson -Encoding UTF8
Write-Output "RESUMO: $falhas falha(s); $pendentes item(ns) não verificado(s). Relatório: $RelatorioJson"
if ($falhas) { throw 'A verificação encontrou falhas objetivas. Consulte o relatório JSON.' }
