# Sort a thought: design

Task M0-03 · 2026-10-25 · Decisions: D-006 · Status: approved by John 2026-10-25

## What John gets
Open the web dashboard on any browser (phone included), sign in, type a thought or a ramble, and within about ten seconds see it split into separate items, each filed into one of seven buckets. Items Claude is unsure about wait at the top of the inbox with the two likeliest buckets as buttons. Any item moves to another bucket in one tap.

## John's answers (brainstorm)
1. First feature: type a thought, Claude splits and sorts it.
2. Web dashboard first; the Android app comes with voice capture.
3. Claude files confident items and asks only when unsure.
4. Runs on a new small DigitalOcean server (2 GB, about $12 a month) with its own domain.

## In this version
- Sign-in with email and password through Supabase Auth. Public sign-up is off; accounts are created by an admin script (John first).
- Settings page: paste your own Anthropic API key. It is encrypted (AES-256-GCM, master key from `KEY_ENCRYPTION_KEY`) on the server, never logged, never sent back to the browser (the page shows only the last four characters).
- Capture page: one text box and a Save button. The text is saved untouched as the original before any Claude call.
- Inbox page: "Needs your answer" first, then filed items grouped by bucket, newest first. Each item shows its title, its bucket, a due date if any (marked "inferred" when Claude guessed it), and a link to the original capture. Updates live through Supabase Realtime.
- Move: one tap picks a new bucket. The correction (original text, Claude's bucket, John's bucket) is saved for future prompt examples.

## Buckets
Seven, from the scope doc: tool can do it, do now, quick task (dated), long-term goal, learning, idea or note, parked. In this version a bucket is a label plus a due date. Reminders, goal milestones, the learning cap and tool actions come in later features. "Tool can do it" shows "no tool connected yet".

## How it works
1. The web app inserts a `captures` row (client-made UUID, raw text, status `queued`). RLS limits every row to its owner.
2. A database trigger puts a job on a pgmq queue.
3. The worker takes the job, decrypts the owner's key, and calls Claude (model from `TRIAGE_MODEL`, default the current Haiku) with a fixed, cached system prompt and the capture text inside delimiters. The call has no tools; the reply is structured JSON.
4. The reply is checked against a Zod schema in `packages/core`: a list of items, each with source text span, title, bucket, confidence (0 to 1), due date, whether the date was inferred, and the next likeliest bucket.
5. The worker writes one `items` row per item, linked to the capture. Confidence at or above 0.75 (`TRIAGE_CONFIDENCE`) is filed; below it the item is `needs_answer` with two bucket buttons.
6. The capture is marked `done`.

## When things go wrong
- No API key: the capture waits as `needs_key` and the inbox links to Settings; saving a key re-queues it.
- Claude error, timeout or invalid JSON: three retries with backoff, then the capture shows `failed` with a Retry button. The original text is never lost.
- Invalid key (401): `needs_key`, no retries.

## Safety
- Captured text is untrusted input to the model (OWASP LLM01): no tools, no URLs, output limited to the schema, and the worker uses only the capture owner's data and key.
- Only the capture text is sent to Anthropic, under the owner's key. Nothing bills John for another user.
- RLS on every table, with tests that one user cannot read another's captures, items or key.

## Testing
- Unit tests: schema, bucket threshold logic, encryption round trip, error states (Claude client mocked).
- Database tests: RLS isolation and the queue trigger, run against local Supabase in CI.
- Triage evals: `evals/triage/` holds about 30 sample captures with expected buckets. CI checks them against recorded replies; a manual GitHub workflow runs them live.
- One end-to-end test in CI: sign in, capture, see items (Claude stubbed).

## Deploy
`deploy/` holds the Compose file (self-hosted Supabase, web, worker, Caddy) and a nightly `pg_dump` kept for 7 days on the server. John gets exact steps to create the server, point a domain at it and add the secrets; a GitHub Actions workflow deploys on merge to `main`. Off-server backups and a restore drill are a separate task before anyone else is invited.

## Not in this version
Voice, the Android app, push reminders, PowerSync offline sync (the web app is online-only), goals and milestones, learning items, notes search, tool actions, data export, other users.

## Done when
John signs in on his phone's browser at his domain, saves his key, types a ramble with three thoughts, and sees three filed or asking items within about ten seconds; moving one records a correction.
