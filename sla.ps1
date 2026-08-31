# ============================================================
# LUVMEOW - GitHub + Vercel Deploy
# ============================================================

$repoName = "luvmeow"
$vercelProject = "luvmeow"
$domain = "luvmeow.vercel.app"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "          LUVMEOW DEPLOY SCRIPT             " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# FUNCAO DE ERRO
# ============================================================

function Stop-Script {
    param(
        [string]$Message
    )

    Write-Host ""
    Write-Host "ERRO: $Message" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# ============================================================
# 1. VERIFICAR GIT
# ============================================================

Write-Host "[1/9] Verificando Git..." -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Stop-Script "Git nao esta instalado."
}

Write-Host "Git encontrado." -ForegroundColor Green

# ============================================================
# 2. VERIFICAR GITHUB CLI
# ============================================================

Write-Host ""
Write-Host "[2/9] Verificando GitHub CLI..." -ForegroundColor Cyan

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {

    Write-Host "GitHub CLI nao encontrado." -ForegroundColor Yellow
    Write-Host "Tentando instalar com Winget..." -ForegroundColor Yellow

    winget install --id GitHub.cli -e

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Nao consegui instalar o GitHub CLI."
    }

    Write-Host ""
    Write-Host "GitHub CLI instalado." -ForegroundColor Green
    Write-Host "Feche este PowerShell, abra novamente e rode o script outra vez." -ForegroundColor Yellow
    exit
}

Write-Host "GitHub CLI encontrado." -ForegroundColor Green

# ============================================================
# 3. LOGIN NO GITHUB
# ============================================================

Write-Host ""
Write-Host "[3/9] Verificando login do GitHub..." -ForegroundColor Cyan

gh auth status 2>$null | Out-Null

if ($LASTEXITCODE -ne 0) {

    Write-Host "Voce ainda nao esta logado no GitHub." -ForegroundColor Yellow
    Write-Host "Abrindo login..." -ForegroundColor Yellow
    Write-Host ""

    gh auth login

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Login do GitHub falhou."
    }
}

$githubUser = gh api user --jq ".login"

if (-not $githubUser) {
    Stop-Script "Nao consegui descobrir seu usuario do GitHub."
}

$githubUser = $githubUser.Trim()

Write-Host "Logado como: $githubUser" -ForegroundColor Green

# ============================================================
# 4. PREPARAR .GITIGNORE
# ============================================================

Write-Host ""
Write-Host "[4/9] Preparando projeto..." -ForegroundColor Cyan

if (-not (Test-Path ".gitignore")) {
    New-Item -Path ".gitignore" -ItemType File | Out-Null
}

$ignoreEntries = @(
    "node_modules/",
    ".next/",
    ".vercel/",
    "dist/",
    "build/",
    ".env",
    ".env.local",
    ".env.development.local",
    ".env.test.local",
    ".env.production.local"
)

$currentIgnore = @(Get-Content ".gitignore" -ErrorAction SilentlyContinue)

foreach ($entry in $ignoreEntries) {

    if ($currentIgnore -notcontains $entry) {
        Add-Content -Path ".gitignore" -Value $entry
    }
}

Write-Host ".gitignore preparado." -ForegroundColor Green

# ============================================================
# 5. PREPARAR REPOSITORIO GIT LOCAL
# ============================================================

Write-Host ""
Write-Host "[5/9] Preparando repositorio Git local..." -ForegroundColor Cyan

if (-not (Test-Path ".git")) {

    Write-Host "Inicializando Git..." -ForegroundColor Yellow

    git init

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "git init falhou."
    }
}

# Configura nome/email local apenas se nao houver configuracao

$gitName = git config user.name
$gitEmail = git config user.email

if (-not $gitName) {
    git config user.name "$githubUser"
}

if (-not $gitEmail) {
    git config user.email "$githubUser@users.noreply.github.com"
}

# Adiciona arquivos

git add .

if ($LASTEXITCODE -ne 0) {
    Stop-Script "git add falhou."
}

# Verifica se existe commit

git rev-parse --verify HEAD 2>$null | Out-Null
$hasCommit = ($LASTEXITCODE -eq 0)

