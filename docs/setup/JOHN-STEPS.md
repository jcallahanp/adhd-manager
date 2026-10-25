# One-time GitHub settings for John

About 10 minutes. Defaults are filled in; do them in order. Tick each in the PR when done.

1. Settings > General > Pull Requests: allow squash merging only; tick "Automatically delete head branches".
2. Settings > Code security: turn on Dependency graph, Dependabot alerts, Dependabot security updates, Secret scanning, Push protection, Private vulnerability reporting.
3. Code scanning (CodeQL, the Security tab, dependency review) is free only on public repos; a private repo needs GitHub Code Security. If you have it (or make the repo public): Settings > Code security > CodeQL analysis > Set up > Default, then add the repository variable `CODE_SCANNING` = `true`. Without it, the scans still run and fail the PR on high or critical findings; results show in the job log.
4. Settings > Rules > Rulesets > New branch ruleset "main": target the default branch; require a pull request (0 approvals while you are the only person; raise to 1 when someone joins), require conversation resolution, block force pushes and deletions, require status checks: `Ledger updated with code changes`, `Lint, test, build`, `Secret scan`, `Trivy filesystem and config`, `Workflow audit (zizmor)` (plus `CodeQL` if step 3 is on).
5. Settings > Actions > General: Workflow permissions "Read repository contents"; untick "Allow GitHub Actions to create and approve pull requests". Under "Allowed actions", optionally require actions to be pinned to a full-length commit SHA.
6. Settings > Secrets and variables > Actions: add secret `ANTHROPIC_API_KEY` for the PR security review only (a separate key with a monthly spend limit set in the Anthropic Console; app users bring their own). Optional variable `CLAUDE_REVIEW_MODEL`.
7. On your machine, once: `pipx install pre-commit && pre-commit install` in the repo, and `/plugin install superpowers@superpowers-dev --scope project` in Claude Code if it says the plugin is not installed.
