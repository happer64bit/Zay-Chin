import fastify, { type FastifyInstance } from 'fastify';
import swagger from '@fastify/swagger';
import swaggerUI from '@fastify/swagger-ui';
import authRoute from './routes/auth';
import groupRoute from './routes/group';
import profileRoute from './routes/profile';
import cartRoute from './routes/cart';
import cartRealtimeRoute from './routes/cart-realtime';

export async function buildServer(): Promise<FastifyInstance> {
    const app = fastify({ logger: true });

    await app.register(import('@fastify/cookie'));

    await app.register(import('@fastify/cors'), {
        origin: true, // Allow all origins in development
        credentials: true, // Allow cookies
    });

    await app.register(import('./auth'));

    await app.register(swagger, {
        openapi: {
            info: {
                title: 'Fastify API Documentation',
                description: 'Testing the Fastify swagger API',
                version: '1.0.0',
            },
            components: {
                securitySchemes: {
                    bearerHttpAuthentication: {
                        type: 'http',
                        scheme: 'bearer',
                        bearerFormat: 'JWT',
                    },
                },
            },
        },
    });

    await app.register(swaggerUI, {
        routePrefix: '/docs',
    });

    await app.register(authRoute, { prefix: '/auth' });
    await app.register(groupRoute, { prefix: '/group' });
    await app.register(profileRoute, { prefix: '/profile' });
    await app.register(cartRoute, { prefix: '/cart' });
    await app.register(cartRealtimeRoute, { prefix: '/cart' });

    return app;
}
