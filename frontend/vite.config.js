import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const railwayFrontendDomain = "divine-rejoicing-production-542f.up.railway.app";

export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: [railwayFrontendDomain],
  },
  preview: {
    allowedHosts: [railwayFrontendDomain],
  },
});
