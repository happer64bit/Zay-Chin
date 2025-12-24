import type { IResolvers } from '@graphql-tools/utils';
import type { AuthContext, BaseContext } from '../context';

export const typeDefs = /** GraphQL */ `
    type Profile {
        name: String
        is_completed: Boolean
    }

    type Query {
        profile: Profile @auth
    }
`;

export const resolvers: IResolvers<unknown, BaseContext> = {
    Query: {
        profile: (ctx: AuthContext) => {
            return {
                name: ctx.user_id,
                is_completed: true,
            }
        },
    },
};
