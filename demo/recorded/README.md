# Recorded scenario result

[intelligent-escalation-prd.md](intelligent-escalation-prd.md) is a sanitized
copy of the earlier WorkIQ-generated PRD. Its tenant citations were replaced
with public fictional-source mirrors. It is not a new retrieval result.

The reusable source kit is
[petender/workiq-ghcopilot-demo](https://github.com/petender/workiq-ghcopilot-demo);
this repository is the working scenario. Both default branches intentionally
exclude the active generated PRD path.

For a terminal-only rehearsal in a fresh clone, first ensure the destination
file does not already exist:

```powershell
Copy-Item .\demo\recorded\intelligent-escalation-prd.md `
  .\docs\specs\intelligent-escalation-prd.md
.\scripts\present-demo.ps1 -ResumeAfterGeneration -NoPublish
```

For confirmed publication, omit `-NoPublish` and explicitly select this working
repository:

```powershell
.\scripts\present-demo.ps1 -ResumeAfterGeneration `
  -Repository petender/workiq-northstar-demo
```

The walkthrough uses keypress pauses, explicit publication confirmations, a
new branch, a PRD-only diff, and a draft PR. It preserves the rehearsal
disclosure in the PR body. Nothing is merged automatically.

For a genuinely fresh demo, use another clean clone, populate ignored `.env`,
and run the full walkthrough without `-ResumeAfterGeneration`. Keep live
tenant citations in an approved private destination, not this public repo.
