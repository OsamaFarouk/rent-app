-- Rental-house cover image, separate from the business logo.
ALTER TABLE public.business_profiles ADD COLUMN IF NOT EXISTS cover_image_url text;
