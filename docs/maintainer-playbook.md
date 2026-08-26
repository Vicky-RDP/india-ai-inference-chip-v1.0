# Maintainer and moderator playbook

This project is public infrastructure. Moderation exists to protect focus,
technical quality, and contributor safety—not to gatekeep expertise.

## Daily triage

1. Acknowledge new issues within two working days.
2. Apply one workstream label and one state label (needs-triage, blocked,
   ready, or good first issue).
3. Ask for a reproduction or design contract when it is missing.
4. Convert recurring questions into documentation or Discussions.
5. Close duplicates with a link to the canonical issue; do not erase context.

## Pull request policy

- Require one approval for every pull request while the project has one active
  maintainer. Once a second qualified maintainer exists, require two approvals
  for RTL, numeric behavior, public interfaces, security, licensing, or
  tapeout-critical changes.
- Require the affected CODEOWNERS group to review its workstream.
- Never merge with failing required checks or unexplained waivers.
- Prefer small PRs. Split refactors from behavior changes.
- Ask for evidence in the PR, not just confidence in the author.

## Handling community conflict

Use the Code of Conduct process for people problems. Keep technical disagreement
public and specific; move personal conflict to private maintainer channels.
Maintainers should record significant moderation decisions without publishing
private details. Retaliation, harassment, discriminatory content, credential
exposure, and unsafe fabrication claims are escalation events.

## Release and tapeout authority

The release steward may cut a release only when CI, review, and the relevant
gate checklist are green. The tapeout decision requires at least two maintainers
and an independent reviewer to sign the public signoff checklist. No single
maintainer can waive a failed safety, licensing, or reproducibility gate.

## GitHub settings checklist

Repository administrators should enable:

- Discussions with categories: Announcements, Q&A, RFC, Show and Tell, and
  Contributors;
- protected main with pull requests, required CI, CODEOWNERS review, and no
  force pushes;
- secret scanning and Dependabot alerts/updates;
- the labels listed in .github/labels.yml;
- squash merge with branch deletion after merge; and
- a public project board grouped by the roadmap gates.

The repository contains policy-as-code for the parts GitHub can enforce from
source. Account-level invitations, branch protection, Discussions categories,
and team membership still require an administrator with GitHub permissions.
