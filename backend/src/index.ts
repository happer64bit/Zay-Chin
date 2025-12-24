import Fastify from 'fastify';

import app from './app';

const fastify = Fastify({
    logger: true,
});

fastify.register(app);

fastify.listen({ port: 3000 }, (err, addr) => {
    if (err) {
        fastify.log.error(err);
        process.exit(1);
    }

    fastify.log.info(`Server listening at ${addr}`);
});
