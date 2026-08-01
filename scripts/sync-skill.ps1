<#
.SYNOPSIS
  Sync a WorkBuddy skill from its active directory to a local git repo and push
  to Gitee (primary, domestic direct) + GitHub (mirror).
.DESCRIPTION
  Copies the skill into a local repo folder, commits changes, then pushes to the
  configured remotes. Designed for dual-platform open-sourcing of WorkBuddy skills.
  Any single push failure is non-fatal; the other remote still syncs.

  This is the GENERIC version: no usernames are hard-coded. Pass your own via
  -GiteeRemote / -GitHubRemote (or configure remotes manually beforehand).
.PARAMETER SkillName
  The skill folder name, e.g. "psych-ally". (Required)
.PARAMETER SourceSkillPath
  Full path to the ACTIVE skill (the one WorkBuddy loads). Default:
  "$env:USERPROFILE\.workbuddy\skills\<SkillName>"
.PARAMETER RepoPath
  Full path to the local git repo copy (the open-source mirror). Required.
.PARAMETER GiteeRemote
  Gitee remote URL, e.g. "https://gitee.com/<你的用户名>/<SkillName>.git".
  If provided and not yet configured, it is added/updated.
.PARAMETER GitHubRemote
  GitHub remote URL, e.g. "https://github.com/<你的用户名>/<SkillName>.git".
  If provided and not yet configured, it is added/updated.
.EXAMPLE
  .\sync-skill.ps1 -SkillName psych-ally `
    -RepoPath "F:\repo\psych-ally" `
    -GiteeRemote https://gitee.com/<你的用户名>/psych-ally.git `
    -GitHubRemote https://github.com/<你的用户名>/psych-ally.git
#>

param(
    [Parameter(Mandatory=$true)][string]$SkillName,
    [string]$SourceSkillPath = "$env:USERPROFILE\.workbuddy\skills\$SkillName",
    [Parameter(Mandatory=$true)][string]$RepoPath,
    [string]$GiteeRemote,
    [string]$GitHubRemote
)

$ErrorActionPreference = "Stop"
function Write-Step($m){ Write-Host "`n==> $m" -ForegroundColor Cyan }

# ---- 1. validate source ----
Write-Step "Validate source skill"
if (-not (Test-Path "$SourceSkillPath\SKILL.md")) {
    Write-Error "Source skill not found (no SKILL.md): $SourceSkillPath"
}
Write-Host "Source : $SourceSkillPath"

# ---- 2. ensure repo dir + git init ----
Write-Step "Ensure repo at $RepoPath"
if (-not (Test-Path $RepoPath)) {
    New-Item -ItemType Directory -Path $RepoPath -Force | Out-Null
}
Push-Location $RepoPath
try {
    if (-not (Test-Path ".git")) {
        git init -q
        Write-Host "git initialized"
    }

    # ---- 3. configure remotes if provided ----
    if ($GiteeRemote) {
        $has = git remote get-url gitee 2>$null
        if ($has) { git remote set-url gitee $GiteeRemote } else { git remote add gitee $GiteeRemote }
        Write-Host "remote gitee -> $GiteeRemote"
    }
    if ($GitHubRemote) {
        $has = git remote get-url origin 2>$null
        if ($has) { git remote set-url origin $GitHubRemote } else { git remote add origin $GitHubRemote }
        Write-Host "remote origin -> $GitHubRemote"
    }

    # ---- 4. sync files (incremental, keep .git, keep .gitignore etc.) ----
    Write-Step "Robocopy active skill -> repo"
    robocopy "$SourceSkillPath" "$RepoPath" /E /XD .git /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "files synced"

    # ---- 5. commit if changed ----
    Write-Step "Stage + commit if changed"
    git add -A
    $diff = git status --porcelain
    if ($diff) {
        $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -q -m "sync: $SkillName @ $stamp"
        Write-Host "committed ($(($diff | Measure-Object -Line).Lines) file changes)"
    } else {
        Write-Host "no changes, skip commit"
    }

    # ---- 6. push (each non-fatal) ----
    Write-Step "Push to gitee (primary)"
    try { git push -u gitee master 2>&1 | Select-Object -Last 5 } catch { Write-Host "gitee push skipped: $_" }

    Write-Step "Push to origin (mirror)"
    try { git push -u origin master 2>&1 | Select-Object -Last 5 } catch { Write-Host "origin push skipped: $_" }

    Write-Step "Done. Repo: $RepoPath"
} finally {
    Pop-Location
}
