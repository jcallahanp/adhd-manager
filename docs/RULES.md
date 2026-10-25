# Working rules

These rules were set by John on 2026-10-24 for the health platform and adopted here on 2026-10-25. They bind every agent and every session on this project.

## 1. One narrow task per session
- A session takes one task from `docs/STATUS.md` (or the GitHub issue it points to), finishes it, logs it and stops.
- The session header (printed by the SessionStart hook) shows what is done and what is ahead. It comes from `docs/STATUS.md`, so keep that file current and short.
- Do not start the next task in the same session. Say in the log what is ready next.
- Never go out of scope. Anything new John asks for mid-task is added to STATUS as its own task, not done in this one. (John, 2026-10-25.)
- Keep a tracker of the task, what is done and what remains, current at every step. Every reply ends with exactly what John must do next.

## 2. Concise everywhere
- Replies to John: result first, under 80 words, one link. Details go in the ledger, not the reply.
- Every reply to John opens with a progress header of two to four lines: what is done, what is happening now, what is left (including anything John must do). Then the answer. (Clarified by John 2026-10-25.)
- Docs: the shortest text that a new agent can act on. CLAUDE.md stays under 40 lines (CI enforces it).
- Commit messages: one line naming the task id and the change.

## 3. Pre-stage everything that can be pre-staged
- Before asking John for a manual step, batch every step he must do into one list with defaults.
- Scaffolding, config templates, scripts and docs are written by agents ahead of time so John only approves or pastes a secret.

## 4. Nothing lives only in agent context
- The ledger is the memory: `docs/STATUS.md` (now), `docs/DECISIONS.md` (why, append only), `docs/SPEC.md` (what), `docs/log/` (one file per task: task, done, deviations, bottlenecks, verification).
- Every task ends with a log entry and a STATUS update. The Stop hook blocks finishing until both exist; CI blocks merging without them.
- A decision made mid-task is appended to `docs/DECISIONS.md` as `D-nnn` in the same commit as the code that depends on it.
- Plans are files in `docs/superpowers/plans/`, never only in a chat. The PreCompact hook writes a checkpoint so a compacted session can resume from git state.
- Secrets never enter the ledger, the repo or memory. Environment variables only.

## 5. Parallelise, with a budget
- Independent, non-overlapping tasks run as parallel subagents or parallel sessions. Each log entry names the files the task owned.
- Default model routing: Sonnet for narrow prescribed tasks (implementer, researcher); Opus or stronger for planning, architecture, review and anything ambiguous. The dispatching agent sets the model.
- Cap: 4 parallel workers unless John raises it. A plan task is sized to finish inside half a context window.

## 5a. Token budget
- CLAUDE.md under 40 lines, STATUS under 40 lines (CI enforces both). Detail lives in files read on demand.
- `.claude/settings.json` denies reading secrets, lockfiles, dependencies and build output.
- Research and wide searches go to the `researcher` agent; the lead keeps the summary, not the file dumps.
- Check `/context` when a session feels slow; past half the window, checkpoint to the log and start fresh.
- Weekly: `npx ccusage@latest weekly` on John's machine; note anything unusual in STATUS.

## Per-task procedure
1. Read the header, `docs/STATUS.md`, the task's plan section or issue, and only the files named there.
2. Write the failing test first where code is involved (`superpowers:test-driven-development`).
3. Implement the minimum; run the verification named in the plan; read the output.
4. Commit on the task branch. Append the log entry and update STATUS in the same commit.
5. Open or update the PR using the template. A reviewer agent (Opus) checks spec compliance and quality before merge.
6. Stop. Report in under 150 words: files changed, test result, deviations, what is ready next.

## Definition of done
Tests green, verification output read, log entry and STATUS committed, PR open with the template filled, no secrets, no unrelated changes.

## Tools adopted
- superpowers (John's fork): brainstorming → writing-plans → subagent-driven-development; TDD; verification-before-completion; code review skills; git worktrees for parallel sessions.
- Claude Code hooks in `.claude/settings.json`: SessionStart header, Stop gate, PreCompact checkpoint.
- Agent definitions in `.claude/agents/` with pinned models.
- GitHub: issues as the task queue (labels `ready`, `blocked`, `M0`…`M4`), PR template, CI ledger check, branch protection on `main`.
- Security automation: gitleaks, CodeQL default setup, dependency review, Dependabot, Trivy, zizmor, OpenSSF Scorecard, Claude security review on PRs, all third-party actions pinned to commit SHAs (see `security/README.md`).
- pre-commit (`.pre-commit-config.yaml`) runs gitleaks and basic hygiene before every commit.
- ralph-wiggum plugin: allowed only for tasks with an automatic pass/fail check (a test file, a build), capped at 10 iterations.

## Tools evaluated and not adopted now
- Beads (`bd`): good dependency-aware queue, but it now stores issues in an embedded Dolt database synced through a special git ref; every fresh cloud clone would need a bootstrap step and a second binary. GitHub issues plus this ledger cover the need. Revisit if the issue count outgrows STATUS.md.
- GSD (get-shit-done) and spec-kit: overlap with superpowers' plan/execute flow; adopting both would mean two competing ledgers. Their ideas are borrowed: STATE-style status file, fresh subagent per task, verification files.
- BMAD, Roo Code: heavier or editor-bound; not needed.

## 6. Security gate per stage
- Every milestone (M1 to M4) and every deployment other people will use ends with the security gate in `security/README.md`: automated scans, the milestone's WSTG/ASVS/MASVS checklist, and a report saved under `docs/security/<date>-<milestone>/`.
- No high or critical finding stays open past the gate. Findings become issues; fixes are ordinary tasks; the report records the retest.
- The `security-tester` agent (Opus) runs it. It tests only this project's own deployment.

## 7. Merge audit at every stage close
- Before a milestone branch merges, and before any PR that carries off-plan work, the `merge-auditor` agent (Opus) checks: no conflicts with `main` after a local merge and a green test run; every off-plan change has a D-nnn entry and a SPEC change note or is removed; STATUS, DECISIONS, SPEC, RULES, the log entries and the build plan doc agree; the security report exists for a milestone close.
- Verdict MERGE, MERGE AFTER (fixes listed) or HOLD goes in the PR as a comment; John merges on MERGE.
- CI runs `scripts/check-docs.sh` on every PR for the parts a script can check: duplicate or dangling decision ids, broken CLAUDE.md pointers, missing log sections, file length caps.
- Off-plan ideas are welcome but go through the same door: a D-nnn entry and a SPEC note in the same PR, never a silent addition.
