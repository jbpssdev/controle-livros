# Funções compartilhadas de seleção e inspeção. Não abre conexão nem escreve no banco.

function Get-ArquivosPublicaveis {
    param([Parameter(Mandatory)][string]$Raiz)
    $raizCompleta = (Resolve-Path -LiteralPath $Raiz).Path.TrimEnd('\', '/')
    $selecionados = @()
    foreach ($nome in @('.gitignore', 'README.md', 'index.php')) {
        $caminho = Join-Path $raizCompleta $nome
        if (Test-Path -LiteralPath $caminho -PathType Leaf) { $selecionados += Get-Item -LiteralPath $caminho -Force }
    }
    foreach ($pasta in @('assets', 'config', 'docs', 'layouts', 'public', 'scripts', 'sql', 'src', 'tests')) {
        $caminho = Join-Path $raizCompleta $pasta
        if (Test-Path -LiteralPath $caminho -PathType Container) {
            $selecionados += Get-ChildItem -LiteralPath $caminho -File -Recurse -Force
        }
    }
    foreach ($arquivo in ($selecionados | Sort-Object FullName -Unique)) {
        $relativo = $arquivo.FullName.Substring($raizCompleta.Length + 1).Replace('\', '/')
        if ($relativo -match '(^|/)(\.git|\.runtime|dist|node_modules|__pycache__|cache|caches)(/|$)' -or
            $relativo -eq 'config/database.php' -or $arquivo.Name -like '.env*' -or
            $arquivo.Extension -match '^\.(zip|log|tmp|bak|db|sqlite|sqlite3|pyc)$') { continue }
        # A pasta config tem somente o exemplo como conteúdo publicável.
        if ($relativo.StartsWith('config/') -and $relativo -ne 'config/database.example.php') { continue }
        # Os únicos SQL publicáveis são os scripts de estrutura e demonstração conhecidos.
        if ($arquivo.Extension -eq '.sql' -and $relativo -notin @('sql/estrutura.sql', 'sql/exemplos.sql')) { continue }
        if ($arquivo.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Link de arquivo não permitido no pacote: $relativo" }
        [pscustomobject]@{ Relativo = $relativo; Caminho = $arquivo.FullName; Tamanho = $arquivo.Length }
    }
}

function Find-CredenciaisPublicaveis {
    param([Parameter(Mandatory)][array]$Arquivos)
    $padroes = [ordered]@{
        'token com prefixo reconhecível' = '(?:gh[pousr]_[A-Za-z0-9]{25,}|github_pat_[A-Za-z0-9_]{30,}|sk-proj-[A-Za-z0-9_-]{25,})'
        'chave privada literal' = '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'
        'credencial em URL' = 'https?://[^\s/:]+:[^\s/@]+@'
        'senha SQL literal' = '(?i)IDENTIFIED\s+BY\s+[''"][^''"\r\n]+[''"]'
        'atribuição literal sensível' = '(?i)[''"](?:password|passwd|senha|secret|api[_-]?key|access[_-]?token)[''"]\s*(?:=>|:|=)\s*[''"][^''"\r\n]+[''"]'
    }
    foreach ($arquivo in $Arquivos) {
        if ([IO.Path]::GetExtension($arquivo.Relativo) -notin @('.php', '.md', '.sql', '.ps1', '.py', '.js', '.css', '.drawio', '.json', '.txt')) { continue }
        $conteudo = [IO.File]::ReadAllText($arquivo.Caminho)
        foreach ($padrao in $padroes.GetEnumerator()) {
            if ([regex]::IsMatch($conteudo, $padrao.Value)) {
                # Nunca imprimir o trecho encontrado: ele pode conter o próprio segredo.
                [pscustomobject]@{ Arquivo = $arquivo.Relativo; Regra = $padrao.Key }
            }
        }
    }
}

function Get-RastreabilidadeProjeto {
    @(
        @{ RF='RF01'; CU='CU01'; Pagina='public/novo-livro.php'; Acao='public/actions/salvar-livro.php'; Classe='AcervoService'; Metodo='cadastrarLivro' },
        @{ RF='RF02'; CU='CU02'; Pagina='public/index.php'; Acao=$null; Classe='Livro'; Metodo='listar' },
        @{ RF='RF03'; CU='CU03'; Pagina='public/editar-livro.php'; Acao='public/actions/atualizar-livro.php'; Classe='AcervoService'; Metodo='atualizarLivro' },
        @{ RF='RF04'; CU='CU04'; Pagina='public/movimentacoes.php'; Acao='public/actions/registrar-movimentacao.php'; Classe='AcervoService'; Metodo='movimentar' },
        @{ RF='RF05'; CU='CU05'; Pagina='public/movimentacoes.php'; Acao=$null; Classe='Movimentacao'; Metodo='listar' }
    )
}

function Read-XmlSeguro {
    param([Parameter(Mandatory)][string]$Texto)
    $config = New-Object System.Xml.XmlReaderSettings
    $config.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $config.XmlResolver = $null
    $leitorTexto = New-Object System.IO.StringReader($Texto)
    $leitor = [System.Xml.XmlReader]::Create($leitorTexto, $config)
    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.PreserveWhitespace = $false
        $xml.XmlResolver = $null
        $xml.Load($leitor)
        return ,$xml
    } finally { $leitor.Dispose(); $leitorTexto.Dispose() }
}

function Get-ModeloPng {
    param([Parameter(Mandatory)][string]$Caminho)
    $bytes = [IO.File]::ReadAllBytes($Caminho)
    if ($bytes.Length -lt 33 -or [BitConverter]::ToString($bytes, 0, 8) -ne '89-50-4E-47-0D-0A-1A-0A') { throw 'Assinatura PNG inválida.' }
    $offset = 8
    $modelo = $null
    $fim = $false
    while ($offset + 12 -le $bytes.Length) {
        $tamanhoBytes = $bytes[$offset..($offset+3)]
        [Array]::Reverse($tamanhoBytes)
        $tamanho = [BitConverter]::ToUInt32([byte[]]$tamanhoBytes, 0)
        if ($tamanho -gt 33554432 -or $offset + 12 + $tamanho -gt $bytes.Length) { throw 'Chunk PNG inválido ou excessivo.' }
        $tipo = [Text.Encoding]::ASCII.GetString($bytes, $offset+4, 4)
        if ($tipo -eq 'zTXt' -and $tamanho -gt 0) {
            [byte[]]$dados = $bytes[($offset+8)..($offset+7+$tamanho)]
            $zero = [Array]::IndexOf($dados, [byte]0)
            if ($zero -gt 0 -and [Text.Encoding]::ASCII.GetString($dados, 0, $zero) -in @('mxGraphModel', 'mxfile')) {
                if ($dados[$zero+1] -ne 0) { throw 'Compressão de metadados PNG não reconhecida.' }
                [byte[]]$zlib = $dados[($zero+2)..($dados.Length-1)]
                # DeflateStream usa o fluxo bruto: remover cabeçalho zlib (2) e Adler32 (4).
                $bruto = New-Object IO.MemoryStream
                $bruto.Write($zlib, 2, $zlib.Length-6)
                $bruto.Position = 0
                $inflador = New-Object IO.Compression.DeflateStream($bruto, [IO.Compression.CompressionMode]::Decompress)
                $saida = New-Object IO.MemoryStream
                try {
                    $inflador.CopyTo($saida)
                    $modelo = [Uri]::UnescapeDataString([Text.Encoding]::UTF8.GetString($saida.ToArray()))
                } finally { $inflador.Dispose(); $saida.Dispose(); $bruto.Dispose() }
            }
        }
        $offset += 12 + $tamanho
        if ($tipo -eq 'IEND') { $fim = $true; break }
    }
    if (-not $fim -or -not $modelo) { throw 'PNG sem IEND ou sem modelo draw.io embutido.' }
    return Read-XmlSeguro -Texto $modelo
}
