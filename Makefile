# CI entry point (ci.yml calls `make ci`). Every app in apps/ and package in packages/
# defines lint, typecheck, test and build scripts; turbo runs only what changed.
.PHONY: ci install
install:
	pnpm install --frozen-lockfile
ci: install
	pnpm run ci
# Database tests (M1-01): local Supabase in Docker, pgTAP isolation tests, sign-up check.
.PHONY: db-test
db-test:
	supabase start -x $(SUPABASE_EXCLUDE)
	supabase db lint --fail-on error
	supabase test db
	bash supabase/tests/signup-off.sh
SUPABASE_EXCLUDE := studio,imgproxy,storage-api,edge-runtime,logflare,vector,supavisor,postgres-meta,mailpit,realtime
