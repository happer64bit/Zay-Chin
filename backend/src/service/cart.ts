import { eq, and, sql } from 'drizzle-orm';
import db from '../db';
import { carts } from '../db/schema';
import { notifyCartUpdated } from '../realtime';
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
    const inserted = await db
        .insert(carts)
        .values({
            group_id: groupId,
            item_name: data.item_name,
            category: data.category,
            price: data.price,
            quantity: data.quantity,
        })
        .returning();
    notifyCartUpdated(groupId);
    return inserted;
};

export const removeItem = async (groupId: string, id: string) => {
    const deleted = await db
        .delete(carts)
        .where(and(eq(carts.group_id, groupId), eq(carts.id, id)))
        .returning();

    notifyCartUpdated(groupId);
    return deleted;
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

    const updated = await db
        .update(carts)
        .set(data)
        .where(
            and(
                eq(carts.id, id),
                eq(carts.group_id, groupId),
            ),
        )
        .returning();
    notifyCartUpdated(groupId);
    return updated;
};
