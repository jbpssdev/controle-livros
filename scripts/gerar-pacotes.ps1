[CmdletBinding()]
param([string]$PhpPath)

$ErrorActionPreference = 'Stop'
$raizProjeto = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'ProjetoTools.ps1')
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Não há conexão com o banco. O verificador executa somente inspeção e php -l.
$parametros = @{}
if ($PhpPath) { $parametros.PhpPath = $PhpPath }
& (Join-Path $PSScriptRoot 'verificar-projeto.ps1') @parametros
$publicaveis = @(Get-ArquivosPublicaveis -Raiz $raizProjeto)
$suspeitas = @(Find-CredenciaisPublicaveis -Arquivos $publicaveis)
if ($suspeitas.Count) { throw 'Pacotes não gerados: possíveis credenciais nos arquivos selecionados. Consulte o verificador; nenhum valor sensível é impresso.' }
$pastaDist = Join-Path $raizProjeto 'dist'
New-Item -ItemType Directory -Path $pastaDist -Force | Out-Null

function New-PacoteVerificado {
    param([string]$Nome, [array]$Arquivos, [string]$Nota)
    $caminhoZip = Join-Path $pastaDist ($Nome+'.zip')
    $notaArquivo = Join-Path $pastaDist ($Nome+'.leia-me.md')
    $Nota | Set-Content -LiteralPath $notaArquivo -Encoding UTF8
    $entradas = @($Arquivos) + [pscustomobject]@{ Relativo='LEIA-ME-PACOTE.md'; Caminho=$notaArquivo; Tamanho=(Get-Item -LiteralPath $notaArquivo).Length }
    $entradas = @($entradas | Sort-Object Relativo)
    foreach ($entrada in $entradas) {
        if ($entrada.Relativo -match '(^|/)\.\.?(/|$)|(^|/)(\.git|\.runtime|dist|\.env)(/|$)|^config/database\.php$|\.zip$' -or [IO.Path]::IsPathRooted($entrada.Relativo)) {
            throw "Caminho não publicável no ZIP: $($entrada.Relativo)"
        }
    }
    $manifesto = @($entradas | ForEach-Object {
        [pscustomobject]@{
            Arquivo=$_.Relativo
            Tamanho=$_.Tamanho
            SHA256=(Get-FileHash -LiteralPath $_.Caminho -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    })
    $caminhoManifesto = Join-Path $pastaDist ($Nome+'.manifesto.csv')
    $manifesto | Export-Csv -LiteralPath $caminhoManifesto -NoTypeInformation -Encoding UTF8

    $fluxo = [IO.File]::Open($caminhoZip, [IO.FileMode]::Create, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $zip = New-Object IO.Compression.ZipArchive($fluxo, [IO.Compression.ZipArchiveMode]::Create, $false)
    try {
        foreach ($entrada in $entradas) {
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $entrada.Caminho, $entrada.Relativo, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $caminhoManifesto, 'MANIFESTO-SHA256.csv', [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    } finally { $zip.Dispose(); $fluxo.Dispose() }

    # Abrir e ler integralmente cada entrada, comparando tamanho e hash ao manifesto.
    $leitura = [IO.Compression.ZipFile]::OpenRead($caminhoZip)
    try {
        if ($leitura.Entries.Count -ne $entradas.Count+1) { throw 'Quantidade inesperada de entradas no ZIP.' }
        if (@($leitura.Entries | Group-Object FullName | Where-Object Count -gt 1).Count) { throw 'ZIP contém nomes duplicados.' }
        foreach ($linha in $manifesto) {
            $entradaZip = $leitura.GetEntry($linha.Arquivo)
            if (-not $entradaZip -or $entradaZip.Length -ne [long]$linha.Tamanho) { throw "Entrada ausente ou tamanho divergente: $($linha.Arquivo)" }
            $hash = [Security.Cryptography.SHA256]::Create()
            $stream = $entradaZip.Open()
            try { $real = [BitConverter]::ToString($hash.ComputeHash($stream)).Replace('-','').ToLowerInvariant() }
            finally { $stream.Dispose(); $hash.Dispose() }
            if ($real -ne $linha.SHA256) { throw "Hash divergente dentro do ZIP: $($linha.Arquivo)" }
        }
        $streamManifesto = $leitura.GetEntry('MANIFESTO-SHA256.csv').Open()
        $hash = [Security.Cryptography.SHA256]::Create()
        try { $hashManifesto = [BitConverter]::ToString($hash.ComputeHash($streamManifesto)).Replace('-','') }
        finally { $streamManifesto.Dispose(); $hash.Dispose() }
        if ($hashManifesto -ne (Get-FileHash -LiteralPath $caminhoManifesto -Algorithm SHA256).Hash) { throw 'Manifesto embutido divergente.' }
    } finally { $leitura.Dispose() }

    # Extração real para área gerada, nunca para a aplicação ou outro projeto.
    $extracao = Join-Path $pastaDist ('verificacao-extraida\'+$Nome)
    New-Item -ItemType Directory -Path $extracao -Force | Out-Null
    Expand-Archive -LiteralPath $caminhoZip -DestinationPath $extracao -Force
    foreach ($linha in $manifesto) {
        $arquivoExtraido = Join-Path $extracao $linha.Arquivo
        if (-not (Test-Path -LiteralPath $arquivoExtraido -PathType Leaf) -or
            (Get-FileHash -LiteralPath $arquivoExtraido -Algorithm SHA256).Hash.ToLowerInvariant() -ne $linha.SHA256) {
            throw "Extração divergente: $($linha.Arquivo)"
        }
    }
    if ((Get-FileHash -LiteralPath (Join-Path $extracao 'MANIFESTO-SHA256.csv') -Algorithm SHA256).Hash -ne
        (Get-FileHash -LiteralPath $caminhoManifesto -Algorithm SHA256).Hash) { throw 'Manifesto extraído divergente.' }
    $arquivoZip = Get-Item -LiteralPath $caminhoZip
    $shaZip = (Get-FileHash -LiteralPath $caminhoZip -Algorithm SHA256).Hash.ToLowerInvariant()
    "$shaZip  $($arquivoZip.Name)" | Set-Content -LiteralPath (Join-Path $pastaDist ($Nome+'.sha256')) -Encoding ASCII
    [pscustomobject]@{
        Arquivo=$arquivoZip.FullName; Bytes=$arquivoZip.Length; Entradas=$entradas.Count+1
        SHA256=$shaZip; Manifesto=$caminhoManifesto; ExtracaoConferida=$extracao
    }
}

$notaProjeto = @'
# Pacote do projeto

Os arquivos da aplicação estão diretamente na raiz, sem pasta principal duplicada.
Leia README.md. config/database.php não é distribuído: copie config/database.example.php
para esse nome e ajuste a conexão somente na instalação local. Importe a estrutura pelo
phpMyAdmin conforme o README. Não há .git, .runtime, .env, ZIPs aninhados ou banco local.

MANIFESTO-SHA256.csv lista todos os arquivos de conteúdo, incluindo esta nota, com tamanho
e SHA-256. O manifesto não calcula o próprio hash; sua cópia interna foi comparada com a
externa. O SHA-256 do ZIP é entregue ao lado do pacote em dist.

Diagramas/protótipos são materiais de modelagem. Resultados manuais e capturas dependem
da execução real pelo estudante. A varredura de texto não examina privacidade em imagens.
'@
$notaDocumentacao = @'
# Pacote de documentação

Abra docs/README.md. Este ZIP contém a documentação, os oito modelos .drawio, os oito
PNGs exportados, o plano original de testes, os scripts auxiliares e as instruções para
evidências. O código operacional e a configuração local não estão neste pacote.

Links relativos para src, public, assets, sql e README da aplicação devem ser consultados
no pacote completo controle-livros-projeto.zip ou no repositório correspondente. Isso
preserva a rastreabilidade sem duplicar o código dentro de um pacote apenas documental.
Scripts de verificação e empacotamento devem ser executados na cópia completa do projeto.

MANIFESTO-SHA256.csv relaciona os arquivos de conteúdo com tamanho e hash, exceto o próprio
manifesto, cuja cópia interna foi conferida com a externa. Os arquivos estão na raiz sem
encapsulamento adicional. Os resultados manuais e capturas não são presumidos.
'@
$somenteDocumentacao = @($publicaveis | Where-Object { $_.Relativo.StartsWith('docs/') -or $_.Relativo.StartsWith('scripts/') -or $_.Relativo -eq 'tests/plano-testes.md' })
$resumo = @(
    New-PacoteVerificado -Nome 'controle-livros-projeto' -Arquivos $publicaveis -Nota $notaProjeto
    New-PacoteVerificado -Nome 'controle-livros-documentacao' -Arquivos $somenteDocumentacao -Nota $notaDocumentacao
)
$resumo | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $pastaDist 'pacotes.json') -Encoding UTF8
$resumo | Format-Table Arquivo,Bytes,Entradas -AutoSize
Write-Output 'ZIPs lidos integralmente, hashes comparados e extração real conferida. Nenhum arquivo do banco local foi usado.'
