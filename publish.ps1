﻿# Publie le trainer sur GitHub : aperçu de ce qui part, confirmation, commit, push.
# Lancement : double-clic sur publish.cmd (ou powershell -ExecutionPolicy Bypass -File .\publish.ps1)
# Trainer statique (index.html autonome) : pas de build. Avant de publier : py tools\sync_langs.py si Sign Reader a changé.
# Premier lancement : crée le dépôt git local et le relie à github.com/TGM-hub/clue-fusion (repo vide).

$ErrorActionPreference = "Continue"   # PowerShell 5.1 : "Stop" rend fatal le stderr de git
Set-Location $PSScriptRoot
$origin = "https://github.com/TGM-hub/clue-fusion.git"
$first = -not (Test-Path ".git")
if ($first) {
    git init -q -b main
    git remote add origin $origin
    Write-Host "Dépôt local créé, relié à $origin" -ForegroundColor Cyan
}
git config core.quotepath false
$branch = git branch --show-current
$remote = git remote get-url origin
$name = ($remote -replace '\.git$', '') -replace '^.*/', ''
$url = "https://tgm-hub.github.io/$name/"

# 1. Se mettre à jour avec GitHub (évite de repartir d'une copie en retard) ; rien à faire si la branche n'y existe pas encore
git fetch -q origin 2>$null
$onRemote = git ls-remote --heads origin $branch
$hasHead = git rev-parse --verify -q HEAD 2>$null
if ($onRemote -and $hasHead) {
    $behind = git rev-list --count "HEAD..origin/$branch"
    if ($behind -ne "0") {
        Write-Host "La copie locale a $behind commit(s) de retard sur GitHub." -ForegroundColor Yellow
        git pull --rebase --autostash -q origin $branch
        if ($LASTEXITCODE -ne 0) { throw "git pull a échoué : règle le conflit avant de publier." }
    }
} elseif ($onRemote -and -not $hasHead) {
    throw "GitHub a déjà des commits sur $branch : clone le repo plutôt que de publier ce dossier."
}

# 2. Aperçu
git add -A
$staged = git diff --cached --name-status
$ahead = if (-not $hasHead) { "0" } elseif ($onRemote) { git rev-list --count "origin/$branch..HEAD" } else { git rev-list --count HEAD }
if (-not $staged -and $ahead -eq "0") { Write-Host "`nRien de nouveau à publier."; exit 0 }
if ($staged) {
    Write-Host "`nFichiers qui vont partir :" -ForegroundColor Cyan
    $staged | ForEach-Object { Write-Host "  $_" }
    if ($hasHead) { Write-Host "`nDétail :" -ForegroundColor Cyan; git --no-pager diff --cached --stat=100 | Select-Object -Last 15 }
} else {
    Write-Host "`nCommits locaux pas encore poussés :" -ForegroundColor Cyan
    git --no-pager log --oneline -10
}
if ((Read-Host "`nPublier sur $name ($branch) ? (o/N)") -notmatch '^[oOyY]') { git reset -q 2>$null; Write-Host "Annulé, rien n'est parti."; exit 1 }

# 3. Commit et push
if ($staged) {
    $def = if ($hasHead) { "Mise à jour {0:yyyy-MM-dd}" -f (Get-Date) } else { "Clue Fusion : premier envoi" }
    $msg = Read-Host "Message de commit (Entrée = « $def »)"
    if (-not $msg) { $msg = $def }
    git commit -q -m $msg -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
    if ($LASTEXITCODE -ne 0) { throw "git commit a échoué" }
}
git push -u origin $branch
if ($LASTEXITCODE -ne 0) { throw "git push a échoué (voir le message ci-dessus)" }
Write-Host "`nPublié. En ligne d'ici une minute : $url" -ForegroundColor Green
if ($first) { Write-Host "Premier envoi : activer GitHub Pages une fois (Settings > Pages > Deploy from a branch > main / root)." -ForegroundColor Yellow }
