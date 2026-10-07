-- Rent App Migration: Update professional_profiles_approval_status_check constraint to allow 'draft'
-- Date: 2026-09-23

ALTER TABLE public.professional_profiles DROP CONSTRAINT IF EXISTS professional_profiles_approval_status_check;

ALTER TABLE public.professional_profiles ADD CONSTRAINT professional_profiles_approval_status_check 
  CHECK (approval_status = ANY (ARRAY['draft'::text, 'pending'::text, 'approved'::text, 'rejected'::text, 'suspended'::text]));
