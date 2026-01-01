<img src="./.github/assets/icon.png" width="100" alt="Zay Chin" />

# FamCart - Family Shopping Cart App

A collaborative shopping cart application that allows family members to create groups, add items to shared carts, and track shopping locations on a map. [Live Demo Video](https://www.linkedin.com/feed/update/urn:li:activity:7412413027284652035/)

## Features

- 👥 **Group Management**: Create groups and invite family members
- 🛒 **Shared Shopping Carts**: Add, edit, and track items in real-time
- 📍 **Location Tracking**: Add locations to items and view them on a map
- 🔄 **Real-time Updates**: WebSocket-based real-time synchronization
- 🗺️ **Map View**: Visualize all item locations on an interactive map
- 📱 **Cross-platform**: Flutter app for iOS, Android

## Tech Stack

### Backend
- **Runtime**: Bun
- **Framework**: Fastify
- **Database**: PostgreSQL with PostGIS extension
- **ORM**: Drizzle ORM
- **Authentication**: JWT (RS256)
- **Real-time**: WebSocket

### Frontend
- **Framework**: Flutter
- **State Management**: Stream-based with real-time updates
- **HTTP Client**: Dio
- **Maps**: flutter_map with OpenStreetMap
- **Storage**: flutter_secure_storage

## Project Structure

```
FamCart/
├── backend/          # Fastify API server
│   ├── src/
│   │   ├── routes/   # API route handlers
│   │   ├── service/  # Business logic
│   │   ├── db/       # Database schema and connection
│   │   └── ...
│   └── drizzle/      # Database migrations
└── zay_chin/         # Flutter mobile app
    └── lib/
        ├── api/      # API client and services
        ├── screen/   # App screens
        └── widget/   # Reusable widgets
```

## Getting Started

### Prerequisites

- **Backend**:
  - Bun (v1.0+)
  - PostgreSQL (v14+) with PostGIS extension
  - Node.js (for some tooling)

- **Frontend**:
  - Flutter SDK (v3.10+)
  - Dart (v3.0+)

### Backend Setup

1. **Install dependencies**:
   ```bash
   cd backend
   bun install
   ```

2. **Set up environment variables**:
   Create a `.env` file in the `backend` directory:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/famcart
   JWT_PUBLIC_KEY_PATH=./keys/public.pem
   JWT_PRIVATE_KEY_PATH=./keys/private.pem
   ```

3. **Generate JWT keys** (if not already present):
   ```bash
   # Generate private key
   openssl genrsa -out keys/private.pem 2048
   
   # Generate public key
   openssl rsa -in keys/private.pem -pubout -out keys/public.pem
   ```

4. **Set up database**:
   ```bash
   # Create database with PostGIS extension
   createdb famcart
   psql famcart -c "CREATE EXTENSION IF NOT EXISTS postgis;"
   
   # Run migrations
   bun run drizzle-kit push
   ```

5. **Start the server**:
   ```bash
   bun run dev
   ```

   The server will start on `http://localhost:3000`

### Frontend Setup

1. **Install dependencies**:
   ```bash
   cd zay_chin
   flutter pub get
   ```

2. **Configure API endpoint**:
   Update `lib/api/config.dart` based on your environment:
   ```dart
   // For Android Emulator
   static const String baseUrl = 'http://10.0.2.2:3000';
   
   // For iOS Simulator
   static const String baseUrl = 'http://localhost:3000';
   
   // For Physical Device
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## API Documentation

Once the backend is running, API documentation is available at:
- Swagger UI: `http://localhost:3000/docs`

### Authentication

All API endpoints (except auth endpoints) require a Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

### WebSocket Connection

Real-time cart updates use WebSocket:
```
ws://localhost:3000/cart/ws?groupId=<group_id>&token=<access_token>
```

## Database Schema

### Key Tables

- **users**: User accounts
- **sessions**: User sessions
- **profiles**: User profiles (name, gender)
- **groups**: Shopping groups
- **group_members**: Group membership and roles
- **carts**: Shopping cart items with PostGIS geometry for locations
- **invitations**: Group invitations

### Location Storage

Locations are stored using PostGIS `geometry(Point, 4326)` type, which allows for:
- Efficient spatial queries
- Distance calculations
- Geographic indexing

The backend automatically converts between lat/lng coordinates and PostGIS geometry.

## Development

### Running Migrations

```bash
cd backend
bun run drizzle-kit generate  # Generate migration
bun run drizzle-kit push      # Apply migration
```

### Backend Scripts

```bash
bun run dev        # Start development server
bun run build      # Build for production
bun run start      # Start production server
```

### Flutter Scripts

```bash
flutter pub get    # Install dependencies
flutter run        # Run app
flutter build      # Build app
```

## Troubleshooting

### WebSocket Connection Issues

If you see "Route not found" errors for WebSocket:

1. Ensure the backend server is running
2. Check that the WebSocket route is registered before regular cart routes
3. Verify authentication token is valid
4. For Android, ensure you're using the correct IP address (not localhost)

### Database Connection Issues

1. Verify PostgreSQL is running
2. Check DATABASE_URL in `.env` file
3. Ensure PostGIS extension is installed: `CREATE EXTENSION postgis;`

### Type Casting Errors

If you encounter type casting errors with location coordinates:

1. Ensure database migrations are up to date
2. The backend uses `DOUBLE PRECISION` for location coordinates
3. Flutter model handles both string and number types gracefully

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[LICENSE](./LICENSE)

## Support

For issues and questions, please open an issue on GitHub.

