[CmdletBinding()]
param(
    [string]$DrawioPath,
    [ValidateRange(1, 4)][double]$Escala = 2
)

$ErrorActionPreference = 'Stop'
$raizProjeto = Split-Path -Parent $PSScriptRoot
if (-not $DrawioPath) {
    $candidatos = @(
        (Join-Path $env:ProgramFiles 'draw.io\draw.io.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\draw.io\draw.io.exe'),
        (Join-Path $raizProjeto '.runtime\ferramentas\drawio\draw.io.exe')
    )
    $DrawioPath = $candidatos | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}
if (-not $DrawioPath -or -not (Test-Path -LiteralPath $DrawioPath -PathType Leaf)) {
    throw 'draw.io Desktop não encontrado. Informe -DrawioPath com o executável oficial. Consulte docs/diagramas/LEITURA.md.'
}

$pastaLog = Join-Path $raizProjeto 'dist\logs-exportacao'
$perfilExportacao = Join-Path $pastaLog 'perfil-drawio'
New-Item -ItemType Directory -Path $pastaLog -Force | Out-Null
$fontes = @(Get-ChildItem -LiteralPath (Join-Path $raizProjeto 'docs\diagramas'), (Join-Path $raizProjeto 'docs\prototipos') -Filter '*.drawio' -File)
if ($fontes.Count -ne 8) { throw 'Esperadas exatamente oito fontes draw.io nas pastas de modelagem.' }

foreach ($fonte in $fontes) {
    $saida = [IO.Path]::ChangeExtension($fonte.FullName, '.png')
    $argumentos = @(
        '--export', '--format', 'png', '--scale', $Escala.ToString([Globalization.CultureInfo]::InvariantCulture),
        '--border', '20', '--size', 'page', '--theme', 'light', '--embed-diagram', '--timeout', '45',
        '--disable-update', ('--user-data-dir="' + $perfilExportacao + '"'),
        '--output', ('"' + $saida + '"'), ('"' + $fonte.FullName + '"')
    )
    $prefixo = if ($fonte.Directory.Name -eq 'prototipos') { 'prototipo-' } else { 'diagrama-' }
    $log = Join-Path $pastaLog ($prefixo + $fonte.BaseName + '.log')
    $erros = Join-Path $pastaLog ($prefixo + $fonte.BaseName + '.stderr.log')
    # CLI oficial; não abre janela interativa nem modifica a configuração do XAMPP.
    $processo = Start-Process -FilePath $DrawioPath -ArgumentList $argumentos -WindowStyle Hidden -PassThru -RedirectStandardOutput $log -RedirectStandardError $erros
    if (-not $processo.WaitForExit(55000)) {
        $processo.Kill()
        throw "Exportação excedeu o limite: $($fonte.Name). Consulte $erros"
    }
    if ($processo.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $saida -PathType Leaf)) {
        throw "Falha na exportação oficial de $($fonte.Name). Consulte $log e $erros"
    }
    Write-Output "EXPORTADO: $($fonte.Directory.Name)/$($fonte.BaseName).png"
}
Write-Output 'Oito PNGs exportados pelo draw.io. Execute verificar-projeto.ps1 e confira visualmente as imagens.'
