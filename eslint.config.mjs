// Shared lint config for packages/core and apps/worker. apps/web and apps/mobile have their own.
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["**/dist/**", "**/node_modules/**", "apps/web/**", "apps/mobile/**"] },
  js.configs.recommended,
  ...tseslint.configs.strict,
);
