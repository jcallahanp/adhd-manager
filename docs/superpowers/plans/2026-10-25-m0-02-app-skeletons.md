# M0-02 First app skeletons

Goal: four workspace packages that each pass `lint`, `typecheck`, `test` and `build` under `make ci`. No product features.

Shared: `tsconfig.base.json` (strict), root `eslint.config.mjs` (typescript-eslint) for core and worker. ESLint 9 (eslint-config-next and eslint-config-expo do not support 10 yet); TypeScript 6.0 (typescript-eslint supports < 6.1); React 19.3.0 everywhere (Expo SDK 58 pin).

1. `packages/core` (`@adhd/core`): exports `APP_NAME`; tsc build to `dist/`; Vitest. Test first.
2. `apps/worker` (`@adhd/worker`): `health()` returns `{ status, app }` from core; tsc build; Vitest.
3. `apps/web` (`@adhd/web`): Next.js 16 App Router page shows `APP_NAME`; eslint-config-next; Vitest + Testing Library; `next build`.
4. `apps/mobile` (`@adhd/mobile`): Expo SDK 58 `App.tsx` shows `APP_NAME`; eslint-config-expo; jest-expo + Testing Library; build is `expo export --platform android`.

Verification: `make ci` green locally on Node 24 and in the CI `build` job.
