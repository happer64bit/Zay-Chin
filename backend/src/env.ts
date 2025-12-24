import { createEnv } from '@t3-oss/env-core';
import { z } from 'zod';


export const env = createEnv({
    server: {
        JWT_PUBLIC_KEY: z.string(),
        JWT_PRIVATE_KEY: z.string(),
        DATABASE_URL: z.url(),
    },
    runtimeEnv: process.env,
});
