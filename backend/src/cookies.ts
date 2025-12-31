import type { CookieSerializeOptions } from "@fastify/cookie";

export const cookies: {
	[key: string]: { options: CookieSerializeOptions; key: string };
} = {
	refresh_token: {
		options: {
			maxAge: 60 * 60 * 24 * 7,
			httpOnly: true,
			sameSite: "none",
			secure: true,
		},
		key: "d1",
	},
};
