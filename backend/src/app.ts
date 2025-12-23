import swagger from '@fastify/swagger';
import swaggerUI from '@fastify/swagger-ui';

import authRoute from './routes/auth.js';
import type { FastifyInstance } from 'fastify';

export default async function (app: FastifyInstance) {
    await app.register(swagger, {
        openapi: {
            info: {
                title: 'Fastify API Documentation',
                description: 'Testing the Fastify swagger API',
                version: '1.0.0'
            }
        }
    });

    await app.register(swaggerUI, {
        routePrefix: '/docs'
    });

    await app.register(authRoute, { prefix: '/auth' });
} 
