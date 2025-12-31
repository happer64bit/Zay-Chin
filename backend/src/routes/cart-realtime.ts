import type { FastifyPluginAsync } from 'fastify';
import websocket from '@fastify/websocket';
import { addCartSubscriber, removeCartSubscriber } from '../realtime';
import { verifyAccessToken } from '../auth';
import { UnauthorizedAccess } from '../errors';

const cartRealtime: FastifyPluginAsync = async (app) => {
    await app.register(websocket);

    app.get('/ws', { websocket: true }, (connection, request) => {
        // Authenticate WebSocket connection
        // Check Authorization header first, then token query parameter
        let token: string | undefined;
        const auth = request.headers.authorization;
        if (auth) {
            token = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
        } else {
            // Fallback: check token in query parameters (for mobile WebSocket)
            const { token: queryToken } = request.query as { token?: string };
            token = queryToken;
        }

        if (!token) {
            connection.close(1008, 'Authentication required');
            return;
        }

        const payload = verifyAccessToken(token);
        if (!payload) {
            connection.close(1008, 'Invalid token');
            return;
        }

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


