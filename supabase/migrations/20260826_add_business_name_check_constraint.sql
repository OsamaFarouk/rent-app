-- Rent App Migration: Add check constraint for business_name when profile_type is 'business'
-- Date: 2026-08-26

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_business_name_check;

ALTER TABLE public.profiles ADD CONSTRAINT profiles_business_name_check 
  CHECK (
    profile_type IS NULL 
    OR profile_type = 'individual' 
    OR (profile_type = 'business' AND business_name IS NOT NULL AND TRIM(business_name) <> '')
  );
