import { AuthenticationError } from 'apollo-server-errors';
import { defaultFieldResolver, GraphQLObjectType, GraphQLSchema } from 'graphql';
import { mapSchema, getDirective, MapperKind } from '@graphql-tools/utils';
import { Context } from '../context';

const directiveName = 'auth';

export const typeDefs = /* GraphQL */ `
  directive @${directiveName} on OBJECT | FIELD_DEFINITION
`;

export const transformer = (schema: GraphQLSchema): GraphQLSchema =>
    mapSchema(schema, {
        [MapperKind.OBJECT_FIELD]: (fieldConfig) => {
            const directive = getDirective(schema, fieldConfig, directiveName)?.[0];
            if (!directive) return fieldConfig;

            const { resolve = defaultFieldResolver } = fieldConfig;
            fieldConfig.resolve = (source, args, ctx: Context, info) => {
                if (!ctx.user_id) throw new AuthenticationError('Access denied!');
                return resolve(source, args, ctx, info);
            };
            return fieldConfig;
        },
    });
