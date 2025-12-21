-- Storage setup for Supabase
-- This migration sets up the storage schema and initial buckets

-- Enable storage extension (if not already enabled)
-- Note: Storage tables are typically created by the storage service itself
-- This migration creates initial buckets and policies

-- Create storage buckets (these will be created via API, but we can document them here)
-- Default public bucket for general files
-- You can create buckets via the Storage API or Supabase Studio

-- Example: Create a bucket for user uploads
-- This is typically done via API, but we'll create a script for it

-- Storage policies will be managed through RLS
-- The storage service handles the actual bucket creation

-- Note: To create buckets, use the Storage API:
-- POST /storage/v1/bucket
-- {
--   "name": "uploads",
--   "public": true,
--   "file_size_limit": 52428800,
--   "allowed_mime_types": ["image/*", "application/pdf"]
-- }

-- Or use the setup-storage.sh script

