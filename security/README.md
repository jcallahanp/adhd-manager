# Security

Two layers: continuous checks on every change, and a gate at every milestone. Nothing ships with an open high or critical finding.

## Continuous (automatic)

| When | Tool | Catches | Where results go |
| --- | --- | --- | --- |
| Every commit, locally | pre-commit: gitleaks, detect-private-key, actionlint, zizmor, shellcheck | Secrets, broken or unsafe workflows | Blocks the commit |
| Every PR and push to main | gitleaks; dependency review; Trivy fs (vuln, misconfig, secret); zizmor | Secrets, risky new dependencies and licences, CVEs, Dockerfile and compose mistakes, workflow injection | PR checks, Security tab |
| Every PR | CodeQL default setup (GitHub settings) | Injection, auth and data-flow bugs in the app code | Security tab |
| Every PR with code | Claude security review (`claude-security-review.yml`) | Logic bugs scanners miss: missing user scoping, prompt injection paths, unsafe automations | PR comment |
| Continuous | GitHub secret scanning with push protection; Dependabot alerts and security updates | Leaked tokens, vulnerable dependencies | Blocks the push; Dependabot PRs |
| Weekly | Trivy rescan; OpenSSF Scorecard | New CVEs in unchanged code; supply-chain posture | Security tab |

All third-party actions are pinned to commit SHAs (D-001). Dependabot bumps them weekly.

The Security tab, CodeQL and dependency review need a public repo or GitHub Code Security (repo variable `CODE_SCANNING=true`, D-003). Without it Trivy and zizmor print to the job log and fail on high or critical findings.

## Milestone gate (`security-gate.yml`, run by the `security-tester` agent)
1. Run the workflow with the staging URL; download every artifact.
2. Semgrep SAST, Trivy image scan of every Dockerfile, ZAP full and API scans, testssl.sh.
3. Manual checks against OWASP ASVS 5.0 Level 2 for the chapters the milestone touched, the OWASP Top 10 for LLM Applications for the triage parser, and OWASP MASVS for the mobile app. Two test users to prove data isolation.
4. Report from `security/REPORT_TEMPLATE.md` into `docs/security/<date>-<milestone>/REPORT.md`. Findings become issues; the report records the retest. John signs the last line.

## Runtime monitoring (added with the first deployment)
- Error tracking with user content and API keys scrubbed, uptime checks, and a per-user alert when their own key nears its monthly cap. Tool choices recorded as D-nnn with the first deployment.
