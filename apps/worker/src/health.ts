import { APP_NAME } from "@adhd/core";

export interface Health {
  status: "ok";
  app: string;
}

export function health(): Health {
  return { status: "ok", app: APP_NAME };
}
