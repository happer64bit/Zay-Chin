import type { IResolvers } from '@graphql-tools/utils';
import type { BaseContext } from '../context';

export const typeDefs = /** GraphQL */ `
    type Query {
        add: Int
    }
`;

export const resolvers: IResolvers<unknown, BaseContext> = {
    Query: {
        add: () => 12,
    },
};
