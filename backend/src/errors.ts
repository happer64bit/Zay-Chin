import createError from '@fastify/error';

export const UserDoesNotExists = createError(
    'USER_DOES_NOT_EXIST',
    'User does not exist',
    404,
);

export const InvalidCredentials = createError(
    'INVALID_CREDENTIALS',
    'Invalid email or password',
    401,
);

export const UserAlreadyExists = createError(
    'USER_ALREADY_EXISTS',
    'User with this email already exists',
    409,
);

export const UnauthorizedAccess = createError(
    'UNAUTHORIZED_ACCESS',
    'Unauthorized access',
    403,
);
