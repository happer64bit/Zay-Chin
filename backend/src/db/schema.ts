import { relations, sql } from 'drizzle-orm';
import {
    integer,
    pgTable,
    timestamp,
    uuid,
    varchar,
    index,
    customType,
} from 'drizzle-orm/pg-core';

// PostGIS geometry type for Point (SRID 4326)
// We'll store it as text and use SQL functions to convert
const geometry = customType<{ data: string | null; driverData: string | null }>({
    dataType: () => 'geometry(Point, 4326)',
    toDriver: (value) => value,
    fromDriver: (value) => value,
});

export const users = pgTable('users', {
    id: uuid('id').primaryKey().defaultRandom(),
    email: varchar('email', { length: 255 }).notNull().unique(),
    password: varchar('password', { length: 255 }).notNull(),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

export const sessions = pgTable(
    'sessions',
    {
        id: uuid('id').primaryKey().defaultRandom(),
        user_id: uuid('user_id')
            .notNull()
            .references(() => users.id, { onDelete: 'cascade' }),
        created_at: timestamp('created_at').defaultNow().notNull(),
        updated_at: timestamp('updated_at')
            .defaultNow()
            .notNull()
            .$onUpdate(() => new Date()),
    },
    (t) => [index('sessions_user_id_idx').on(t.user_id)],
);

export const profiles = pgTable(
    'profiles',
    {
        id: uuid('id').primaryKey().defaultRandom(),
        user_id: uuid('user_id')
            .notNull()
            .references(() => users.id, { onDelete: 'cascade' }),
        name: varchar('name', { length: 100 }).notNull(),
        gender: varchar('gender', { length: 50 })
            .$type<'male' | 'female' | 'other'>()
            .notNull(),
        created_at: timestamp('created_at').defaultNow().notNull(),
        updated_at: timestamp('updated_at')
            .defaultNow()
            .notNull()
            .$onUpdate(() => new Date()),
    },
    (t) => [index('profiles_user_id_idx').on(t.user_id)],
);

export const groups = pgTable('groups', {
    id: uuid('id').primaryKey().defaultRandom(),
    name: varchar('name', { length: 100 }).notNull(),
    total_members: integer('total_members').notNull().default(1),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

// export const categories = pgTable('categories', {
//     name: varchar('name', { length: 100 }).primaryKey(),
//     created_at: timestamp('created_at').defaultNow().notNull(),
// });

export const carts = pgTable(
    'carts',
    {
        id: uuid('id').primaryKey().defaultRandom(),
        group_id: uuid('group_id')
            .notNull()
            .references(() => groups.id, { onDelete: 'cascade' }),
        item_name: varchar('item_name', { length: 255 }).notNull(),
        quantity: integer('quantity').notNull().default(1),
        current: integer('current').notNull().default(0),
        category: varchar('category', { length: 100 })
            .notNull(),
            // .references(() => categories.name),
        price: integer('price').notNull().default(0),
        location: geometry('location'),
        location_name: varchar('location_name', { length: 255 }),
        created_at: timestamp('created_at').defaultNow().notNull(),
        updated_at: timestamp('updated_at')
            .defaultNow()
            .notNull()
            .$onUpdate(() => new Date()),
    },
    (t) => [
        index('carts_group_id_idx').on(t.group_id),
        index('carts_category_idx').on(t.category),
        index('carts_group_item_unique').on(t.group_id, t.item_name),
    ],
);

export const groupMembers = pgTable(
    'group_members',
    {
        id: uuid('id').primaryKey().defaultRandom(),
        group_id: uuid('group_id')
            .notNull()
            .references(() => groups.id, { onDelete: 'cascade' }),
        profile_id: uuid('profile_id')
            .notNull()
            .references(() => profiles.id, { onDelete: 'cascade' }),
        role: varchar('role', { length: 20 })
            .$type<'admin' | 'member'>()
            .notNull()
            .default('member'),
        created_at: timestamp('created_at').defaultNow().notNull(),
        updated_at: timestamp('updated_at')
            .defaultNow()
            .notNull()
            .$onUpdate(() => new Date()),
    },
    (t) => [index('group_members_unique').on(t.group_id, t.profile_id)],
);

export const invitations = pgTable('invitations', {
    id: uuid('id').primaryKey().defaultRandom(),
    group_id: uuid('group_id')
        .notNull()
        .references(() => groups.id, { onDelete: 'cascade' }),
    invited_profile_id: uuid('invited_profile_id')
        .notNull()
        .references(() => profiles.id, { onDelete: 'cascade' }),
    invited_by_profile_id: uuid('invited_by_profile_id')
        .notNull()
        .references(() => profiles.id, { onDelete: 'cascade' }),
    status: varchar('status', { length: 20 })
        .$type<'pending' | 'accepted' | 'rejected'>()
        .notNull()
        .default('pending'),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

export const usersRelations = relations(users, ({ one, many }) => ({
    profile: one(profiles),
    sessions: many(sessions),
}));

export const sessionsRelations = relations(sessions, ({ one }) => ({
    user: one(users, { fields: [sessions.user_id], references: [users.id] }),
}));

export const profilesRelations = relations(profiles, ({ one, many }) => ({
    user: one(users, { fields: [profiles.user_id], references: [users.id] }),
    groupMembers: many(groupMembers),
    receivedInvitations: many(invitations, { relationName: 'invitedProfile' }),
    sentInvitations: many(invitations, { relationName: 'invitedBy' }),
}));

export const groupsRelations = relations(groups, ({ many }) => ({
    members: many(groupMembers),
    carts: many(carts),
}));

// export const categoriesRelations = relations(categories, ({ many }) => ({
//     carts: many(carts),
// }));

export const cartsRelations = relations(carts, ({ one }) => ({
    group: one(groups, { fields: [carts.group_id], references: [groups.id] }),
}));

export const groupMembersRelations = relations(groupMembers, ({ one }) => ({
    group: one(groups, {
        fields: [groupMembers.group_id],
        references: [groups.id],
    }),
    profile: one(profiles, {
        fields: [groupMembers.profile_id],
        references: [profiles.id],
    }),
}));

export const invitationsRelations = relations(invitations, ({ one }) => ({
    group: one(groups, {
        fields: [invitations.group_id],
        references: [groups.id],
    }),
    invitedProfile: one(profiles, {
        fields: [invitations.invited_profile_id],
        references: [profiles.id],
    }),
    invitedBy: one(profiles, {
        fields: [invitations.invited_by_profile_id],
        references: [profiles.id],
    }),
}));
