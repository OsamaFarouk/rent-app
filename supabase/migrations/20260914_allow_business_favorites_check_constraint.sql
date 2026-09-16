-- Migration to allow 'business' in favorites target_type check constraint
ALTER TABLE public.favorites DROP CONSTRAINT IF EXISTS favorites_target_type_check;
ALTER TABLE public.favorites ADD CONSTRAINT favorites_target_type_check CHECK (target_type IN ('equipment', 'professional', 'business'));
