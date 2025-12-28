import type { FastifyPluginAsyncJsonSchemaToTs } from '@fastify/type-provider-json-schema-to-ts';
import {
    UnauthorizedAccess,
    UserAlreadyExists,
    UserDoesNotExists,
    InvalidCredentials,
} from '../errors';
import { users } from '../db/schema';
import db from '../db';
import { hash, verify } from 'argon2';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../auth';
import { cookies } from '../cookies';

async function createUser(email: string, password: string) {
    const existingUser = await db.query.users.findFirst({
        where: (fields, operators) => operators.eq(fields.email, email),
    });
    if (existingUser) throw new UserAlreadyExists(email);

    const hashedPassword = await hash(password);
    const [newUser] = await db
        .insert(users)
        .values({ email, password: hashedPassword })
        .returning();

    if (!newUser) throw new Error('Failed to create user');
    return newUser;
}

async function loginUser(email: string, password: string) {
    const user = await db.query.users.findFirst({
        where: (fields, operators) => operators.eq(fields.email, email),
    });
    if (!user) throw new UserDoesNotExists(email);

    const valid = await verify(user.password, password);
    if (!valid) throw new InvalidCredentials();

    return user;
}

function refreshToken(refreshToken: string) {
    const payload = verifyRefreshToken(refreshToken);
    if (!payload!.sub) throw new UnauthorizedAccess();
    return signAccessToken(payload!.sub);
}

function setAuthCookies(reply: any, userId: string) {
    const refresh_token = signRefreshToken(userId);

    reply.setCookie(
        cookies.refresh_token!.key,
        refresh_token,
        cookies.refresh_token!.options,
    );

    const access_token = signAccessToken(userId);
    return access_token;
}

const auth: FastifyPluginAsyncJsonSchemaToTs = async (app) => {
    app.route({
        method: 'POST',
        url: '/create',
        schema: {
            body: {
                type: 'object',
                properties: {
                    email: { type: 'string', format: 'email', maxLength: 255 },
                    password: { type: 'string', minLength: 8, maxLength: 255 },
                },
                required: ['email', 'password'],
            },
        },
        handler: async (request, reply) => {
            const { email, password } = request.body;
            const user = await createUser(email, password);
            const access_token = setAuthCookies(reply, user.id);
            return {
                message: 'User created successfully',
                data: { auth: { access_token } },
            };
        },
    });

    app.route({
        method: 'POST',
        url: '/login',
        schema: {
            body: {
                type: 'object',
                properties: {
                    email: { type: 'string', format: 'email', maxLength: 255 },
                    password: { type: 'string', minLength: 8, maxLength: 255 },
                },
                required: ['email', 'password'],
            },
        },
        handler: async (request, reply) => {
            const { email, password } = request.body;
            const user = await loginUser(email, password);
            const access_token = setAuthCookies(reply, user.id);
            return {
                message: 'Logged in successfully',
                data: { auth: { access_token } },
            };
        },
    });

    app.route({
        method: 'GET',
        url: '/session',
        schema: { security: [{ bearerHttpAuthentication: [] }] },
        handler: async (req, reply) => {
            if (!req.user_id) throw new UnauthorizedAccess();

            const user = await db.query.users.findFirst({
                where: (fields, op) => op.eq(fields.id, req.user_id!),
                columns: {
                    password: false,
                },
            });

            if (!user) throw new UnauthorizedAccess();

            reply.send({ data: user });
        },
    });

    app.route({
        method: 'GET',
        url: '/refresh',
        handler: (req) => {
            const token = req.cookies[cookies.refresh_token!.key];
            if (!token) throw new UnauthorizedAccess();
            const access_token = refreshToken(token);
            return { data: { auth: { access_token } } };
        },
    });
};

export default auth;
