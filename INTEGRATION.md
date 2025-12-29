# Backend-Frontend Integration Guide

This document describes how the backend and frontend are integrated.

## Backend Setup

The backend is a Fastify server running on port 3000 with the following features:
- JWT-based authentication with access tokens and refresh tokens
- CORS enabled for cross-origin requests
- API endpoints for auth, profile, groups, and cart

### Starting the Backend

```bash
cd backend
bun install
bun run dev
```

The server will start on `http://localhost:3000`

## Frontend Setup

The frontend is a Flutter application with the following features:
- HTTP client using Dio
- Secure token storage using flutter_secure_storage
- API service classes for all backend endpoints

### Installing Dependencies

```bash
cd zay_chin
flutter pub get
```

### API Configuration

Update the base URL in `lib/api/config.dart` based on your environment:

- **Android Emulator**: `http://10.0.2.2:3000`
- **iOS Simulator**: `http://localhost:3000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:3000` (e.g., `http://192.168.1.100:3000`)

### Running the Frontend

```bash
cd zay_chin
flutter run
```

## API Integration

### Authentication Flow

1. **Register**: `POST /auth/create`
   - Creates a new user account
   - Returns access token
   - Token is stored securely in the app

2. **Login**: `POST /auth/login`
   - Authenticates existing user
   - Returns access token
   - Token is stored securely in the app

3. **Session**: `GET /auth/session`
   - Gets current user information
   - Requires Bearer token authentication

4. **Refresh Token**: `GET /auth/refresh`
   - Refreshes access token using refresh token cookie
   - Note: Refresh tokens are stored as HTTP-only cookies, which may require additional handling on mobile

### API Services

The following services are available:

- `AuthService`: Authentication operations
- `ProfileService`: User profile management
- `GroupService`: Group and invitation management
- `CartService`: Shopping cart operations (to be implemented)

### Error Handling

All API services include error handling that:
- Catches Dio exceptions
- Extracts error messages from API responses
- Displays user-friendly error messages in the UI

## Current Implementation Status

✅ **Completed:**
- CORS configuration in backend
- API client setup with token management
- Authentication API integration (login/register)
- Error handling and validation
- Secure token storage

⚠️ **Notes:**
- Refresh token flow uses HTTP-only cookies, which may need adjustment for mobile apps
- Profile setup screen not yet integrated
- Home screen groups not yet connected to API
- Cart functionality not yet integrated

## Next Steps

1. Integrate profile setup screen
2. Connect home screen to fetch groups from API
3. Implement cart API integration
4. Add token refresh handling for mobile (if needed)
5. Add loading states and better error handling throughout

