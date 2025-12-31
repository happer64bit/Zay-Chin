import { generateKeyPairSync } from "node:crypto";
import fs from "node:fs";
import type { FastifyInstance, FastifyRequest } from "fastify";
import fp from "fastify-plugin";
import jwt, { type JwtPayload, type SignOptions } from "jsonwebtoken";
import type { StringValue } from "ms";
import db from "./db";
import { env } from "./env";
import { UnauthorizedAccess } from "./errors";

const plugin = async (fastify: FastifyInstance): Promise<void> => {
	fastify.decorateRequest("profile_id");

	fastify.addHook("preHandler", async (req: FastifyRequest) => {
		if (req.user_id) {
			const profileId = await db.query.profiles.findFirst({
				where: (fields, op) => op.eq(fields.user_id, req.user_id!),
				columns: { id: true },
			});

			if (profileId) req.profile_id = profileId.id;
		}
	});
};

export default fp(plugin, {
	name: "profile",
});
