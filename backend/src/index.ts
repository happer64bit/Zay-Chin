import { buildServer } from './app';

(await buildServer()).listen({ port: 3000 }, (err, addr) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }

    console.info(`Server listening at ${addr}`);
});
