import type { FastifyPluginAsyncJsonSchemaToTs } from '@fastify/type-provider-json-schema-to-ts';
import * as CartService from '../service/cart';
import { UnauthorizedAccess } from '../errors';

const cart: FastifyPluginAsyncJsonSchemaToTs = async (app) => {
    app.register(import('./../profile'));

    app.addHook('preHandler', async (req) => {
        if (!req.user_id) throw new UnauthorizedAccess();
        if (!req.profile_id)
            throw new UnauthorizedAccess('Requires profile setup');
    });

    app.route({
        method: 'GET',
        url: '/:groupId',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['cart'],
            params: {
                type: 'object',
                properties: { groupId: { type: 'string', format: 'uuid' } },
                required: ['groupId'],
            },
        },
        handler: async (req) => {
            await CartService.assertGroupMember(
                req.params.groupId,
                req.profile_id!,
            );
            return CartService.getCart(req.params.groupId);
        },
    });

    app.route({
        method: 'POST',
        url: '/:groupId',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['cart'],
            params: {
                type: 'object',
                properties: { groupId: { type: 'string', format: 'uuid' } },
                required: ['groupId'],
            },
            body: {
                type: 'object',
                properties: {
                    item_name: { type: 'string' },
                    category: { type: 'string' },
                    price: { type: 'number' },
                    quantity: { type: 'number', minimum: 1 },
                },
                required: ['item_name', 'category', 'price', 'quantity'],
            },
        },
        handler: async (req) => {
            await CartService.assertGroupMember(
                req.params.groupId,
                req.profile_id!,
            );
            return CartService.addOrUpdateItem(req.params.groupId, req.body);
        },
    });

    app.route({
        method: 'DELETE',
        url: '/:groupId',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['cart'],
            params: {
                type: 'object',
                properties: { groupId: { type: 'string', format: 'uuid' } },
                required: ['groupId'],
            },
            body: {
                type: 'object',
                properties: { id: { type: 'string', format: 'uuid' } },
                required: ['id'],
            },
        },
        handler: async (req) => {
            await CartService.assertGroupMember(
                req.params.groupId,
                req.profile_id!,
            );
            return CartService.removeItem(
                req.params.groupId,
                req.body.id,
            );
        },
    });

    app.route({
        method: 'PATCH',
        url: '/:groupId/:id',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['cart'],
            params: {
                type: 'object',
                properties: {
                    groupId: { type: 'string', format: 'uuid' },
                    id: { type: 'string', format: 'uuid' },
                },
                required: ['groupId', 'id'],
            },
            body: {
                type: 'object',
                properties: {
                    item_name: { type: 'string' },
                    category: { type: 'string' },
                    price: { type: 'number' },
                    quantity: { type: 'number', minimum: 1 },
                    current: { type: 'number' },
                },
                additionalProperties: false,
            },
        },
        handler: async (req) => {
            await CartService.assertGroupMember(
                req.params.groupId,
                req.profile_id!,
            );

            return CartService.updateItem(
                req.params.groupId,
                req.params.id,
                req.body,
            );
        },
    });
};

export default cart;
