import type { FastifyRequest } from 'fastify';

export class Context {
    req: FastifyRequest;

    constructor(req: FastifyRequest) {
        this.req = req;
    }

    get user_id(): string | undefined {
        return this.req.user_id;
    }
}

export type BaseContext = Omit<Context, 'user_id'>;

export type AuthContext = BaseContext & {
    user_id: string;
};
