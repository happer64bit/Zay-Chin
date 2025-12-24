import { makeExecutableSchema } from '@graphql-tools/schema';
import { merge } from 'lodash';

import * as helloWorld from './schemas/hello-world';
import * as profile from './schemas/profile';

import * as authDirective from './directive/auth';

export const schema = authDirective.transformer(
    makeExecutableSchema({
        typeDefs: [
            authDirective.typeDefs,
            helloWorld.typeDefs,
            profile.typeDefs,
        ],
        resolvers: merge(helloWorld.resolvers, profile.resolvers),
    })
);
