// Background worker (TRD §1): publishing, data sync, scoring, weekly summary.
// Stub for now: consumes the "jobs" queue and logs each job.
import { Worker } from "bullmq";

const connection = { url: process.env.REDIS_URL ?? "redis://localhost:6379" };

const worker = new Worker(
  "jobs",
  async (job) => {
    console.log(`[worker] ${job.name}`, job.data);
  },
  { connection },
);

worker.on("ready", () => console.log("[worker] connected to redis"));
worker.on("failed", (job, err) => console.error(`[worker] ${job?.name} failed`, err));

const shutdown = async () => {
  await worker.close();
  process.exit(0);
};
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
