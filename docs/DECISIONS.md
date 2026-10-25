# Decisions

Append only. Format: `- D-nnn · date · decision · why · consequence`.

- D-001 · 2026-10-25 · Engineering process copied from the health-system repo (rules, ledger, hooks, agents, security gate), plus CodeQL, dependency review, Dependabot, Trivy, zizmor, OpenSSF Scorecard and a Claude security review on PRs; third-party actions pinned to commit SHAs. · Proven on M0 of the health platform; the March 2026 trivy-action tag hijack (CVE-2026-33634) showed tag pins are not enough. · Dependabot keeps the SHAs current.
- D-002 · 2026-10-25 · Stack is TypeScript (John): pnpm + Turborepo monorepo with `apps/mobile` (Expo, Android first), `apps/web` (Next.js), `apps/worker` (Node, Anthropic TypeScript SDK), `packages/core`; self-hosted Supabase + PowerSync; users bring their own Anthropic API key, stored encrypted. pnpm 10 and Node 24 pinned. · One language across mobile, web and worker; nothing bills John for other users. · CI runs `make ci`; Dependabot npm, docker, actions; CodeQL javascript-typescript; `.npmrc` node-linker=hoisted for Expo.
