# CI entry point (ci.yml calls `make ci`). Every app in apps/ and package in packages/
# defines lint, typecheck, test and build scripts; turbo runs only what changed.
.PHONY: ci install
install:
	pnpm install --frozen-lockfile
ci: install
	pnpm run ci
