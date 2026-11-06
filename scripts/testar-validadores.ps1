[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$raizProjeto = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'ProjetoTools.ps1')
$pastaTeste = Join-Path $raizProjeto 'dist/testes-validadores'
New-Item -ItemType Directory -Path $pastaTeste -Force | Out-Null
$fixture = Join-Path $pastaTeste 'amostra-scanner.txt'

# Valor sintético, deliberadamente sem validade como credencial; não é publicado.
[IO.File]::WriteAllText($fixture, ('ghp_' + ('A' * 40)))
$entrada = @([pscustomobject]@{ Relativo='amostra-scanner.txt'; Caminho=$fixture })
$achados = @(Find-CredenciaisPublicaveis -Arquivos $entrada)
if ($achados.Count -ne 1 -or $achados[0].Regra -ne 'token com prefixo reconhecível') { throw 'Scanner não reconheceu a amostra sintética.' }
[IO.File]::WriteAllText($fixture, 'Texto comum de ensaio, sem credenciais.')
if (@(Find-CredenciaisPublicaveis -Arquivos $entrada).Count -ne 0) { throw 'Scanner rejeitou a amostra limpa.' }
Write-Output '[VERIFICADO] Scanner: padrão sintético detectado e texto limpo aceito.'

$copia = Join-Path $raizProjeto 'dist/verificacao-extraida/controle-livros-projeto'
$verificadorCopia = Join-Path $copia 'scripts/verificar-projeto.ps1'
$modeloCopia = Join-Path $copia 'docs/diagramas/classes.drawio'
if (-not (Test-Path -LiteralPath $modeloCopia -PathType Leaf)) { throw 'Execute gerar-pacotes.ps1 antes deste teste para criar a cópia extraída.' }
$modeloOriginal = [IO.File]::ReadAllText($modeloCopia)
$divergente = $modeloOriginal.Replace('Classes PHP e dependências', 'Classes PHP - alteração controlada')
if ($divergente -eq $modeloOriginal) { throw 'Rótulo de controle não encontrado no modelo.' }
$jsonDivergencia = Join-Path $pastaTeste 'divergencia.json'
try {
    [IO.File]::WriteAllText($modeloCopia, $divergente)
    $rejeitou = $false
    try { & $verificadorCopia -RelatorioJson $jsonDivergencia *> (Join-Path $pastaTeste 'divergencia.log') }
    catch { $rejeitou = $true }
    $resultado = Get-Content -LiteralPath $jsonDivergencia -Raw | ConvertFrom-Json
    $png = $resultado.Resultados | Where-Object Item -eq 'PNG / fonte: docs/diagramas/classes'
    if (-not $rejeitou -or $png.Status -ne 'FALHA') { throw 'Divergência controlada entre modelo e PNG não foi rejeitada.' }
} finally {
    # Restaura a cópia descartável; o editável da aplicação nunca foi alterado.
    [IO.File]::WriteAllText($modeloCopia, $modeloOriginal)
}
Write-Output '[VERIFICADO] PNG/editável: divergência rejeitada na cópia extraída; cópia restaurada.'

$jsonSemPhp = Join-Path $pastaTeste 'sem-php.json'
& (Join-Path $PSScriptRoot 'verificar-projeto.ps1') -PhpPath (Join-Path $pastaTeste 'executavel-inexistente.exe') -RelatorioJson $jsonSemPhp *> (Join-Path $pastaTeste 'sem-php.log')
$semPhp = Get-Content -LiteralPath $jsonSemPhp -Raw | ConvertFrom-Json
$lint = $semPhp.Resultados | Where-Object Item -eq 'Sintaxe PHP'
if ($lint.Status -ne 'NAO_VERIFICADO') { throw 'Ausência de PHP não foi declarada como não verificada.' }
Write-Output '[VERIFICADO] Ausência de PHP: lint marcado NAO_VERIFICADO, sem aprovação presumida.'
Write-Output 'Ensaios dos validadores concluídos sem conexão com banco. Logs em dist/testes-validadores.'
