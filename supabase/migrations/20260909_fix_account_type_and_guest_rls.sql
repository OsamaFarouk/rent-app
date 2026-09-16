-- Migration: Fix Account Type Selection & Guest RLS Permissions
-- Date: 2026-09-09

-- 1. Remove automatic 'personal' assignment from profiles.account_type column
ALTER TABLE public.profiles ALTER COLUMN account_type DROP DEFAULT;
ALTER TABLE public.profiles ALTER COLUMN account_type DROP NOT NULL;

-- 2. Update handle_new_user() trigger function so it does NOT default account_type to 'personal'
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
    NEW.raw_user_meta_data->>'account_type'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  RETURN NEW;
END;
$function$;

-- 3. Grant execute on private.has_moderation_role() to public (anon & authenticated)
GRANT EXECUTE ON FUNCTION private.has_moderation_role() TO public;

-- 4. Update Business Profiles SELECT policy to enforce approved & active status for public
DROP POLICY IF EXISTS "Public read business profiles" ON public.business_profiles;
CREATE POLICY "Public read business profiles" ON public.business_profiles
FOR SELECT TO public
USING (
  (approval_status = 'approved'::text AND is_active = true)
  OR (auth.uid() IS NOT NULL AND (user_id = auth.uid() OR private.has_moderation_role()))
);

-- 5. Update Equipment SELECT policy to enforce approved status and active owner profile for public
DROP POLICY IF EXISTS "Public read approved equipment" ON public.equipment;
CREATE POLICY "Public read approved equipment" ON public.equipment
FOR SELECT TO public
USING (
  (approval_status = 'approved'::text AND EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = equipment.owner_id AND p.is_active = true
  ))
  OR (auth.uid() IS NOT NULL AND (owner_id = auth.uid() OR private.has_moderation_role()))
);

-- 6. Update Equipment Images SELECT policy for public read access
DROP POLICY IF EXISTS "Public read equipment images" ON public.equipment_images;
CREATE POLICY "Public read equipment images" ON public.equipment_images
FOR SELECT TO public
USING (
  EXISTS (
    SELECT 1 FROM public.equipment e
    WHERE e.id = equipment_images.equipment_id
    AND (
      (e.approval_status = 'approved'::text AND EXISTS (
        SELECT 1 FROM public.profiles p WHERE p.id = e.owner_id AND p.is_active = true
      ))
      OR (auth.uid() IS NOT NULL AND (e.owner_id = auth.uid() OR private.has_moderation_role()))
    )
  )
);

-- 7. Update profiles table check constraints to allow personal, professional, and business account types
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_profile_type_check;
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_business_name_check;

ALTER TABLE public.profiles ADD CONSTRAINT profiles_profile_type_check 
  CHECK (profile_type IS NULL OR profile_type IN ('individual', 'personal', 'professional', 'business'));

ALTER TABLE public.profiles ADD CONSTRAINT profiles_business_name_check 
  CHECK (
    profile_type IS NULL 
    OR profile_type IN ('individual', 'personal', 'professional') 
    OR (
      (profile_type = 'business' OR account_type = 'business') 
      AND business_name IS NOT NULL 
      AND trim(business_name) <> ''
    )
    OR (account_type IS DISTINCT FROM 'business' AND (profile_type IS DISTINCT FROM 'business'))
  );

