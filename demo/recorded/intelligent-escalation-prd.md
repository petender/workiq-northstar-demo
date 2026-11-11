# Intelligent Escalation Pilot - Product Requirements

> **SANITIZED REHEARSAL COPY:** This document was generated earlier through
> WorkIQ from three fictional OneDrive-hosted documents. Original tenant URLs
> have been removed and replaced with public mirrors of the fictional source
> content. These replacement links are not the original retrieval evidence.
> Use this copy for a disclosed terminal rehearsal, not as proof of fresh
> grounding. The unmodified original is retained locally outside Git.

## Document control

| Field | Value |
|---|---|
| Status | Draft for human review; not implementation approval |
| Project | Project Northstar Escalation |
| Business owner | Maya Chen, VP of Customer Support (fictional scenario) |
| Engineering owner | Open |
| Original generation | November 10, 2026, through WorkIQ retrieval; this is a sanitized recorded copy, not a fresh run |
| Source staging | Three Markdown documents in OneDrive for Business simulating a business brief, Teams transcript, and compliance email; not live Teams or Outlook items |

Source dates below are story dates, not upload or retrieval timestamps.
[Brief][brief], [Decision transcript][teams], [Compliance document][compliance].

## Problem statement

North America enterprise support cases are escalated inconsistently across
shifts. Agents can miss deteriorating sentiment and repeated contacts, while
managers lack consistent explanations and engineering receives avoidable
escalations with insufficient context. The pilot must recommend action inside
the existing support case experience while retaining human control.
[Brief][brief]

## Business outcomes and success measures

| ID | Measure | Target | Source |
|---|---|---|---|
| BO-001 | Median time from qualifying risk to engineering escalation | Reduce by 30% against the current baseline; baseline value and evaluation window are open. | [Brief][brief] |
| BO-002 | False escalations | Increase by no more than 10% compared with the current baseline; definition and measurement method are open. | [Brief][brief] |
| BO-003 | Recommendation latency | Within two minutes of a qualifying case update. | [Brief][brief] |

Managers must receive contributing signals sufficient to understand a
recommendation; the source supplies no numeric usability target. FR-003 defines
the required visible information. [Brief][brief], [Decision transcript][teams]

## Personas

| Persona | Need | Source |
|---|---|---|
| Support agent | See a recommendation in the existing case experience for an eligible case. | [Brief][brief] |
| Support manager | Review contributing signals and make the final decision. | [Brief][brief], [Decision transcript][teams] |
| Support Operations | Control the cohort and stop new recommendations without deployment. | [Decision transcript][teams], [Compliance document][compliance] |
| Compliance reviewer | Verify decision records and the pilot's privacy and retention boundaries. | [Compliance document][compliance] |

## User journey

1. A pilot agent opens or updates an eligible case in the existing support
   experience. [Brief][brief]
2. The service evaluates severity, customer tier, sentiment category, and
   repeat-contact count. The exact scoring formula remains open.
   [Brief][brief], [Decision transcript][teams]
3. If the risk score is 80 or higher, show a recommendation and its contributing
   signals within two minutes of the qualifying update.
   [Brief][brief], [Decision transcript][teams]
4. A support manager reviews and approves, dismisses, or overrides the
   recommendation. A recommendation alone never submits an escalation.
   [Decision transcript][teams]
5. Require a dismissal/override reason and retain the specified decision record
   for 13 months. [Compliance document][compliance]

## Scope

### In scope

- North America enterprise accounts and English-language cases in the existing
  support case experience. [Brief][brief]
- An initial feature-flagged cohort of 20 support agents plus their managers.
  [Decision transcript][teams]
- Explainable recommendations with manager approval, auditable decisions, and
  operational disablement. [Decision transcript][teams], [Compliance document][compliance]

### Out of scope

- Autonomous engineer paging, automatic customer communication, or automatic
  case-severity changes. [Brief][brief]
- Global rollout or replacing the existing case-management platform.
  [Brief][brief]
- Production rollout or broader data collection authorized by this pilot.
  [Compliance document][compliance]

## Functional requirements

| ID | Requirement | Priority | Source |
|---|---|---|---|
| FR-001 | Limit pilot recommendations to English-language cases for North America enterprise accounts and the initial 20-agent cohort plus managers, within the existing case experience. | Must | [Brief][brief], [Decision transcript][teams] |
| FR-002 | Evaluate the approved risk signals on qualifying case updates and show an escalation recommendation when the calculated score is 80 or higher; do not generate a threshold-based recommendation below 80. The qualifying update set and scoring formula remain open. | Must | [Brief][brief], [Decision transcript][teams] |
| FR-003 | Show contributing severity, customer tier, sentiment category, and repeat-contact count; do not display internal weights or raw customer message text. | Must | [Decision transcript][teams] |
| FR-004 | Require a support manager's approval before an escalation can be submitted from a recommendation, including regulated-customer cases; the recommendation alone must not trigger escalation. | Must | [Decision transcript][teams] |
| FR-005 | Require the manager to select or enter a reason when dismissing or overriding a recommendation. | Must | [Compliance document][compliance] |
| FR-006 | Place the pilot behind a feature flag and let Operations disable new recommendations through an emergency kill switch without deployment. | Must | [Decision transcript][teams], [Compliance document][compliance] |
| FR-007 | Record the recommendation, contributing signal categories, final decision, applicable override reason, timestamp, and approving manager identity. | Must | [Compliance document][compliance] |
| FR-008 | Do not autonomously page engineers, contact customers, or change case severity. | Must | [Brief][brief] |

