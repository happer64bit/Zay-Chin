import { relations } from 'drizzle-orm';
import {
    integer,
    pgTable,
    timestamp,
    uuid,
    varchar,
} from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
    id: uuid('id').primaryKey().defaultRandom(),
    email: varchar('username', { length: 255 }).notNull().unique(),
    password: varchar('password', { length: 255 }).notNull(),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

export const sessions = pgTable('sessions', {
    id: uuid('id').primaryKey().defaultRandom(),
    user_id: uuid('user_id')
        .notNull()
        .references(() => users.id, { onDelete: 'cascade' }),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

export const profiles = pgTable('profiles', {
    id: uuid('id').primaryKey().defaultRandom(),
    user_id: uuid('user_id')
        .notNull()
        .references(() => users.id, { onDelete: 'cascade' }),
    name: varchar('first_name', { length: 100 }).notNull(),
    gender: varchar('gender', { length: 50 })
        .$type<'male' | 'female' | 'other'>()
        .notNull(),
    created_at: timestamp('created_at').defaultNow().notNull(),
    updated_at: timestamp('updated_at')
        .defaultNow()
        .notNull()
        .$onUpdate(() => new Date()),
});

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

export const groupMembers = pgTable('group_members', {
    id: uuid('id').primaryKey().defaultRandom(),
    group_id: uuid('group_id')
        .notNull()
        .references(() => groups.id, { onDelete: 'cascade' }),
    profile_id: uuid('profile_id')
        .notNull()
        .references(() => profiles.id, { onDelete: 'cascade' }),
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
    user: one(users, {
        fields: [sessions.user_id],
        references: [users.id],
    }),
}));

export const profilesRelations = relations(profiles, ({ one, many }) => ({
    user: one(users, {
        fields: [profiles.user_id],
        references: [users.id],
    }),
    groupMembers: many(groupMembers),
}));

export const groupsRelations = relations(groups, ({ many }) => ({
    members: many(groupMembers),
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
