-- Rent App Migration: Fix RLS SELECT policy on public.profiles to allow users to read their own profile row when is_active = false
-- Date: 2026-08-26

DROP POLICY IF EXISTS "Public read active profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users read own profile or active profiles" ON public.profiles;

CREATE POLICY "Users read own profile or active profiles"
  ON public.profiles FOR SELECT
  USING (
    is_active = true 
    OR (auth.uid() IS NOT NULL AND auth.uid() = id) 
    OR private.has_moderation_role()
  );
