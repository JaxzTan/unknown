import { config } from "dotenv";
import path from "node:path";
import { defineConfig, env } from "prisma/config";

// .env lives at the repo root, one level above backend/
config({ path: path.resolve(__dirname, "../.env") });

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // Migrations need the session pooler (5432), not the transaction pooler
    url: env("DIRECT_URL"),
  },
});
