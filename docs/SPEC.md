# Spec

What we are building. Filled from the scope and stack thread. Each change note is dated and names its D-nnn.

## Product
TBD: capture by voice, Claude triage (do now, automate, quick task, long-term goal, park, idea), learning and second-brain loop, web dashboard and mobile app.

## First feature (D-006)
Sort a thought: typed capture on the web, Claude splits and files into seven buckets, asks when unsure. Design: `docs/superpowers/specs/2026-10-25-sort-a-thought-design.md`.

## Stack and layout
D-002: pnpm + Turborepo. `apps/mobile` Expo (Android first), `apps/web` Next.js, `apps/worker` Node worker, `packages/core` shared types and Zod schemas, `supabase/` migrations and RLS, `deploy/` Compose and Caddy, `evals/` triage cases. Users bring their own Anthropic API key.

## Change notes
- 2026-10-25 · D-005 · Two Expo dev-CLI advisories allowed in the security checks; no product change.
- 2026-10-25 · D-006 · First feature set to sort a thought, web first, on its own server.
