# ==============================================================================
# SIGAEDU - Sincronizador de Componentes e Layout
# Desenvolvido sob as diretrizes de @senior-architect e @windows-shell-reliability
# ==============================================================================
#
# Este script lê os componentes comuns (Sidebar, Overlay, Header e Scripts de navegação)
# a partir do arquivo 'unificado.html' (nossa Fonte Única da Verdade) e os propaga
# automaticamente para todas as telas individuais do SIGAEDU.
#
# Como executar:
# No console PowerShell da pasta do projeto, execute:
# .\sync_layout.ps1
#
# ==============================================================================

# Forçar a saída a usar codificação UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SIGAEDU - Sincronizador de Layout Estático" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Verificar se o arquivo unificado.html existe
$unificadoPath = Join-Path $PSScriptRoot "unificado.html"
if (-not (Test-Path $unificadoPath)) {
    Write-Error "O arquivo 'unificado.html' nao foi encontrado na pasta atual!"
    Exit
}

# 2. Ler a Fonte Única da Verdade (unificado.html) com codificação UTF-8
Write-Host "Lendo a Fonte Única da Verdade (unificado.html)..." -ForegroundColor Yellow
$unificadoContent = [System.IO.File]::ReadAllText($unificadoPath, [System.Text.Encoding]::UTF8)

# 3. Extrair os componentes usando expressões regulares .NET com modificador (?s) (single-line / dot matches all)
Write-Host "Extraindo componentes unificados..." -ForegroundColor Yellow

$sidebarRegex = '(?s)<aside id="sidebar"[^>]*>.*?</aside>'
$sidebarMatch = [regex]::Match($unificadoContent, $sidebarRegex)
if (-not $sidebarMatch.Success) {
    Write-Error "Erro: Nao foi possivel encontrar a tag <aside id=`"sidebar`"> em unificado.html"
    Exit
}
$sidebarBlock = $sidebarMatch.Value

$overlayRegex = '(?s)<div id="sidebar-overlay"[^>]*>.*?</div>'
$overlayMatch = [regex]::Match($unificadoContent, $overlayRegex)
if (-not $overlayMatch.Success) {
    Write-Error "Erro: Nao foi possivel encontrar a tag <div id=`"sidebar-overlay`"> em unificado.html"
    Exit
}
$overlayBlock = $overlayMatch.Value

$headerRegex = '(?s)<header class="fixed top-0 right-0 left-0 md:left-64[^>]*>.*?</header>'
$headerMatch = [regex]::Match($unificadoContent, $headerRegex)
if (-not $headerMatch.Success) {
    Write-Error "Erro: Nao foi possivel encontrar o <header> do TopNavBar em unificado.html"
    Exit
}
$headerBlock = $headerMatch.Value

$scriptRegex = '(?s)<script>\s*// Fun.*?function toggleSidebar\(\).*?</script>'
$scriptMatch = [regex]::Match($unificadoContent, $scriptRegex)
if (-not $scriptMatch.Success) {
    Write-Error "Erro: Nao foi possivel encontrar o script de navegacao em unificado.html"
    Exit
}
$scriptBlock = $scriptMatch.Value

# 4. Lista dos arquivos HTML individuais das telas do sistema
$paginas = @(
    "dashboard.html",
    "turmas.html",
    "fichadoaluno.html",
    "sala_aee.html",
    "calendario.html",
    "agenda.html",
    "frequencia.html",
    "ocorrencias.html",
    "solicitacoes.html",
    "whatsapp.html",
    "relatorios.html",
    "boletins.html",
    "usuarios.html"
)

Write-Host "Pronto! Iniciando a propagacao automatica para as paginas..." -ForegroundColor Green
$atualizadosCount = 0

foreach ($pagina in $paginas) {
    $paginaPath = Join-Path $PSScriptRoot $pagina
    
    if (-not (Test-Path $paginaPath)) {
        Write-Host "Aviso: A pagina '$pagina' nao foi encontrada nesta pasta. Pulando..." -ForegroundColor Gray
        continue
    }

    Write-Host "Sincronizando '$pagina'..." -ForegroundColor Yellow

    # Ler o conteúdo da página individual
    $pageContent = [System.IO.File]::ReadAllText($paginaPath, [System.Text.Encoding]::UTF8)

    # Realizar as substituições cirúrgicas com regex
    # Usamos o [regex]::Replace do .NET para garantir a precisão
    $newContent = [regex]::Replace($pageContent, $sidebarRegex, $sidebarBlock)
    $newContent = [regex]::Replace($newContent, $overlayRegex, $overlayBlock)
    $newContent = [regex]::Replace($newContent, $headerRegex, $headerBlock)
    $newContent = [regex]::Replace($newContent, $scriptRegex, $scriptBlock)

    # Substituir a fonte do Material Symbols para display=block e remover duplicatas consecutivas
    $fontBlock = '  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=block" rel="stylesheet"/>'
    $duplicateFontRegex = '(?is)(<link[^>]*Material\+Symbols\+Outlined[^>]*>\s*){1,}'
    $newContent = [regex]::Replace($newContent, $duplicateFontRegex, $fontBlock + "`r`n")

    # Corrigir a classe CSS do Material Symbols para evitar o flash
    $cssRegex = '(?s)\.material-symbols-outlined\s*\{[^}]*\}'
    $cssBlock = ".material-symbols-outlined {`n      font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;`n      display: inline-block;`n      width: 24px;`n      height: 24px;`n      overflow: hidden;`n      text-rendering: optimizeLegibility;`n      -webkit-font-smoothing: antialiased;`n    }"
    $newContent = [regex]::Replace($newContent, $cssRegex, $cssBlock)

    # Escrever de volta o arquivo com codificação UTF-8 pura (sem BOM, padrão web moderno)
    # [System.IO.File]::WriteAllText cuida disso perfeitamente
    $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($paginaPath, $newContent, $utf8NoBOM)

    Write-Host " -> Sincronizada com sucesso!" -ForegroundColor Green
    $atualizadosCount++
}

Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  Sincronizacao Concluida! $atualizadosCount de $($paginas.Count) paginas atualizadas." -ForegroundColor Green
Write-Host "  Todos os menus, cabeçalhos e scripts estao unificados!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
