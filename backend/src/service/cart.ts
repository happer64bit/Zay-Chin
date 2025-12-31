import { and, eq, sql } from "drizzle-orm";
import db from "../db";
import { carts } from "../db/schema";
import { UnauthorizedAccess } from "../errors";
import { notifyCartUpdated } from "../realtime";

export const assertGroupMember = async (groupId: string, profileId: string) => {
	const member = await db.query.groupMembers.findFirst({
		where: (f, op) =>
			op.and(eq(f.group_id, groupId), eq(f.profile_id, profileId)),
	});

	if (!member) throw new UnauthorizedAccess("Not a group member");
	return member;
};

export const getCart = async (groupId: string) => {
	const items = await db
		.select({
			id: carts.id,
			group_id: carts.group_id,
			item_name: carts.item_name,
			quantity: carts.quantity,
			current: carts.current,
			category: carts.category,
			price: carts.price,
			location_lat: sql<
				number | null
			>`CAST(ST_Y(${carts.location}) AS DOUBLE PRECISION)`,
			location_lng: sql<
				number | null
			>`CAST(ST_X(${carts.location}) AS DOUBLE PRECISION)`,
			location_name: carts.location_name,
			created_at: carts.created_at,
			updated_at: carts.updated_at,
		})
		.from(carts)
		.where(eq(carts.group_id, groupId));

	return items;
};

export const addOrUpdateItem = async (
	groupId: string,
	data: {
		item_name: string;
		category: string;
		price: number;
		quantity: number;
		location_lat?: number;
		location_lng?: number;
		location_name?: string;
	},
) => {
	const locationGeometry =
		data.location_lat !== undefined && data.location_lng !== undefined
			? sql`ST_SetSRID(ST_MakePoint(${data.location_lng}, ${data.location_lat}), 4326)`
			: null;

	const [inserted] = await db
		.insert(carts)
		.values({
			group_id: groupId,
			item_name: data.item_name,
			category: data.category,
			price: data.price,
			quantity: data.quantity,
			location: locationGeometry as any,
			location_name: data.location_name,
		})
		.returning();

	if (!inserted) throw new Error("Failed to create item");

	// Convert geometry back to lat/lng for response
	const result = await db
		.select({
			id: carts.id,
			group_id: carts.group_id,
			item_name: carts.item_name,
			quantity: carts.quantity,
			current: carts.current,
			category: carts.category,
			price: carts.price,
			location_lat: sql<
				number | null
			>`CAST(ST_Y(${carts.location}) AS DOUBLE PRECISION)`,
			location_lng: sql<
				number | null
			>`CAST(ST_X(${carts.location}) AS DOUBLE PRECISION)`,
			location_name: carts.location_name,
			created_at: carts.created_at,
			updated_at: carts.updated_at,
		})
		.from(carts)
		.where(eq(carts.id, inserted.id));

	notifyCartUpdated(groupId);
	return result;
};

export const removeItem = async (groupId: string, id: string) => {
	await db
		.delete(carts)
		.where(and(eq(carts.group_id, groupId), eq(carts.id, id)));

	notifyCartUpdated(groupId);
	return [];
};

export const updateItem = async (
	groupId: string,
	id: string,
	data: Partial<{
		item_name: string;
		category: string;
		price: number;
		quantity: number;
		current: number;
		location_lat: number;
		location_lng: number;
		location_name: string | null;
	}>,
) => {
	if (data.current !== undefined || data.quantity !== undefined) {
		const existing = await db.query.carts.findFirst({
			where: (f, op) => op.and(eq(f.id, id), eq(f.group_id, groupId)),
		});

		if (!existing) throw new UnauthorizedAccess();

		const nextQty = data.quantity ?? existing.quantity;
		const nextCurrent = data.current ?? existing.current;

		if (nextCurrent > nextQty)
			throw new UnauthorizedAccess("Current cannot exceed quantity");
	}

	// Convert location_lat/lng to geometry if provided
	const updateData: any = { ...data };
	if (data.location_lat !== undefined && data.location_lng !== undefined) {
		updateData.location = sql`ST_SetSRID(ST_MakePoint(${data.location_lng}, ${data.location_lat}), 4326)`;
		delete updateData.location_lat;
		delete updateData.location_lng;
	} else if (data.location_lat === null || data.location_lng === null) {
		// Allow clearing location by setting to null
		updateData.location = null;
		delete updateData.location_lat;
		delete updateData.location_lng;
	}

	await db
		.update(carts)
		.set(updateData)
		.where(and(eq(carts.id, id), eq(carts.group_id, groupId)));

	// Return updated item with lat/lng extracted
	const result = await db
		.select({
			id: carts.id,
			group_id: carts.group_id,
			item_name: carts.item_name,
			quantity: carts.quantity,
			current: carts.current,
			category: carts.category,
			price: carts.price,
			location_lat: sql<
				number | null
			>`CAST(ST_Y(${carts.location}) AS DOUBLE PRECISION)`,
			location_lng: sql<
				number | null
			>`CAST(ST_X(${carts.location}) AS DOUBLE PRECISION)`,
			location_name: carts.location_name,
			created_at: carts.created_at,
			updated_at: carts.updated_at,
		})
		.from(carts)
		.where(eq(carts.id, id));

	notifyCartUpdated(groupId);
	return result;
};
