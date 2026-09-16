-- Rent App Migration: Add profile_setup_completed flag to public.profiles
-- Date: 2026-08-25

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS profile_setup_completed BOOLEAN NOT NULL DEFAULT FALSE;
