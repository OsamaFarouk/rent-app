-- Rent App Migration: Add Business Profile Fields and Check Constraint to public.profiles
-- Date: 2026-08-26

-- 1. Create all business columns if they do not exist:
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS business_name TEXT,
ADD COLUMN IF NOT EXISTS business_address TEXT,
ADD COLUMN IF NOT EXISTS business_description TEXT,
ADD COLUMN IF NOT EXISTS website_url TEXT,
ADD COLUMN IF NOT EXISTS working_hours TEXT;

-- 2. Populate business_name for any existing business rows where business_name is missing:
UPDATE public.profiles
SET business_name = COALESCE(NULLIF(TRIM(full_name), ''), 'Business')
WHERE profile_type = 'business' AND (business_name IS NULL OR TRIM(business_name) = '');

-- 3. Add constraint requiring business_name for Business profiles:
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_business_name_check;

ALTER TABLE public.profiles ADD CONSTRAINT profiles_business_name_check 
  CHECK (
    profile_type IS NULL 
    OR profile_type = 'individual' 
    OR (profile_type = 'business' AND business_name IS NOT NULL AND TRIM(business_name) <> '')
  );
