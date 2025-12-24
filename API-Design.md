# API design

## Auth

`/auth` - **Auth Scope**

1. `/auth/login`
2. `/auth/create-user`
3. `/auth/session`
4. `/auth/logout`

## Group

1. `/group/` (GET)
2. `/group/create` (POST)
3. `/group/:id/` (GET)
4. `/group/:id/exit` (POST)
5. `/group/ws` (WebSocket)
6. `/group/:id/invite` (POST)
7. `/group/invites` (GET)
8. `/group/invites/accept/:id` (POST)

