import type { FastifyPluginAsync } from 'fastify';
import websocket from '@fastify/websocket';
import { addCartSubscriber, removeCartSubscriber } from '../realtime';

const cartRealtime: FastifyPluginAsync = async (app) => {
    await app.register(websocket);

    app.get('/ws', { websocket: true }, (connection, request) => {
        const { groupId } = request.query as { groupId?: string };

        if (!groupId) {
            connection.close(1008, 'groupId query parameter is required');
            return;
        }

        addCartSubscriber(groupId, connection);

        connection.on('close', () => {
            removeCartSubscriber(connection);
        });
    });
};

export default cartRealtime;


