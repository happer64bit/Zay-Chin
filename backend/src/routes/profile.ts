import type { FastifyPluginAsyncJsonSchemaToTs } from "@fastify/type-provider-json-schema-to-ts";
import { eq } from "drizzle-orm";
import db from "../db";
import { profiles } from "../db/schema";
import {
	ProfileAlreadyExists,
	ProfileRequired,
	UnauthorizedAccess,
} from "../errors";

const createOrUpdateProfileSchema = {
	type: "object",
	properties: {
		name: { type: "string", maxLength: 255 },
		gender: { type: "string", enum: ["male", "female", "other"] },
	},
	required: ["name", "gender"],
} as const;

const profile: FastifyPluginAsyncJsonSchemaToTs = async (app) => {
	await app.register(import("./../profile"));

	app.addHook("preHandler", (req, reply, next) => {
		if (!req.user_id) throw new UnauthorizedAccess();
		next();
	});

	app.post("/setup", {
		schema: {
			security: [{ bearerHttpAuthentication: [] }],
			tags: ["profile"],
			body: createOrUpdateProfileSchema,
		},
		handler: async (req) => {
			if (req.profile_id) throw new ProfileAlreadyExists();

			const { name, gender } = req.body;

			const [newProfile] = await db
				.insert(profiles)
				.values({
					name,
					gender,
					user_id: req.user_id!,
				})
				.returning();

			if (!newProfile) throw new Error("Failed to create profile");

			return {
				message: "Profile setup success",
				data: { profile: newProfile },
			};
		},
	});

	app.get("/", {
		schema: {
			security: [{ bearerHttpAuthentication: [] }],
			tags: ["profile"],
		},
		handler: async (req, reply) => {
			if (!req.profile_id) throw new ProfileRequired();

			const profileData = await db.query.profiles.findFirst({
				where: (fields, operators) => operators.eq(fields.id, req.profile_id!),
			});

			return profileData;
		},
	});

	app.put("/update", {
		schema: {
			security: [{ bearerHttpAuthentication: [] }],
			tags: ["profile"],
			body: createOrUpdateProfileSchema,
		},
		handler: async (req) => {
			if (!req.profile_id) throw new ProfileRequired();

			const { name, gender } = req.body;

			const [updatedProfile] = await db
				.update(profiles)
				.set({ name, gender })
				.where(eq(profiles, req.profile_id!))
				.returning();

			if (!updatedProfile) throw new Error("Failed to update profile");

			return {
				message: "Profile updated successfully",
				data: { profile: updatedProfile },
			};
		},
	});
};

export default profile;
