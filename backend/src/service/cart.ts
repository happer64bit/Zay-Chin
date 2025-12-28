import { eq, and, sql } from 'drizzle-orm';
import db from '../db';
import { carts } from '../db/schema';
import { UnauthorizedAccess } from '../errors';

export const assertGroupMember = async (groupId: string, profileId: string) => {
    const member = await db.query.groupMembers.findFirst({
        where: (f, op) =>
            op.and(eq(f.group_id, groupId), eq(f.profile_id, profileId)),
    });

    if (!member) throw new UnauthorizedAccess('Not a group member');
    return member;
};

export const getCart = async (groupId: string) => {
    return db.select().from(carts).where(eq(carts.group_id, groupId));
};

export const addOrUpdateItem = async (
    groupId: string,
    data: {
        item_name: string;
        category: string;
        price: number;
        quantity: number;
    },
) => {
    const existing = await db.query.carts.findFirst({
        where: (fields, op) =>
            op.and(
                eq(fields.group_id, groupId),
                eq(fields.item_name, data.item_name),
            ),
    });

    if (existing) {
        return db
            .update(carts)
            .set({
                quantity: sql`${carts.quantity} + ${data.quantity}`,
                price: data.price,
                category: data.category,
            })
            .where(eq(carts.id, existing.id))
            .returning();
    }

    return db
        .insert(carts)
        .values({
            group_id: groupId,
            item_name: data.item_name,
            category: data.category,
            price: data.price,
            quantity: data.quantity,
        })
        .returning();
};

export const removeItem = async (groupId: string, id: string) => {
    return db
        .delete(carts)
        .where(and(eq(carts.group_id, groupId), eq(carts.item_name, id)))
        .returning();
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
    }>,
) => {
    if (data.current !== undefined || data.quantity !== undefined) {
        const existing = await db.query.carts.findFirst({
            where: (f, op) =>
                op.and(
                    eq(f.id, id),
                    eq(f.group_id, groupId),
                ),
        });

        if (!existing) throw new UnauthorizedAccess();

        const nextQty = data.quantity ?? existing.quantity;
        const nextCurrent = data.current ?? existing.current;

        if (nextCurrent > nextQty)
            throw new UnauthorizedAccess('Current cannot exceed quantity');
    }

    return db
        .update(carts)
        .set(data)
        .where(
            and(
                eq(carts.id, id),
                eq(carts.group_id, groupId),
            ),
        )
        .returning();
};
