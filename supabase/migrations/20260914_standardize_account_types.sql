-- Migration: Standardize account types to 'user', 'professional', 'business'
-- Date: 2026-09-14

-- 1. Drop old constraint first to allow updating values to 'user'
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_account_type_check;

-- 2. Update existing account_type values in public.profiles table
UPDATE public.profiles
SET account_type = 'user'
WHERE account_type IN ('personal', 'individual') OR account_type IS NULL;

-- 3. Add updated check constraint on public.profiles.account_type
ALTER TABLE public.profiles ADD CONSTRAINT profiles_account_type_check
  CHECK (account_type IN ('user', 'professional', 'business'));

-- 4. Update handle_new_user() trigger function to store account_type from user metadata or default to 'user'
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, profile_photo, account_type)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_user_meta_data->>'account_type', 'user')
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    account_type = COALESCE(EXCLUDED.account_type, profiles.account_type),
    updated_at = NOW();
  RETURN NEW;
END;
$function$;

-- 5. Update check_professional_profile_account_type trigger function
CREATE OR REPLACE FUNCTION public.check_professional_profile_account_type()
RETURNS TRIGGER AS $$
DECLARE
  v_account_type TEXT;
BEGIN
  SELECT account_type INTO v_account_type
  FROM public.profiles
  WHERE id = NEW.profile_id;

  IF v_account_type IS DISTINCT FROM 'professional' THEN
    RAISE EXCEPTION 'Only accounts with account_type = ''professional'' can create or manage a professional profile.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Update check_business_profile_account_type trigger function
CREATE OR REPLACE FUNCTION public.check_business_profile_account_type()
RETURNS TRIGGER AS $$
DECLARE
  v_account_type TEXT;
BEGIN
  SELECT account_type INTO v_account_type
  FROM public.profiles
  WHERE id = NEW.user_id;

  IF v_account_type IS DISTINCT FROM 'business' THEN
    RAISE EXCEPTION 'Only accounts with account_type = ''business'' can create or manage a business profile.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
