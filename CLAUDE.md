# Agent instructions

Read `docs/STATUS.md` first (the session header prints it). Then read only what your task needs.
No STATUS header printed means the hooks did not load (multi-repo cloud sessions start outside the repo): run `bash .claude/hooks/session-start.sh </dev/null` now, and before finishing run `AP_BASE=origin/main bash .claude/hooks/stop-gate.sh </dev/null` (no output means pass).

## Scope (John's rule, 2026-10-25)
- Each session or thread has one narrow task. It never goes out of scope; new asks become a new task in `docs/STATUS.md`.
- Keep a visible tracker: the task, what is done, what remains. Update it at every step.
- Every reply ends with exactly what John must do next, or "nothing".
- When the task is done: log it, update STATUS, close out, stop. Do not start the next task.

## Process
- Spec: `docs/SPEC.md`. Decisions: `docs/DECISIONS.md` (append only). Rules: `docs/RULES.md`.
- New feature: `superpowers:brainstorming`, then `superpowers:writing-plans` into `docs/superpowers/plans/`, then `superpowers:subagent-driven-development`. Bugs: `superpowers:systematic-debugging`.
- Test first (`superpowers:test-driven-development`). Run the verification and read its output before saying done.
- Before you finish: add `docs/log/YYYY-MM-DD-<task-id>.md` (`scripts/task-log.sh`) and update `docs/STATUS.md`. The Stop hook and CI check this.
- Off-plan work needs a D-nnn entry and a SPEC change note in the same PR.

## Tokens and context
- Sonnet for narrow, fully specified tasks; Opus for planning, review and ambiguous work. The dispatcher sets the model.
- Send broad reading and searches to a subagent that returns a short summary with file:line citations.
- Never read `pnpm-lock.yaml`, build output, `node_modules`, generated clients or fixtures unless the task is about them.
- Stack: pnpm + Turborepo; `apps/mobile` (Expo), `apps/web` (Next.js), `apps/worker`, `packages/core`, `supabase/`. CI runs `make ci`.
- Keep failing test output whole; trim passing output. Prefer `gh` and other CLIs over MCP tools when both work.
- Past half the context window, write state to the log and plan, then `/compact` or start a fresh session.

## Safety
- Never commit secrets. Config comes from environment variables; `.env.example` lists them.
- Each user brings their own Anthropic API key: encrypted at rest, never logged, never sent back to a client. User data goes only to the Anthropic API, and only the fields the call needs.
- Text a user logs is untrusted input to the LLM: it never chooses tools, URLs or other users' data (OWASP LLM01).
- Every milestone ends with the security gate in `security/README.md`.
- Keep replies, docs and commit messages short. No summaries of work already in the ledger.
