import db from '../db';
import {
    groups,
    groupMembers,
    invitations,
    users,
    profiles,
} from '../db/schema';
import { eq, and, inArray, sql } from 'drizzle-orm';
import { UnauthorizedAccess } from '../errors';

export const getGroupsForProfile = async (profileId: string) => {
    const memberships = await db.query.groupMembers.findMany({
        where: eq(groupMembers.profile_id, profileId),
    });

    const groupIds = memberships.map((m) => m.group_id);
    if (groupIds.length === 0) return [];

    const groupList = await db.query.groups.findMany({
        where: inArray(groups.id, groupIds),
    });
    return groupList || [];
};

export const getGroupById = async (groupId: string, profileId: string) => {
    const membership = await db.query.groupMembers.findFirst({
        where: and(
            eq(groupMembers.group_id, groupId),
            eq(groupMembers.profile_id, profileId),
        ),
    });
    if (!membership) throw new Error('Access denied');

    const group = await db.query.groups.findFirst({
        where: eq(groups.id, groupId),
    });
    if (!group) throw new Error('Group not found');

    return group;
};

export const createGroup = async (name: string, profileId: string) => {
    const [group] = await db
        .insert(groups)
        .values({
            name,
            total_members: 1,
        })
        .returning();

    if (!group) throw new Error('Failed to create group');

    await db
        .insert(groupMembers)
        .values({
            group_id: group.id,
            profile_id: profileId,
            role: 'admin',
        })
        .returning();

    return group;
};

export const inviteToGroup = async (
    groupId: string,
    email: string,
    inviterProfileId: string,
) => {
    const inviterMembership = await db.query.groupMembers.findFirst({
        where: and(
            eq(groupMembers.group_id, groupId),
            eq(groupMembers.profile_id, inviterProfileId),
            eq(groupMembers.role, 'admin'),
        ),
    });
    if (!inviterMembership) throw new Error('Only admins can invite');

    const user = await db.query.users.findFirst({
        where: eq(users.email, email),
    });
    if (!user) throw new Error('User not found');

    const invitee = await db.query.profiles.findFirst({
        where: eq(profiles.user_id, user.id),
    });
    if (!invitee) throw new Error('Invitee profile not found');

    const existingMember = await db.query.groupMembers.findFirst({
        where: and(
            eq(groupMembers.group_id, groupId),
            eq(groupMembers.profile_id, invitee.id),
        ),
    });
    if (existingMember) throw new Error('User already a member');

    const existingInvitation = await db.query.invitations.findFirst({
        where: and(
            eq(invitations.group_id, groupId),
            eq(invitations.invited_profile_id, invitee.id),
            eq(invitations.status, 'pending'),
        ),
    });
    if (existingInvitation) throw new Error('Invitation already pending');

    const [invitation] = await db
        .insert(invitations)
        .values({
            group_id: groupId,
            invited_profile_id: invitee.id,
            invited_by_profile_id: inviterProfileId,
            status: 'pending',
        })
        .returning();

    return invitation;
};

export const acceptInvitation = async (inviteId: string, profileId: string) => {
    const invitation = await db.query.invitations.findFirst({
        where: eq(invitations.id, inviteId),
    });
    if (!invitation) throw new Error('Invitation not found');
    if (invitation.invited_profile_id !== profileId)
        throw new Error('Access denied');
    if (invitation.status !== 'pending')
        throw new Error('Invitation already processed');

    const [member] = await db
        .insert(groupMembers)
        .values({
            group_id: invitation.group_id,
            profile_id: profileId,
            role: 'member',
        })
        .returning();

    if (!member) throw new Error('Failed to add member');

    await db
        .update(groups)
        .set({ total_members: sql`${groups.total_members} + 1` })
        .where(eq(groups.id, invitation.group_id));

    await db
        .update(invitations)
        .set({ status: 'accepted' })
        .where(eq(invitations.id, inviteId));

    return db.query.groups.findFirst({
        where: eq(groups.id, invitation.group_id),
    });
};

export const rejectInvitation = async (inviteId: string, profileId: string) => {
    const invitation = await db.query.invitations.findFirst({
        where: eq(invitations.id, inviteId),
    });
    if (!invitation) throw new Error('Invitation not found');
    if (invitation.invited_profile_id !== profileId)
        throw new Error('Access denied');
    if (invitation.status !== 'pending')
        throw new Error('Invitation already processed');

    await db
        .update(invitations)
        .set({ status: 'rejected' })
        .where(eq(invitations.id, inviteId));
    return true;
};
