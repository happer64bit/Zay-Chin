import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";
 
export const env = createEnv({
    server: {
        ACCESS_JWT_SECRET: z.string().min(1),
        REFRESH_JWT_SECRET: z.string().min(1),
    },
    runtimeEnv: process.env,
});
