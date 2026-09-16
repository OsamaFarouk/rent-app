-- Migration: New Account Architecture (Personal, Professional, Business)
-- Date: 2026-09-09

-- 1. Create public.business_profiles table if it does not exist
CREATE TABLE IF NOT EXISTS public.business_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  business_address TEXT,
  business_description TEXT,
  logo_url TEXT,
  phone TEXT,
  whatsapp TEXT,
  email TEXT,
  city TEXT DEFAULT 'Cairo',
  area TEXT,
  website_url TEXT,
  working_hours TEXT,
  approval_status TEXT DEFAULT 'approved',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT unique_business_profile_per_user UNIQUE (user_id)
);

-- 2. Add account_type column to public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS account_type TEXT;

-- 3. Populate account_type for existing records
UPDATE public.profiles p
SET account_type = CASE
  WHEN EXISTS (SELECT 1 FROM public.professional_profiles pro WHERE pro.profile_id = p.id) THEN 'professional'
  WHEN p.profile_type = 'business' THEN 'business'
  ELSE 'personal'
END
WHERE p.account_type IS NULL;

-- Ensure default and NOT NULL constraint for account_type
ALTER TABLE public.profiles ALTER COLUMN account_type SET DEFAULT 'personal';
UPDATE public.profiles SET account_type = 'personal' WHERE account_type IS NULL;
ALTER TABLE public.profiles ALTER COLUMN account_type SET NOT NULL;

-- Add CHECK constraint on account_type
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_account_type_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_account_type_check CHECK (account_type IN ('personal', 'professional', 'business'));

-- 4. Migrate existing business profiles from profiles table to business_profiles table
INSERT INTO public.business_profiles (
  user_id,
  business_name,
  business_address,
  business_description,
  website_url,
  working_hours,
  city,
  area,
  phone,
  whatsapp,
  email
)
SELECT 
  p.id AS user_id,
  COALESCE(p.business_name, p.full_name, 'Business') AS business_name,
  p.business_address,
  p.business_description,
  p.website_url,
  p.working_hours,
  p.city,
  p.area,
  p.phone,
  p.whatsapp,
  p.email
FROM public.profiles p
WHERE p.account_type = 'business'
ON CONFLICT (user_id) DO UPDATE SET
  business_name = EXCLUDED.business_name,
  business_address = EXCLUDED.business_address,
  business_description = EXCLUDED.business_description,
  website_url = EXCLUDED.website_url,
  working_hours = EXCLUDED.working_hours;

-- 5. Ensure UNIQUE constraint on professional_profiles.profile_id
ALTER TABLE public.professional_profiles DROP CONSTRAINT IF EXISTS unique_professional_profile_per_user;
ALTER TABLE public.professional_profiles ADD CONSTRAINT unique_professional_profile_per_user UNIQUE (profile_id);

-- 6. Trigger to enforce account_type = 'professional' for professional_profiles
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

DROP TRIGGER IF EXISTS trg_check_professional_profile_account_type ON public.professional_profiles;
CREATE TRIGGER trg_check_professional_profile_account_type
  BEFORE INSERT OR UPDATE ON public.professional_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.check_professional_profile_account_type();

-- 7. Trigger to enforce account_type = 'business' for business_profiles
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

DROP TRIGGER IF EXISTS trg_check_business_profile_account_type ON public.business_profiles;
CREATE TRIGGER trg_check_business_profile_account_type
  BEFORE INSERT OR UPDATE ON public.business_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.check_business_profile_account_type();

-- 8. Update handle_new_user() function for auth user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, profile_photo, account_type)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_user_meta_data->>'account_type', 'personal')
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. RLS Policies for business_profiles
ALTER TABLE public.business_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read business profiles" ON public.business_profiles;
CREATE POLICY "Public read business profiles" ON public.business_profiles
  FOR SELECT TO public
  USING (is_active = true OR (auth.uid() IS NOT NULL AND (user_id = auth.uid() OR private.has_moderation_role())));

DROP POLICY IF EXISTS "Business owners insert own business profile" ON public.business_profiles;
CREATE POLICY "Business owners insert own business profile" ON public.business_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND account_type = 'business')
  );

DROP POLICY IF EXISTS "Business owners update own business profile" ON public.business_profiles;
CREATE POLICY "Business owners update own business profile" ON public.business_profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id OR private.has_moderation_role())
  WITH CHECK (auth.uid() = user_id OR private.has_moderation_role());

DROP POLICY IF EXISTS "Business owners delete own business profile" ON public.business_profiles;
CREATE POLICY "Business owners delete own business profile" ON public.business_profiles
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR private.has_moderation_role());

-- 10. Update professional_profiles RLS INSERT policy
DROP POLICY IF EXISTS "LoggedIn providers insert own professional profile" ON public.professional_profiles;
CREATE POLICY "LoggedIn professionals insert own professional profile" ON public.professional_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = profile_id AND 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND account_type = 'professional')
  );
