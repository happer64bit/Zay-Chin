import { createEnv } from '@t3-oss/env-core';
import { z } from 'zod';

export const env = createEnv({
    server: {
        JWT_PUBLIC_KEY_PATH: z.string(),
        JWT_PRIVATE_KEY_PATH: z.string(),
        DATABASE_URL: z.url(),
    },
    runtimeEnv: process.env,
});
