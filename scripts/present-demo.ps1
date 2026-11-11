#requires -Version 7.0
<#
Interactive presenter walkthrough. Requires PowerShell 7, not Windows PowerShell 5.1.
Use start-presenter.cmd for a dedicated presenter window separate from VS Code.
PrepareOnly renders the local prompt without changing Git or using the clipboard.
ResumeAfterGeneration starts at PRD review; NoPublish stops before Git changes.
The script never invokes Copilot, accepts a EULA, or retrieves tenant content.
#>
[CmdletBinding()]
param(
    [switch]$PrepareOnly,
    [switch]$ResumeAfterGeneration,
    [switch]$NoPublish,
    [string]$Repository,
    [string]$Branch = ("spec/intelligent-escalation-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$prdRelative = "docs/specs/intelligent-escalation-prd.md"
$prd = Join-Path $root "docs\specs\intelligent-escalation-prd.md"
$local = Join-Path $root ".local"
$renderedPrompt = Join-Path $local "workiq-prompt.txt"

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed (exit $LASTEXITCODE). Stop here; inspect the error before rerunning."
    }
}

function Pause-Demo {
    param([string]$Message = "Press any key to continue (Ctrl+C to stop).")
    Write-Host "`n$Message" -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-Section {
    param([string]$Title, [string]$Narration)
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host $Narration
}

function Confirm-Demo {
    param([string]$Message)
    if ((Read-Host "$Message Type YES to continue") -cne "YES") {
        throw "Not confirmed. No further steps were performed."
    }
}

function New-LocalPrompt {
    $envFile = Join-Path $root ".env"
    if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) {
        throw "Copy .env.example to .env and set the three source file URLs first."
    }
    $keys = @("BUSINESS_BRIEF_URL", "DECISION_TRANSCRIPT_URL", "COMPLIANCE_NOTE_URL")
    $values = @{}
    foreach ($line in Get-Content -LiteralPath $envFile) {
        $text = $line.Trim()
        if (-not $text -or $text.StartsWith("#")) { continue }
        if ($text -notmatch '^([A-Z_]+)=(.*)$' -or $Matches[1] -notin $keys) {
            throw "Unsupported .env entry. Use only the three keys in .env.example; no shell expressions."
        }
        $key = $Matches[1]
        $value = $Matches[2].Trim()
        if ($values.ContainsKey($key)) { throw "Duplicate .env key: $key" }
        if ($value.Length -ge 2 -and (
            ($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        $uri = $null
        if (-not [uri]::TryCreate($value, [UriKind]::Absolute, [ref]$uri) -or
            $uri.Scheme -ne "https" -or $uri.Host -eq "example.invalid" -or
            $uri.UserInfo -or $value -match '[\s`{}]' -or $value -match '/:f:/') {
            throw "Invalid $key. Use an individual HTTPS file URL, with no wrappers, credentials, or example.invalid host."
        }
        $values[$key] = $value
    }
    foreach ($key in $keys) {
        if (-not $values.ContainsKey($key)) { throw "Missing .env key: $key" }
    }
    $template = Get-Content -LiteralPath (Join-Path $root "demo\workiq-prompt.md") -Raw
    $promptMatch = [regex]::Match($template,
        '(?s)## Prompt to paste into GitHub Copilot Chat\s*\r?\n(.*?)\r?\n## Expected visible result')
    if (-not $promptMatch.Success) { throw "Could not locate prompt boundaries in the template." }
    $prompt = [regex]::Replace($promptMatch.Groups[1].Value.Trim(), '(?m)^> ?', '')
    foreach ($key in $keys) { $prompt = $prompt.Replace('${' + $key + '}', $values[$key]) }
    if ($prompt -match '\$\{|\{\{') { throw "Unresolved prompt variables remain." }
    $null = New-Item -ItemType Directory -Path $local -Force
    Set-Content -LiteralPath $renderedPrompt -Value $prompt -Encoding utf8
    Write-Host "Prepared ignored .local\workiq-prompt.txt. Source URLs were not printed."
}

function Show-PrdSection {
    param([string]$Heading)
    $content = Get-Content -LiteralPath $prd -Raw
    $pattern = '(?ms)^## ' + [regex]::Escape($Heading) + '\r?\n.*?(?=^## |\z)'
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { throw "PRD section missing: $Heading" }
    Write-Host $match.Value
}

Push-Location $root
try {
    if ($PrepareOnly) {
        if ($ResumeAfterGeneration) { throw "PrepareOnly and ResumeAfterGeneration cannot be combined." }
        New-LocalPrompt
        return
    }

    foreach ($command in @("git", "gh", "pwsh")) { $null = Get-Command $command -ErrorAction Stop }
    $gitRoot = (Invoke-Checked git @("rev-parse", "--show-toplevel")).Trim()
    if ([IO.Path]::GetFullPath($gitRoot) -ne [IO.Path]::GetFullPath($root)) {
        throw "Run from a dedicated clone of the working demo repository, not a nested folder."
    }
    if (-not $NoPublish) {
        if (-not $Repository -or $Repository -notmatch '^[\w.-]+/[\w.-]+$') {
            throw "Supply -Repository OWNER/WORKING-DEMO-REPO to explicitly select the publication destination."
        }
        $origin = (Invoke-Checked git @("config", "--get", "remote.origin.url")).Trim()
        if ($origin -notmatch ('^(?:https://github\.com/|git@github\.com:)' +
            [regex]::Escape($Repository) + '(?:\.git)?/?$')) {
            throw "origin does not match -Repository. Do not publish from the source-kit checkout."
        }
        $repoInfo = ((Invoke-Checked gh @("repo", "view", $Repository,
            "--json", "nameWithOwner,defaultBranchRef,visibility")) -join "`n") | ConvertFrom-Json
        $base = $repoInfo.defaultBranchRef.name
        if (-not $base) { throw "The remote repository needs an initialized default branch." }
        $currentBranch = (Invoke-Checked git @("branch", "--show-current")).Trim()
        if ($currentBranch -ne $base) {
            throw "Start on the default branch ($base). For interrupted runs, inspect existing work before resuming manually."
        }
        $null = Invoke-Checked git @("check-ref-format", "--branch", $Branch)
        $localBranches = Invoke-Checked git @("branch", "--list", $Branch)
        $remoteBranches = Invoke-Checked git @("ls-remote", "--heads", "origin", "refs/heads/$Branch")
        if ($localBranches -or $remoteBranches) { throw "Branch already exists. Choose a new -Branch; no reset was attempted." }
        $basePrd = Invoke-Checked git @("ls-tree", "--name-only", "HEAD", "--", $prdRelative)
        if ($basePrd) { throw "The starting branch already tracks the generated PRD. Use a clean demo clone." }
    }

    # Keep unrelated work out of the one-file handoff, including pre-staged files.
    $status = @(Invoke-Checked git @("status", "--porcelain", "--untracked-files=all"))
    foreach ($line in $status) {
        if ($line -cne "?? $prdRelative") {
            throw "Unexpected workspace change: $line. Preserve it and use a clean demo checkout."
        }
    }
    if (-not $ResumeAfterGeneration -and (Test-Path -LiteralPath $prd)) {
        throw "PRD already exists. Use -ResumeAfterGeneration for an explicitly disclosed earlier result."
    }

    if (-not $ResumeAfterGeneration) {
        New-LocalPrompt
        Show-Section "1 - Start with the whiteboard story" @"
SHOW: demo\diagrams\01-business-to-engineering.png, then 02-decision-change.png.
SAY: Business context becomes a cited engineering draft. An explicit decision
changes 70 to 80. Our OneDrive documents simulate a brief, transcript and email;
we are not claiming live Teams/Outlook retrieval or deploying an application.
"@
        Pause-Demo

        Show-Section "2 - Hand off to GitHub Copilot" @"
Open a fresh agent conversation in this working demo workspace with WorkIQ tools
enabled. Paste .local\workiq-prompt.txt, submit it, and approve understood reads
and the requested PRD edit. Expand a WorkIQ result so retrieval is visible.
If any source is missing, stop; do not substitute local documents or fallback.
"@
        if ((Read-Host "Copy the rendered prompt to your clipboard? Type YES, or press Enter to copy it manually") -ceq "YES") {
            Set-Clipboard -Value (Get-Content -LiteralPath $renderedPrompt -Raw)
            Write-Host "Prompt copied. Paste into Copilot Chat; source URLs remain local."
        }
        Pause-Demo "Switch to Copilot, submit the prompt, and WAIT until it has finished writing the PRD. Return here and press any key."
    }
    else {
        Write-Host "Resuming an already-generated result. Disclose that generation occurred earlier." -ForegroundColor Yellow
    }

    if (-not (Test-Path -LiteralPath $prd -PathType Leaf)) {
        throw "PRD not found. Finish generation in Copilot first, then rerun with -ResumeAfterGeneration."
    }
    $rehearsal = (Get-Content -LiteralPath $prd -Raw) -match 'SANITIZED REHEARSAL COPY'
    if ($rehearsal) {
        Write-Host "SANITIZED REHEARSAL COPY: public mirror links replaced original tenant citations; this is not live grounding." -ForegroundColor Yellow
    }

    Show-Section "3 - Reconcile the decision" "SAY: Use 80, preserve the original 70, and keep the reason and source trail."
    Show-PrdSection "Superseded decisions"
    Pause-Demo

    Show-Section "4 - Inspect the engineering contract" "SHOW: Observable acceptance criteria, human approval, and compliance boundaries."
    Show-PrdSection "Acceptance criteria"
    Show-PrdSection "Non-functional and compliance requirements"
    Pause-Demo

    Show-Section "5 - Inspect evidence and unresolved choices" @"
Follow citations against the retrieved sources (in the editor/browser if easier).
Verify 80 is current, 13-month retention, no raw messages in telemetry, manager
approval, 20-agent rollout, and operational disablement. A plausible link is
not proof. The scoring formula and feature-flag platform must remain open.
"@
    Show-PrdSection "Open questions"
    Show-PrdSection "Source traceability"
    Pause-Demo

    Show-Section "6 - Validate document structure" @"
SAY: This checks headings, Given/When/Then tokens, an ID, an HTTPS link,
selected placeholders, and the two threshold values. It cannot certify truth,
every citation, or compliance. Fix evidence-supported PRD issues, not the validator.
"@
    Invoke-Checked pwsh @("-NoProfile", "-File", (Join-Path $PSScriptRoot "validate-prd.ps1"), "-Path", $prd)
    Pause-Demo
    if ($NoPublish) {
        Write-Host "Review complete. No branch, staging, commit, push, or PR was performed."
        return
    }

    Show-Section "7 - Confirm the publication boundary" "Destination: $Repository ($($repoInfo.visibility)). Base: $base. New branch: $Branch."
    # Recheck after the Copilot edit, not just before generation.
    foreach ($line in @(Invoke-Checked git @("status", "--porcelain", "--untracked-files=all"))) {
        if ($line -cne "?? $prdRelative") { throw "Unexpected change after generation: $line" }
    }
    if ($repoInfo.visibility -ne "PRIVATE") {
        $content = Get-Content -LiteralPath $prd -Raw
        if ($content -match '(?i)sharepoint\.com|onedrive\.|1drv\.ms|pkgs\.visualstudio\.com|[?&](share|token|sig|access_token)=') {
            throw "Tenant links or environment-specific addresses detected in a non-private destination. Do not publish them. Use a private approved destination or a separately labeled sanitized rehearsal copy; preserve the original locally."
        }
    }
    Confirm-Demo "Have you checked the evidence AND approved every PRD field/link for this repository's audience?"
    Pause-Demo "Next: create a new branch and stage ONLY the PRD. Press any key to continue."
    Invoke-Checked git @("switch", "-c", $Branch)
    Invoke-Checked git @("add", "--", $prdRelative)
    $staged = @(Invoke-Checked git @("diff", "--cached", "--name-only"))
    if ($staged.Count -ne 1 -or $staged[0] -cne $prdRelative) { throw "Staged changes must contain only the PRD." }
    Invoke-Checked git @("--no-pager", "diff", "--cached", "--stat")
    Invoke-Checked git @("--no-pager", "diff", "--cached", "--", $prdRelative)

    Show-Section "8 - Commit and push the reviewed draft" "SAY: This is a specification change, not application code. Nothing will be merged."
    Confirm-Demo "Approve the displayed one-file diff and push to $Repository?"
    Pause-Demo
    Invoke-Checked git @("commit", "-m", "Add Intelligent Escalation product requirements",
        "-m", "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>")
    Invoke-Checked git @("push", "-u", "origin", $Branch)
    Pause-Demo "Commit and push finished. Press any key to prepare the draft PR."

    Show-Section "9 - Enter human review" @"
SHOW: demo\diagrams\03-human-review.png.
SAY: AI drafted; people verified evidence and retain approval. Open questions
remain visible. The PR will be draft, not merged, and the local validator is
not an automated GitHub check.
"@
    $body = Get-Content -LiteralPath (Join-Path $root "demo\draft-pr-body.md") -Raw
    if ($rehearsal) {
        $body = "> SANITIZED REHEARSAL COPY: generated earlier through WorkIQ. Tenant citations were replaced with public fictional-source mirrors. This run does not demonstrate live retrieval.`n`n" + $body
    }
    $bodyFile = Join-Path $local "draft-pr-body.md"
    $null = New-Item -ItemType Directory -Path $local -Force
    Set-Content -LiteralPath $bodyFile -Value $body -Encoding utf8
    Write-Host $body
    Confirm-Demo "Does this description accurately represent what you demonstrated, and may the draft PR be created?"
    Pause-Demo
    $existing = ((Invoke-Checked gh @("pr", "list", "--repo", $Repository, "--head", $Branch,
        "--state", "open", "--json", "url")) -join "`n") | ConvertFrom-Json
    if (@($existing).Count -gt 0) { throw "An open PR already exists for this branch. Inspect it instead of creating a duplicate." }
    Invoke-Checked gh @("pr", "create", "--repo", $Repository, "--base", $base, "--head", $Branch,
        "--draft", "--title", "Add Intelligent Escalation product requirements", "--body-file", $bodyFile)
    $createdPr = ((Invoke-Checked gh @("pr", "view", "--repo", $Repository, $Branch,
        "--json", "url,isDraft,files")) -join "`n") | ConvertFrom-Json
    if (-not $createdPr.isDraft -or @($createdPr.files).Count -ne 1 -or
        $createdPr.files[0].path -cne $prdRelative) {
        throw "The remote PR is not the expected one-file draft. Inspect it before proceeding."
    }
    Write-Host "Verified one-file draft PR: $($createdPr.url)"
    Pause-Demo "Draft PR created. Press any key to open it in your browser."
    Invoke-Checked gh @("pr", "view", "--repo", $Repository, $Branch, "--web")
    Pause-Demo "Close with: a traceable engineering contract, with people in control. Press any key to finish."
}
finally {
    Pop-Location
}