if (-not $hasCommit) {

    Write-Host "Criando primeiro commit..." -ForegroundColor Yellow

    git commit -m "Initial commit"

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Nao consegui criar o primeiro commit."
    }

} else {

    # Verifica alteracoes
    $changes = git status --porcelain

    if ($changes) {

        Write-Host "Alteracoes encontradas. Criando commit..." -ForegroundColor Yellow

        git commit -m "Update project"

        if ($LASTEXITCODE -ne 0) {
            Stop-Script "Nao consegui criar o commit."
        }

    } else {

        Write-Host "Nenhuma alteracao nova para commit." -ForegroundColor DarkGray
    }
}

# Garante branch main

git branch -M main

if ($LASTEXITCODE -ne 0) {
    Stop-Script "Nao consegui configurar a branch main."
}

Write-Host "Git local pronto." -ForegroundColor Green

# ============================================================
# 6. CRIAR REPOSITORIO PRIVADO NO GITHUB
# ============================================================

Write-Host ""
Write-Host "[6/9] Preparando GitHub..." -ForegroundColor Cyan

# IMPORTANTE:
# Aqui nao usamos ErrorActionPreference Stop.
# Repo inexistente e uma situacao NORMAL.

gh repo view "$githubUser/$repoName" --json name 2>$null | Out-Null

$repoExists = ($LASTEXITCODE -eq 0)

if (-not $repoExists) {

    Write-Host "Repositorio nao existe ainda." -ForegroundColor Yellow
    Write-Host "Criando $githubUser/$repoName..." -ForegroundColor Yellow

    gh repo create "$githubUser/$repoName" --private

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Nao consegui criar o repositorio no GitHub."
    }

    Write-Host "Repositorio privado criado!" -ForegroundColor Green

} else {

    Write-Host "Repositorio $githubUser/$repoName ja existe." -ForegroundColor Green
}

# ============================================================
# 7. CONFIGURAR ORIGIN + PUSH
# ============================================================

Write-Host ""
Write-Host "[7/9] Enviando projeto para o GitHub..." -ForegroundColor Cyan

$repoUrl = "https://github.com/$githubUser/$repoName.git"

$origin = git remote get-url origin 2>$null

if ($LASTEXITCODE -eq 0) {

    Write-Host "Atualizando origin..." -ForegroundColor DarkGray
    git remote set-url origin "$repoUrl"

} else {

    Write-Host "Adicionando origin..." -ForegroundColor DarkGray
    git remote add origin "$repoUrl"
}

if ($LASTEXITCODE -ne 0) {
    Stop-Script "Nao consegui configurar o remote origin."
}

git push -u origin main

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "O push normal falhou." -ForegroundColor Red
    Write-Host ""
    Write-Host "Isso pode acontecer se o repositorio remoto ja tiver arquivos." -ForegroundColor Yellow
    Write-Host "Nao vou dar force automaticamente para nao apagar algo sem querer." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Repositorio:" -ForegroundColor Yellow
    Write-Host "https://github.com/$githubUser/$repoName"
    Write-Host ""

    exit 1
}

Write-Host ""
Write-Host "Projeto enviado para:" -ForegroundColor Green
Write-Host "https://github.com/$githubUser/$repoName" -ForegroundColor Cyan

# ============================================================
# 8. VERIFICAR / INSTALAR VERCEL CLI
# ============================================================

Write-Host ""
Write-Host "[8/9] Preparando Vercel..." -ForegroundColor Cyan

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {

    Write-Host "Vercel CLI nao encontrado." -ForegroundColor Yellow

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {

        Write-Host ""
        Write-Host "npm tambem nao foi encontrado." -ForegroundColor Red
        Write-Host "Instale Node.js primeiro e rode o script novamente." -ForegroundColor Yellow
        Write-Host ""

        exit 1
    }

    Write-Host "Instalando Vercel CLI..." -ForegroundColor Yellow

    npm install -g vercel@latest

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Nao consegui instalar o Vercel CLI."
    }

    Write-Host "Vercel CLI instalado." -ForegroundColor Green
}

# Login

vercel whoami 2>$null | Out-Null

