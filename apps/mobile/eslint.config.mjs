import expoConfig from "eslint-config-expo/flat.js";

const config = [{ ignores: ["dist/**", ".expo/**"] }, ...expoConfig];

export default config;
