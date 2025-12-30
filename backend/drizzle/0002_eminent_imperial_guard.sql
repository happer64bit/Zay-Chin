-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;--> statement-breakpoint
-- Add new location geometry column
ALTER TABLE "carts" ADD COLUMN IF NOT EXISTS "location" geometry(Point, 4326);--> statement-breakpoint
-- Migrate existing location_lat/location_lng data to geometry
UPDATE "carts"
SET "location" = ST_SetSRID(ST_MakePoint("location_lng"::double precision, "location_lat"::double precision), 4326)
WHERE "location_lat" IS NOT NULL AND "location_lng" IS NOT NULL;--> statement-breakpoint
-- Drop old location columns
ALTER TABLE "carts" DROP COLUMN IF EXISTS "location_lat";--> statement-breakpoint
ALTER TABLE "carts" DROP COLUMN IF EXISTS "location_lng";