if ($LASTEXITCODE -ne 0) {

    Write-Host ""
    Write-Host "Voce ainda nao esta logado na Vercel." -ForegroundColor Yellow
    Write-Host "Abrindo login..." -ForegroundColor Yellow
    Write-Host ""

    vercel login

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Login na Vercel falhou."
    }
}

$vercelUser = vercel whoami 2>$null

Write-Host "Vercel: $vercelUser" -ForegroundColor Green

# ============================================================
# 9. CRIAR/LINKAR PROJETO + DEPLOY
# ============================================================

Write-Host ""
Write-Host "[9/9] Colocando luvmeow no ar..." -ForegroundColor Cyan

# Verifica se o projeto ja existe na Vercel

vercel project inspect "$vercelProject" 2>$null | Out-Null

$vercelProjectExists = ($LASTEXITCODE -eq 0)

if (-not $vercelProjectExists) {

    Write-Host "Projeto Vercel nao existe ainda." -ForegroundColor Yellow
    Write-Host "Criando projeto '$vercelProject'..." -ForegroundColor Yellow

    vercel project add "$vercelProject"

    if ($LASTEXITCODE -ne 0) {
        Stop-Script "Nao consegui criar o projeto na Vercel."
    }

    Write-Host "Projeto Vercel criado." -ForegroundColor Green

} else {

    Write-Host "Projeto Vercel '$vercelProject' ja existe." -ForegroundColor Green
}

# Linkar pasta atual com o projeto

Write-Host ""
Write-Host "Linkando pasta ao projeto Vercel..." -ForegroundColor Yellow

vercel link --yes --project "$vercelProject"

if ($LASTEXITCODE -ne 0) {
    Stop-Script "Nao consegui linkar a pasta ao projeto Vercel."
}

# Deploy de producao

Write-Host ""
Write-Host "Fazendo deploy de producao..." -ForegroundColor Cyan
Write-Host ""

$deployOutput = @(& vercel deploy --prod --yes)

$deployExitCode = $LASTEXITCODE

if ($deployExitCode -ne 0) {
    Stop-Script "O deploy da Vercel falhou."
}

$deploymentUrl = $null

foreach ($line in $deployOutput) {

    $text = "$line"

    if ($text -match "https://[A-Za-z0-9._-]+\.vercel\.app") {
        $deploymentUrl = $Matches[0]
    }
}

if (-not $deploymentUrl) {

    Write-Host ""
    Write-Host "Deploy terminou, mas nao consegui detectar a URL automaticamente." -ForegroundColor Yellow
    Write-Host "Confira o dashboard da Vercel." -ForegroundColor Yellow

} else {

    Write-Host ""
    Write-Host "Deployment criado:" -ForegroundColor Green
    Write-Host "$deploymentUrl" -ForegroundColor Cyan

    # ========================================================
    # TENTAR DEFINIR luvmeow.vercel.app
    # ========================================================

    Write-Host ""
    Write-Host "Tentando configurar https://$domain ..." -ForegroundColor Cyan

    vercel alias set "$deploymentUrl" "$domain"

    if ($LASTEXITCODE -eq 0) {

        Write-Host ""
        Write-Host "Dominio configurado!" -ForegroundColor Green

    } else {

        Write-Host ""
        Write-Host "Nao consegui atribuir $domain." -ForegroundColor Yellow
        Write-Host "Isso normalmente significa que esse nome ja esta ocupado ou indisponivel." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Mas o deploy continua funcionando em:" -ForegroundColor Yellow
        Write-Host "$deploymentUrl" -ForegroundColor Cyan
    }
}

# ============================================================
# FINAL
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "              TUDO PRONTO                  " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "GitHub:" -ForegroundColor White
Write-Host "https://github.com/$githubUser/$repoName" -ForegroundColor Cyan

Write-Host ""

if ($deploymentUrl) {
    Write-Host "Deployment Vercel:" -ForegroundColor White
    Write-Host "$deploymentUrl" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Dominio desejado:" -ForegroundColor White
Write-Host "https://$domain" -ForegroundColor Cyan
Write-Host ""

Write-Host "Finalizado :)" -ForegroundColor Green
Write-Host ""