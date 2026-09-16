-- Rent App Migration: Make profile_type nullable and remove DEFAULT 'individual'
-- Date: 2026-08-26

ALTER TABLE public.profiles ALTER COLUMN profile_type DROP DEFAULT;
ALTER TABLE public.profiles ALTER COLUMN profile_type DROP NOT NULL;

-- Update constraint to allow NULL as well as 'individual' and 'business'
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_profile_type_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_profile_type_check 
  CHECK (profile_type IS NULL OR profile_type IN ('individual', 'business'));
