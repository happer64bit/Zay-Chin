import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";
import fastify, { type FastifyInstance } from "fastify";
import authRoute from "./routes/auth";
import cartRoute from "./routes/cart";
import cartRealtimeRoute from "./routes/cart-realtime";
import groupRoute from "./routes/group";
import profileRoute from "./routes/profile";

export async function buildServer(): Promise<FastifyInstance> {
	const app = fastify({ logger: true });

	await app.register(import("@fastify/cookie"));

	await app.register(import("@fastify/cors"), {
		origin: true,
		credentials: true,
	});

	await app.register(import("./auth"));

	await app.register(swagger, {
		openapi: {
			info: {
				title: "Fastify API Documentation",
				description: "Testing the Fastify swagger API",
				version: "1.0.0",
			},
			components: {
				securitySchemes: {
					bearerHttpAuthentication: {
						type: "http",
						scheme: "bearer",
						bearerFormat: "JWT",
					},
				},
			},
		},
	});

	await app.register(swaggerUI, {
		routePrefix: "/docs",
	});

	await app.register(authRoute, { prefix: "/auth" });
	await app.register(groupRoute, { prefix: "/group" });
	await app.register(profileRoute, { prefix: "/profile" });
	// Register WebSocket route before regular cart routes to avoid route conflicts
	await app.register(cartRealtimeRoute, { prefix: "/cart" });
	await app.register(cartRoute, { prefix: "/cart" });

	return app;
}
