$ErrorActionPreference = "Stop"

$repoName = "luvmeow"
$vercelProject = "luvmeow"
$domain = "luvmeow.vercel.app"

Write-Host ""
Write-Host "=== LUVMEOW DEPLOY ===" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------
# 1. Verificar ferramentas
# -------------------------------------------------

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git nao encontrado." -ForegroundColor Red
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI nao encontrado." -ForegroundColor Yellow
    Write-Host "Instalando GitHub CLI..."
    winget install --id GitHub.cli -e
    Write-Host "Feche e abra o PowerShell e rode o script novamente." -ForegroundColor Yellow
    exit
}

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "Vercel CLI nao encontrado. Instalando..." -ForegroundColor Yellow
    npm install -g vercel@latest
}

# -------------------------------------------------
# 2. Login GitHub
# -------------------------------------------------

Write-Host ""
Write-Host "[1/6] Verificando GitHub..." -ForegroundColor Cyan

gh auth status *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Voce precisa logar no GitHub."
    gh auth login
}

$githubUser = gh api user --jq ".login"

Write-Host "GitHub: $githubUser" -ForegroundColor Green

# -------------------------------------------------
# 3. .gitignore basico para nao vazar segredo
# -------------------------------------------------

Write-Host ""
Write-Host "[2/6] Preparando Git..." -ForegroundColor Cyan

$ignoreEntries = @(
    "node_modules/",
    ".next/",
    ".vercel/",
    ".env",
    ".env.local",
    ".env.production",
    ".env.development",
    ".env.*.local"
)

if (-not (Test-Path ".gitignore")) {
    New-Item ".gitignore" -ItemType File | Out-Null
}

$currentIgnore = Get-Content ".gitignore" -ErrorAction SilentlyContinue

foreach ($entry in $ignoreEntries) {
    if ($currentIgnore -notcontains $entry) {
        Add-Content ".gitignore" $entry
    }
}

# -------------------------------------------------
# 4. Criar Git e commit
# -------------------------------------------------

if (-not (Test-Path ".git")) {
    git init
}

git checkout -B main

git add .

$changes = git status --porcelain

if ($changes) {
    git commit -m "Initial commit"
} else {
    Write-Host "Nenhuma alteracao nova para commit." -ForegroundColor DarkGray
}

# -------------------------------------------------
# 5. Criar repo privado no GitHub
# -------------------------------------------------

Write-Host ""
Write-Host "[3/6] Criando repositorio privado..." -ForegroundColor Cyan

gh repo view "$githubUser/$repoName" *> $null

if ($LASTEXITCODE -ne 0) {

    gh repo create "$repoName" `
        --private `
        --source "." `
        --remote "origin"

    Write-Host "Repositorio criado." -ForegroundColor Green

} else {

    Write-Host "Repositorio ja existe. Usando ele." -ForegroundColor Yellow

    $repoUrl = "https://github.com/$githubUser/$repoName.git"

    $originExists = git remote | Select-String "^origin$"

    if ($originExists) {
        git remote set-url origin $repoUrl
    } else {
        git remote add origin $repoUrl
    }
}

Write-Host ""
Write-Host "[4/6] Enviando arquivos para o GitHub..." -ForegroundColor Cyan

git push -u origin main --force-with-lease

Write-Host "GitHub OK: https://github.com/$githubUser/$repoName" -ForegroundColor Green

# -------------------------------------------------
# 6. Login Vercel
# -------------------------------------------------

Write-Host ""
Write-Host "[5/6] Preparando Vercel..." -ForegroundColor Cyan

vercel whoami *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Faca login na Vercel..."
    vercel login
}

# Verifica se projeto existe
vercel project inspect $vercelProject *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Criando projeto Vercel '$vercelProject'..."
    vercel project add $vercelProject
}

# Linka esta pasta ao projeto
vercel link --yes --project $vercelProject

# -------------------------------------------------
# 7. Deploy production
# -------------------------------------------------

Write-Host ""
Write-Host "[6/6] Colocando o site no ar..." -ForegroundColor Cyan

$deploymentUrl = vercel deploy --prod --yes

if ($LASTEXITCODE -ne 0) {
    Write-Host "O deploy falhou." -ForegroundColor Red
    exit 1
}

$deploymentUrl = $deploymentUrl.Trim()

Write-Host ""
Write-Host "Deploy criado:" -ForegroundColor Green
Write-Host $deploymentUrl

# -------------------------------------------------
# 8. Alias luvmeow.vercel.app
# -------------------------------------------------

Write-Host ""
Write-Host "Configurando $domain..." -ForegroundColor Cyan

vercel alias set $deploymentUrl $domain

if ($LASTEXITCODE -eq 0) {

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "         DEPLOY FINALIZADO!"
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "GitHub:"
    Write-Host "https://github.com/$githubUser/$repoName"
    Write-Host ""
    Write-Host "Site:"
    Write-Host "https://$domain" -ForegroundColor Cyan
    Write-Host ""

} else {

    Write-Host ""
    Write-Host "O site foi publicado, mas o dominio" -ForegroundColor Yellow
    Write-Host "$domain nao conseguiu ser atribuido." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Deployment:"
    Write-Host $deploymentUrl
}