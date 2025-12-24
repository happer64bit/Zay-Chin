import swagger from '@fastify/swagger';
import swaggerUI from '@fastify/swagger-ui';

import authRoute from './routes/auth';
import type { FastifyInstance } from 'fastify';
import { schema } from './graphql';
import { Context } from './context';

export default async function (app: FastifyInstance) {
    await app.register(import('@fastify/cookie'));
    await app.register(import('./auth'));

    await app.register(import('mercurius'), {
        schema: schema,
        graphiql: true,
        context: (request) => new Context(request)
    });

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
}