## Non-functional and compliance requirements

| ID | Requirement | Source |
|---|---|---|
| NFR-001 | Produce a recommendation within two minutes of a qualifying case update. | [Brief][brief] |
| NFR-002 | Exclude raw customer message text, attachments, and message excerpts from both model and application telemetry. | [Compliance document][compliance] |
| NFR-003 | Retain every FR-007 decision record for 13 months. The precise retention-start event and post-retention disposition require clarification. | [Compliance document][compliance] |
| NFR-004 | Encrypt audit records in transit and at rest using approved enterprise controls. The named standard and verification procedure remain open. | [Compliance document][compliance] |
| NFR-005 | Ensure pilot reporting does not expose customer message content or directly identify individual customers; aggregated metrics are permitted within this boundary. | [Compliance document][compliance] |

## Acceptance criteria

### AC-001 - Threshold boundary and latency (FR-002, NFR-001)

- **Given** an eligible pilot case with a test-supplied calculated score of 80
- **When** a qualifying update is processed while the pilot is enabled
- **Then** the recommendation is visible within two minutes of that update

The test-supplied score does not define or approve a scoring formula.
[Brief][brief], [Decision transcript][teams]

### AC-002 - Below-threshold boundary (FR-002)

- **Given** an eligible pilot case with a test-supplied score below 80 and no existing recommendation
- **When** a qualifying update is processed while the pilot is enabled
- **Then** no threshold-based recommendation is generated

[Decision transcript][teams]

### AC-003 - Eligibility and cohort (FR-001)

- **Given** a case outside the North America enterprise or English-language scope, or a user outside the approved pilot cohort
- **When** the case is opened or updated
- **Then** no new pilot recommendation is shown to that user for that case

[Brief][brief], [Decision transcript][teams]

### AC-004 - Explainability without disclosure (FR-003)

- **Given** a pilot recommendation is visible
- **When** a manager reviews its explanation
- **Then** it shows the contributing severity, customer tier, sentiment category, and repeat-contact count, but not internal weights or raw customer message text

[Decision transcript][teams]

### AC-005 - Human approval and non-autonomy (FR-004, FR-008)

- **Given** a recommendation without support-manager approval, including for a regulated-customer case
- **When** the recommendation is generated or reviewed
- **Then** it does not submit an escalation, autonomously page engineers, contact customers, or change case severity

[Brief][brief], [Decision transcript][teams]

### AC-006 - Reason capture and audit retention (FR-005, FR-007, NFR-003)

- **Given** a manager attempts to dismiss or override a recommendation
- **When** no reason has been selected or entered
- **Then** the dismissal or override cannot be completed without a reason
- **And** after a reason is supplied and the decision completes, its audit record contains all FR-007 fields applicable to that decision and is governed by 13-month retention

Verify retention configuration and time-based tests after OQ-007 is resolved.
[Compliance document][compliance]

### AC-007 - Operational disablement (FR-006)

- **Given** the feature-flagged pilot is active
- **When** Operations activates the emergency kill switch
- **Then** new recommendations are disabled without an application deployment

Propagation timing and handling of existing recommendations are not specified.
[Decision transcript][teams], [Compliance document][compliance]

### AC-008 - Telemetry and reporting boundaries (NFR-002, NFR-005)

- **Given** a test case containing recognizable synthetic customer text, an attachment, and a customer identifier
- **When** a recommendation and manager decision generate telemetry and pilot reports
- **Then** model and application telemetry contain no raw message text, attachments, or excerpts, and reports contain neither message content nor information directly identifying an individual customer

[Compliance document][compliance]

### AC-009 - Audit encryption (NFR-004)

- **Given** the enterprise-approved encryption controls have been identified
- **When** audit storage and transport are inspected against those controls
- **Then** both at-rest and in-transit protection satisfy the approved controls

This criterion cannot be signed off until OQ-004 is answered.
[Compliance document][compliance]

## Telemetry and measurement

- Measure BO-001 through BO-003 using the agreed baseline and pilot evaluation
  window; do not invent baseline values. [Brief][brief]
- Apply NFR-002 to model and application telemetry, and NFR-005 to reporting.
  Permission to collect audit fields does not authorize broader telemetry
  collection. [Compliance document][compliance]
- Keep the required approving-manager identity in the audit record; do not
  confuse this with permission to identify customers in pilot reports.
  [Compliance document][compliance]
