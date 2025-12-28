import type { FastifyPluginAsyncJsonSchemaToTs } from '@fastify/type-provider-json-schema-to-ts';
import db from '../db';
import { groupMembers, invitations, profiles } from '../db/schema';
import { eq, and } from 'drizzle-orm';
import * as GroupService from '../service/group';
import { UnauthorizedAccess } from '../errors';

const groups: FastifyPluginAsyncJsonSchemaToTs = async (app) => {
    await app.register(import('./../profile'));

    app.addHook('preHandler', async (req, reply) => {
        if (!req.user_id) throw new UnauthorizedAccess();
        if (!req.profile_id)
            throw new UnauthorizedAccess('Requires to setup profile');
    });

    app.route({
        method: 'GET',
        url: '/',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
        },
        handler: async (req) => {
            return GroupService.getGroupsForProfile(req.profile_id!);
        },
    });

    app.route({
        method: 'GET',
        url: '/:id',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
            params: {
                type: 'object',
                properties: {
                    id: { type: 'string', format: 'uuid' },
                },
                required: ['id'],
            },
        },
        handler: async (req) => {
            return GroupService.getGroupById(req.params.id, req.profile_id!);
        },
    });

    app.route({
        method: 'GET',
        url: '/:id/members',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
            params: {
                type: 'object',
                properties: {
                    id: { type: 'string', format: 'uuid' },
                },
                required: ['id'],
            },
        },
        handler: async (req) => {
            const membership = await db.query.groupMembers.findFirst({
                where: and(
                    eq(groupMembers.group_id, req.params.id),
                    eq(groupMembers.profile_id, req.profile_id!),
                ),
            });
            if (!membership) throw new UnauthorizedAccess();

            return db.query.groupMembers.findMany({
                where: eq(groupMembers.group_id, req.params.id),
            });
        },
    });

    app.route({
        method: 'GET',
        url: '/invites',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
        },
        handler: async (req) => {
            return db.query.invitations.findMany({
                where: and(
                    eq(invitations.invited_profile_id, req.profile_id!),
                    eq(invitations.status, 'pending'),
                ),
            });
        },
    });

    app.route({
        method: 'POST',
        url: '/',
        schema: {
            body: {
                type: 'object',
                properties: {
                    name: { type: 'string', minLength: 1, maxLength: 255 },
                },
                required: ['name'],
            },
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
        },
        handler: async (req) => {
            return GroupService.createGroup(req.body.name, req.profile_id!);
        },
    });

    app.route({
        method: 'POST',
        url: '/:id/invite',
        schema: {
            body: {
                type: 'object',
                properties: {
                    email: { type: 'string', format: 'email' },
                },
                required: ['email'],
            },
            params: {
                type: 'object',
                properties: {
                    id: {
                        type: 'string',
                    },
                },
                required: ['id'],
            },
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
        },
        handler: async (req) => {
            return GroupService.inviteToGroup(
                req.params.id,
                req.body.email,
                req.profile_id!,
            );
        },
    });

    app.route({
        method: 'POST',
        url: '/invites/:id/accept',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
            params: {
                type: 'object',
                properties: {
                    id: {
                        type: 'string',
                    },
                },
                required: ['id'],
            },
        },
        handler: async (req) => {
            return GroupService.acceptInvitation(
                req.params.id,
                req.profile_id!,
            );
        },
    });

    app.route({
        method: 'POST',
        url: '/invites/:id/reject',
        schema: {
            security: [{ bearerHttpAuthentication: [] }],
            tags: ['group'],
            params: {
                type: 'object',
                properties: {
                    id: {
                        type: 'string',
                    },
                },
                required: ['id'],
            },
        },
        handler: async (req) => {
            const success = await GroupService.rejectInvitation(
                req.params.id,
                req.profile_id!,
            );
            return { success };
        },
    });
};

export default groups;
