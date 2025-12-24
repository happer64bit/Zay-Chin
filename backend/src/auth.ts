import fp from 'fastify-plugin';
import jwt, { type JwtPayload, type SignOptions } from 'jsonwebtoken';
import fs from 'node:fs';
import { generateKeyPairSync } from 'node:crypto';
import type { FastifyInstance, FastifyRequest } from 'fastify';
import { type StringValue } from 'ms';

let publicKey: Buffer;
let privateKey: Buffer;

export const loadAuthKeys = (): void => {
    if (process.env.NODE_ENV !== 'production') {
        const keyPair = generateKeyPairSync('rsa', {
            modulusLength: 2048,
            publicKeyEncoding: { type: 'pkcs1', format: 'pem' },
            privateKeyEncoding: { type: 'pkcs1', format: 'pem' },
        });

        publicKey = Buffer.from(keyPair.publicKey);
        privateKey = Buffer.from(keyPair.privateKey);
    } else {
        publicKey = fs.readFileSync(process.env.JWT_PUBLIC_KEY_PATH as string);
        privateKey = fs.readFileSync(
            process.env.JWT_PRIVATE_KEY_PATH as string,
        );
    }
};

export const signAccessToken = (
    sub: string,
    expiresIn: StringValue = '15m',
): string => {
    const options: SignOptions = { algorithm: 'RS256', expiresIn };
    return jwt.sign({ sub } as JwtPayload, privateKey, options);
};

export const signRefreshToken = (
    sub: string,
    expiresIn: StringValue = '7d',
): string => {
    const options: SignOptions = { algorithm: 'RS256', expiresIn };
    return jwt.sign({ sub } as JwtPayload, privateKey, options);
};

export const verifyAccessToken = (token: string): { sub: string } | null => {
    try {
        return jwt.verify(token, publicKey, {
            algorithms: ['RS256'],
        }) as { sub: string };
    } catch {
        return null;
    }
};

export const verifyRefreshToken = (token: string): { sub: string } | null => {
    try {
        return jwt.verify(token, publicKey, {
            algorithms: ['RS256'],
        }) as { sub: string };
    } catch {
        return null;
    }
};

const plugin = async (fastify: FastifyInstance): Promise<void> => {
    loadAuthKeys();
    
    fastify.decorateRequest('user_id');

    fastify.addHook('preHandler', async (req: FastifyRequest) => {
        const auth = req.headers.authorization;

        if (!auth) return;

        const token = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
        const payload = verifyAccessToken(token);
        if (payload) req.user_id = payload.sub;
    });
};

export default fp(plugin, {
    name: 'auth',
});
