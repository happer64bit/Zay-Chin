import "@fastify/cookie";

declare module "@fastify/cookie" {
	interface FastifyCookieOptions {}
}

declare module "fastify" {
	interface FastifyRequest {
		user_id?: string;
		profile_id?: string;
	}
}