- Event schema, measurement ownership, false-escalation definition, and the
  baseline method remain open. [Brief][brief]

## Dependencies and risks

The following are review implications, not additional approved requirements.

| Item | Type | Mitigation or owner |
|---|---|---|
| Risk score formula is unspecified. | Dependency | Engineering and Product to resolve OQ-001; reviewer assignment proposed, not source-assigned. [Decision transcript][teams] |
| Feature-flag platform and kill-switch semantics are unspecified. | Dependency | Engineering and Operations to resolve OQ-002 and OQ-006; proposed reviewer assignment. [Decision transcript][teams], [Compliance document][compliance] |
| Business baselines are not supplied. | Measurement risk | Operations and Product to define baseline and evaluation method before claiming success; proposed reviewer assignment. [Brief][brief] |
| Approved encryption standard and retention mechanics are unnamed. | Compliance dependency | Compliance and Engineering to resolve OQ-004 and OQ-007; proposed reviewer assignment. [Compliance document][compliance] |
| The earlier brief remains at 70. | Implementation risk | Review FR-002 against the explicit later decision, not the brief alone. [Brief][brief], [Decision transcript][teams] |

## Open questions

- OQ-001: What exact formula and weights produce the risk score? Explicitly
  unresolved in the [decision transcript][teams].
- OQ-002: Which approved feature-flag platform controls the pilot? Explicitly
  unresolved in the [decision transcript][teams].
- OQ-003: What are the current time-to-escalation and false-escalation
  baselines, how is a false escalation defined, and what evaluation window and
  measurement owners apply? Not supplied by the [brief][brief].
- OQ-004: Which approved enterprise controls and verification procedure apply
  to audit encryption? Not named in the [compliance document][compliance].
- OQ-005: Which case updates qualify for reevaluation, and what happens to an
  existing recommendation when a score falls below 80? Not defined by the
  [brief][brief] or [decision transcript][teams].
- OQ-006: What kill-switch propagation target applies, and how are existing or
  in-flight recommendations handled? Not defined by the
  [decision transcript][teams] or [compliance document][compliance].
- OQ-007: When does the 13-month retention clock start, how is compliance
  tested, and what happens at expiry? How are manager identity and reasons
  represented for dismissal/override records? Not specified by the
  [compliance document][compliance].
- OQ-008: Do any regulated-customer workflows require approvals beyond the
  universal manager approval? The [brief][brief] asks about additional approval;
  the [decision transcript][teams] confirms manager approval but names no
  additional workflow.
- OQ-009: Which permitted telemetry fields and event schema support the success
  measures without exceeding compliance boundaries? The [brief][brief] defines
  measures and the [compliance document][compliance] defines exclusions, not a schema.

## Superseded decisions

| Topic | Earlier value | Current value | Evidence |
|---|---|---|---|
| Pilot recommendation threshold | 70 or higher in the September 8, 2026 draft | 80 or higher for the pilot | The September 15, 2026 transcript explicitly states 80 supersedes 70, then records business-owner approval. [Brief][brief], [Decision transcript][teams] |

The earlier value is historical only. The compliance document's September 18
story date adds controls; it does not change the approved threshold.
[Decision transcript][teams], [Compliance document][compliance]

## Source traceability

The original generation used OneDrive-hosted Markdown files retrieved through
WorkIQ, not separate Teams or Outlook items. In this public rehearsal copy,
all source links below point to fictional-content mirrors in GitHub rather
than the original tenant URLs. They allow content review but do not establish
which Microsoft 365 items were retrieved or whether a fresh call succeeded.

| Requirement IDs | Source | Evidence summary | Source URL |
|---|---|---|---|
| BO-001, BO-002, BO-003, FR-001, FR-002, FR-008, NFR-001 | Business brief; story date September 8, 2026 | Scope, existing experience, signals, initial threshold, outcome targets, two-minute latency, and non-goals. Threshold is superseded as recorded above. | [Business brief][brief] |
| FR-001, FR-002, FR-003, FR-004, FR-006 | Simulated Teams transcript; story date September 15, 2026 | Explicit threshold 80 replacing 70, manager approval, permitted explanation, 20-agent cohort, feature flag, operational disablement, and open formula/platform decisions. | [Decision transcript][teams] |
| FR-005, FR-006, FR-007, NFR-002, NFR-003, NFR-004, NFR-005 | Simulated compliance email; story date September 18, 2026 | Telemetry exclusions, audit fields, 13-month retention, encryption, dismissal/override reason, emergency kill switch, reporting limits, and pilot-only authorization. | [Compliance document][compliance] |

[brief]: https://github.com/petender/workiq-northstar-demo/blob/main/business-artifacts/sharepoint-business-brief.md
[teams]: https://github.com/petender/workiq-northstar-demo/blob/main/business-artifacts/teams-decision-thread.md
[compliance]: https://github.com/petender/workiq-northstar-demo/blob/main/business-artifacts/compliance-email.md
