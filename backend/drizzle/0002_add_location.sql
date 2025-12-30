-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add optional location columns to carts
ALTER TABLE "carts"
    ADD COLUMN IF NOT EXISTS "location_lat" NUMERIC(9,6),
    ADD COLUMN IF NOT EXISTS "location_lng" NUMERIC(9,6),
    ADD COLUMN IF NOT EXISTS "location_name" VARCHAR(255);

-- Optional: add a computed geography point for future use
-- ALTER TABLE "carts" ADD COLUMN IF NOT EXISTS "location" geography(POINT, 4326);
-- You can populate it like:
-- UPDATE "carts"
-- SET "location" = ST_SetSRID(ST_MakePoint("location_lng"::double precision, "location_lat"::double precision), 4326)::geography
-- WHERE "location_lat" IS NOT NULL AND "location_lng" IS NOT NULL;
