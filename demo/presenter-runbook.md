# Five-minute presenter runbook

## Recommended: terminal-first, one section at a time

Clone and configure your **working demo repository**, not the reusable source
kit, using the [two-repository starter instructions](../README.md#two-repositories-two-responsibilities).
All terminal steps below are consolidated in
[scripts/present-demo.ps1](../scripts/present-demo.ps1), including narration and
keypress pauses. **Recommended: launch a dedicated PowerShell 7 window** so
Copilot stays in VS Code and the presenter output has its own screen. From the
working demo checkout, run this in any terminal, including Windows PowerShell:

```powershell
# Full session: whiteboards -> Copilot -> wait -> review -> validate -> draft PR.
.\scripts\start-presenter.cmd -Repository OWNER/workiq-northstar-demo
```

The [Windows launcher](../scripts/start-presenter.cmd) explicitly selects
`pwsh.exe`, skips profiles, and keeps the new window open when the script ends
or fails. It does not change or bypass execution policy. `code .` opens VS Code
but does not guarantee its terminal is PowerShell 7. **Do not run the `.ps1`
directly in Windows PowerShell 5.1.** If `pwsh.exe` is unavailable, install the
approved PowerShell 7 release before rehearsing.

Replace OWNER with the intended GitHub owner. A fresh timestamped specification
branch is chosen automatically; use `-Branch spec/my-session` if desired.
The destination must match `origin`, and the default branch must be clean
except for a new PRD when explicitly resuming.

| Script section | Presenter action before pressing a key |
|---|---|
| 1. Whiteboard story | Show [business-to-engineering](diagrams/01-business-to-engineering.png) and [decision change](diagrams/02-decision-change.png). Explain the OneDrive simulations and the explicit 70-to-80 change. |
| 2. Copilot handoff | Optionally copy the rendered prompt, switch to Copilot, submit it, show WorkIQ retrieval, and wait until the PRD is written. Return to the paused terminal only after generation completes. |
| 3. Decision | Explain the displayed superseded-decision table. |
| 4. Engineering contract | Walk through acceptance criteria and compliance controls. |
| 5. Evidence and unknowns | Inspect the displayed questions and traceability; follow citations in the editor/browser against retrieved evidence. |
| 6. Structure | Run the validator, explain its limits, and inspect its output. |
| 7. Publication boundary | Check destination/visibility, approve disclosure, create the branch, and inspect the staged PRD-only diff. |
| 8. Commit/push | Type `YES` to approve the reviewed diff; press a key to commit and push. |
| 9. Human review | Show [human review](diagrams/03-human-review.png), read the proposed description, explicitly approve draft PR creation, then open the result in a browser. |

The pauses have no timeout. The script does not invoke Copilot itself, poll for
an arbitrary file timestamp, auto-accept legal terms, or infer retrieval from
the existence of a file. You decide when generation and evidence review are
complete. Press `Ctrl+C` to stop; no destructive cleanup is performed.

### Continue from the result already generated

```powershell
# Review only: no branch, stage, commit, push, or PR.
.\scripts\start-presenter.cmd -ResumeAfterGeneration -NoPublish

# Review, then explicitly confirm publication in the correct working repo.
.\scripts\start-presenter.cmd -ResumeAfterGeneration -Repository OWNER/workiq-northstar-demo
```

If you prefer an existing **PowerShell 7** window, run the same options through
`.\scripts\present-demo.ps1` directly. From a different shell, explicitly use
`pwsh -NoProfile -File .\scripts\present-demo.ps1` followed by those options.
If scripts remain blocked in PowerShell 7, inspect `Get-ExecutionPolicy -List`
and use your organization's approved policy; do not disable controls to demo.

Disclose that generation occurred earlier. A sanitized recorded result is
labeled **SANITIZED REHEARSAL COPY**; its replacement public-source links are
not the original WorkIQ citations. The script carries that disclosure into
the proposed PR body. Do not describe a recorded copy as fresh grounding.

For a fresh run, clone the working default branch into an unused folder and
configure a new ignored `.env`. Do not overwrite or reset prior work. If the
script fails after branch creation, stop and inspect your local branch/remote
state; resume manually using the commands later in this runbook rather than
rerunning mutations blindly. Public repositories reject detected tenant links;
use an approved private destination for an unsanitized live PRD.

### Where to configure the prompt

Set the three individual source URLs in ignored `.env`, based on
[.env.example](../.env.example). The walkthrough renders them into
`.local/workiq-prompt.txt`; this file is the text to paste, **not** the
[variable-based template](workiq-prompt.md). No tenant or proxy/feed address
belongs in the committed template. `-PrepareOnly` renders the prompt without
starting the interactive walkthrough or modifying Git.

The manual timing guide below remains useful for narration and recovery.
Keypresses and review may make a walkthrough longer than five minutes.

## Before going live

Complete the [README preparation guide](../README.md#prepare-the-demo) first.
This runbook assumes the sources are published, all three have passed a
read-only WorkIQ retrieval test, and the GitHub destination is ready. Setup and
authentication are not part of the five-minute presentation.

### Presenter orientation

- **Maya (business owner):** wants faster, more consistent qualified escalation.
- **Luis (Support Operations):** changes the threshold and defines rollout.
- **Priya (Compliance):** adds approval, audit, retention, and data boundaries.
- **Evan (Engineering):** asks for an explanation a manager can understand.
- **You (presenter):** act as the developer turning these decisions into a
  reviewable engineering contract. You are not implementing the application.

### Ready-to-start checklist

- [ ] The actual staged sources are open in three tabs (OneDrive simulation
  documents or actual SharePoint, Teams, and Outlook items)
  under the same Microsoft 365 account WorkIQ uses.
- [ ] The brief still says 70; Teams explicitly supersedes it with 80; the email
  includes 13-month retention.
- [ ] All three `.env` URLs are set and the local prompt renders successfully.
- [ ] A fresh Copilot Chat is in agent mode with WorkIQ tools enabled.
- [ ] The workspace is on the clean default branch, with no generated PRD.
- [ ] `spec/intelligent-escalation` is unused locally and remotely; otherwise
  choose a fresh name and substitute it in the commands below.
- [ ] Git push and `gh` authentication were tested during rehearsal.
- [ ] The terminal is at the workspace root, with the validator command ready.
- [ ] The [fallback](fallback/intelligent-escalation-prd.expected.md) is available
  but closed, and editor/browser/terminal text is readable from the back row.

The timings are a target, not a guarantee of tool latency. Rehearse them in
your tenant. At 1:50, if retrieval is still blocked, take the recovery path
instead of consuming the remaining slot on troubleshooting.

## 0:00-0:40 - Business context

**Do:** Start with the whiteboard story, then switch through the three actual
Microsoft 365 browser tabs, not their local Markdown counterparts. Disclose
OneDrive staging if used. In the brief show the title, project marker,
pilot scope, and "70 or higher." In Teams show the matching marker and the
explicit "80 ... supersedes the 70" decision. In Outlook show the subject and
13-month retention/data-minimization controls.

**Say:**

> Maya is our fictional business leader, not a developer. She works in the
> tools she already knows. In this scenario, no single artifact tells the
> complete story. The SharePoint brief defines the outcome, Teams contains a
> later decision, and email adds compliance boundaries.

**Ask the audience to notice:** "If a developer implements only the brief,
which threshold will they use?" Do not manually reconcile it for the agent.
Explain that all content is fictional and already staged for this demo.

## 0:40-1:50 - Ground the developer agent

**Do:**

1. Switch to VS Code and open the generated `.local/workiq-prompt.txt`.
2. Copy the rendered plain text (or use the walkthrough's clipboard offer),
   not the variable-based template, preparation notes, or expected checklist.
3. Show that the prompt supplies three source links, requires evidence and
   conflict resolution, and explicitly requests one new PRD file.
4. Send it in the fresh agent conversation. Review and approve expected WorkIQ
   read requests and the requested workspace edit when prompted.
5. Expand one WorkIQ tool call/result so the audience can see retrieval of a
   staged item. Do not expose unrelated tenant content or sign-in details.

**Say while WorkIQ runs:**

> We have already configured WorkIQ and granted this demo account access.
> The developer supplies links rather than copying all three source bodies.
> GitHub Copilot invokes WorkIQ to retrieve the authorized business context.
> The prompt requires citations, conflict resolution, and open questions rather
> than invented details.

**Expected:** visible WorkIQ activity for the sources and a new file at
`docs/specs/intelligent-escalation-prd.md`. A summary in chat alone is not the
file deliverable. If the agent only replies in chat, ask it to save its
evidence-grounded result at that path using the template.

If retrieval is progressing but takes longer than expected, briefly show the
[template](../docs/specs/prd-template.md): requirement IDs, acceptance criteria,
superseded decisions, and traceability. If any source is missing, the prompt
should stop before writing; do not authorize invented replacements.

## 1:50-3:20 - Inspect the generated PRD

**Do:** Open the generated PRD in the editor or Markdown preview. Use Find
(`Ctrl+f`) to jump to `Superseded decisions`. Point to earlier value 70, current
value 80, and both source citations. Follow the Teams citation to show the
explicit replacement decision, then return to VS Code.

**Say:**

> This is more than summarization. The agent recognized that the later Teams
> decision supersedes the original threshold, selected 80, and preserved 70 in
> the decision trail.

Then use Find to move through this checklist. IDs and prose can differ; verify
the meaning rather than expecting an exact copy of the fallback.

| Find/show | What to point out and verify |
|---|---|
| `80` in functional requirements | Recommendation threshold is 80 or higher, not 70. Earlier 70 appears only as historical context. |
| `Acceptance criteria` | A boundary case at 80 produces a recommendation within two minutes; a case below 80 does not. Given/When/Then describes observable behavior. |
| Manager approval | Recommendations do not autonomously escalate or page engineers; regulated cases cannot bypass manager approval. |
| `13 months` | Audit retention includes the decision, signal categories, timestamp, approving manager, and applicable reason, with an email citation. |
| `Telemetry` | No raw customer messages, attachments, or excerpts; reporting must not expose message content or directly identify customers. |
| `20` and feature flag | The pilot is limited to 20 agents plus managers, with operational disablement without deployment. |
| `Open questions` | The scoring formula and feature-flag platform are not invented. Any undefined baseline or encryption standard remains explicitly unresolved. |
| `Source traceability` | Material requirements map to the real staged URLs, not local files, placeholder URLs, or unrelated search results. |

**Say:** "A threshold is a business decision; a scoring formula is still an
engineering question. The PRD preserves that distinction instead of silently
choosing a design."

Inspect retrieved evidence as well as citations. A plausible link or a fluent
answer does not, by itself, prove the linked source supports the requirement.

## 3:20-4:10 - Validate the handoff

**Do:** Switch to the prepared workspace terminal and run:

```powershell
.\scripts\validate-prd.ps1 `
  -Path .\docs\specs\intelligent-escalation-prd.md
```

**Say:**

> This is a lightweight structural check, not a truth checker. It looks for
> required sections, Given/When/Then tokens, a requirement ID, an HTTPS link,
> selected template tokens, and both threshold values. We still have to verify
> that 80 is the current decision and every material requirement is supported.

**Expected:** `PRD validation passed:` and exit code 0. Do not claim that a pass
verifies all citations, retention controls, every placeholder, or testability.

If validation fails, show the specific error. Ask Copilot:

> Fix only the reported structural errors in the generated PRD, preserving
> the retrieved evidence and the template contract. Do not change the
> validator or invent missing requirements.

Rerun once. If evidence is missing or the result still fails, disclose that
the draft needs further work rather than publishing it as validated.

## 4:10-5:00 - Enter the DevOps workflow

**Do:** Review the proposed change before publishing:

```powershell
git status --short
```

Expected: only the new PRD is untracked. If other changes appear, inspect them
and do not stage them accidentally. Create the branch and stage only the PRD:

```powershell
git switch -c spec/intelligent-escalation
git add -- docs/specs/intelligent-escalation-prd.md
git diff --cached --stat
git diff --cached -- docs/specs/intelligent-escalation-prd.md
```

Use VS Code's Source Control diff if that is easier to show on screen. Confirm
only the intended PRD is staged. Then commit and publish:

```powershell
git commit -m "Add Intelligent Escalation product requirements" `
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push -u origin spec/intelligent-escalation
```

Create the draft PR explicitly (the live generation prompt does not do this):

```powershell
gh pr create --draft `
  --title "Add Intelligent Escalation product requirements" `
  --body-file .\demo\draft-pr-body.md
gh pr view --web
```

These commands assume `origin` and the default base branch were checked during
preparation. For a fork or a different target, supply the verified repository
and base explicitly. Do not merge the PR as part of this demo.

**Show in GitHub:** the **Draft** badge, **Files changed** with one PRD, its
rendered decision/traceability tables, and the review requests in the
description. The description's checkboxes are deliberately unchecked; only
mark checks you actually completed. They are not automated CI results.

**Expected:** a real draft PR URL, with no application implementation changes.
The local validator is not a GitHub required check unless you separately
configured CI; this kit does not configure it.

**Close with:**

> WorkIQ brought business knowledge to the developer's agent. GitHub Copilot
> converted it into a traceable engineering contract. The draft PR now puts
> that contract into the team's normal review and governance workflow. The
> agent accelerated the handoff without pretending unresolved decisions were
> settled.

## Recovery cues

### WorkIQ retrieval is slow

Briefly explain the template's grounding contract. At the retrieval cutoff,
say: "Live retrieval has not completed, so I am switching to a prepared,
fictional example of the expected output." Cancel the outstanding generation
request before switching to avoid late edits being mistaken for fallback work.
Open the [labeled fallback](fallback/intelligent-escalation-prd.expected.md)
without renaming or removing its banner.

Its `example.invalid` links are intentionally nonfunctional. They are not
source evidence. You may demonstrate the validator against the fallback with:

```powershell
.\scripts\validate-prd.ps1 `
  -Path .\demo\fallback\intelligent-escalation-prd.expected.md
```

Say that this demonstrates structure only, not live grounding. Do not commit
the fallback as a newly grounded PRD or reuse the live PR description's
generation claim. If showing a rehearsal PR, label it as pre-created.

### One source is not found

The live prompt requires a missing-source report and no new PRD. State which
source is unavailable. Never fill the gap from the local source files and
claim WorkIQ found it. Use the fallback only to explain the intended full flow;
do not describe its compliance requirements as verified in this run.

### Sign-in, consent, or tools fail

Do not debug tenant consent on stage. Explain that setup is incomplete and use
the disclosed fallback. Afterward check the server output, enabled tools,
Microsoft 365 account, admin consent, applicable billing configuration, and
source permissions using the README's read-only preflight.

### Wrong threshold, invented design, or invalid citation

Show the relevant retrieved evidence and ask for a correction limited to the
PRD. Do not edit the source or relax the validator to force a pass. If the
evidence cannot be established within the slot, stop the live publishing path
and state that human review caught an incomplete handoff.

### GitHub is unavailable

Show the [prepared PR description](draft-pr-body.md) and local staged/committed
diff. State exactly where the flow stopped: local commit, push, or PR creation.
Do not claim a draft PR exists without a successful creation and a real URL.
If publication status is uncertain, check `gh pr view` before retrying creation.

### A rehearsal branch or generated file already exists

Do not reset or delete work on stage. Use a fresh branch name if that is the
only conflict. If the starting checkout already contains the output, disclose
that it is a rehearsal result and use a prepared clean clone for a fresh run.

### Time is running short

Skip detailed acceptance-criteria narration. Show the superseded decision,
traceability matrix, validator result, and draft PR if created. If you cannot
reach publication, show the reviewed local diff and say publication remains
to be done.

## After the session

- Share the actual draft PR link only with the intended reviewers. Repository
  access does not automatically grant access to the Microsoft 365 citations.
- Keep the PR in draft until Product, Operations, Compliance, and Engineering
  resolve the requested reviews and open questions.
- Close rehearsal PRs and choose a fresh demo branch/clone for future sessions;
  do not overwrite someone else's changes or force-push a shared branch.
- Remove staged demo content only under the demo tenant's retention and cleanup
  policy. No real customer information should have been introduced.
