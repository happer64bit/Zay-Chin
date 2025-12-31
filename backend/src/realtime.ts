import type WebSocket from "ws";

// In-memory subscribers for cart updates per group
const cartSubscribers = new Map<string, Set<WebSocket>>();

export const addCartSubscriber = (groupId: string, socket: WebSocket): void => {
	let set = cartSubscribers.get(groupId);
	if (!set) {
		set = new Set();
		cartSubscribers.set(groupId, set);
	}
	set.add(socket);
};

export const removeCartSubscriber = (socket: WebSocket): void => {
	for (const [, set] of cartSubscribers) {
		if (set.has(socket)) {
			set.delete(socket);
		}
	}
};

export const notifyCartUpdated = (groupId: string): void => {
	const set = cartSubscribers.get(groupId);
	if (!set) return;

	const payload = JSON.stringify({
		type: "cart_updated",
		groupId,
	});

	for (const socket of set) {
		try {
			if ((socket as any).readyState === (socket as any).OPEN) {
				socket.send(payload);
			} else {
				set.delete(socket);
			}
		} catch {
			set.delete(socket);
		}
	}
};
