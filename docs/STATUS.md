# Status

Updated: 2026-10-26 · Milestone: M1 Sort a thought · Keep this file under 40 lines.

## Done
- M0-01 Repo scaffold: rules, ledger, hooks, agents, CI and security workflows, Dependabot, pre-commit. Merged (#1).
- M0-01b Exact settings steps; Dependabot docker entry deferred to the first Dockerfile.
- M0-02 App skeletons (`packages/core`, `apps/worker`, `apps/web`, `apps/mobile`); `make ci` green. Merged (#3).
- M0-03 First feature brainstorm: sort a thought (D-006); design in `docs/superpowers/specs/`, plan `docs/superpowers/plans/2026-10-25-sort-a-thought.md`. Merged (#4).
- M1-01 Database: tables, RLS, 38 isolation tests, sign-up off; CI job `database`. PR open.

## In progress
- Scope (separate thread); results go into `docs/SPEC.md`. Stack set: D-002.

## Next (ready, in order)
- M1-02 Triage contract in core (bucket strings must match the M1-01 enum).
- Then M1-03 to M1-07 in plan order.

## Blocked / waiting on John
- Review and merge the M1-01 PR.
