import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone", // minimal server for the Docker image
  cacheComponents: true,
  partialPrefetching: true,
};

export default nextConfig;
