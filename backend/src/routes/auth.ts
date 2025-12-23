import type { FastifyPluginAsyncJsonSchemaToTs } from '@fastify/type-provider-json-schema-to-ts'

function createUser(email: string, password: string) {
    return { email }
}

const auth: FastifyPluginAsyncJsonSchemaToTs = async (app) => {
    app.route({
        method: 'POST',
        url: '/create',
        schema: {
            body: {
                type: 'object',
                properties: {
                    email: { type: 'string', format: 'email', maxLength: 255 },
                    password: { type: 'string', minLength: 8, maxLength: 255 }
                },
                required: ['email', 'password']
            }
        },
        handler: async (request, reply) => {
            const { email, password } = request.body
            const user = createUser(email, password)
            return { message: 'User created successfully', user }
        }
    })
}

export default auth
