-- Rent App Initial PostgreSQL Schema Migration (Final Private Schema Hardened + Avatars Storage)
-- Project: Rent App Discovery Marketplace
-- Date: 2026-08-25

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- 1. PRIVATE SCHEMA & HELPER FUNCTIONS
-- ==========================================

-- Private schema for internal system functions (hidden from PostgREST API)
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

-- Function to handle updated_at timestamps automatically
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Function to handle automated profile creation on auth.users registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, profile_photo)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- ==========================================
-- 2. TABLE DEFINITIONS
-- ==========================================

-- 2.1 PROFILES (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  profile_photo TEXT,
  phone TEXT,
  whatsapp TEXT,
  email TEXT,
  city TEXT DEFAULT 'Cairo',
  area TEXT,
  profile_type TEXT CHECK (profile_type IS NULL OR profile_type IN ('individual', 'business')),
  business_name TEXT,
  business_address TEXT,
  business_description TEXT,
  website_url TEXT,
  working_hours TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger for auth.users profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger for updated_at on profiles
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 2.2 USER ROLES (Secure Admin & Moderator Authorization)
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_user_role UNIQUE (user_id, role)
);

-- Hardened SECURITY DEFINER Function in Private Schema
CREATE OR REPLACE FUNCTION private.has_moderation_role()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN EXISTS (
    SELECT 1 
    FROM public.user_roles
    WHERE user_roles.user_id = v_user_id
      AND user_roles.role IN ('admin', 'moderator')
  );
END;
$$;

-- Strict Execution Rights: Only authenticated users (never anon/public)
REVOKE ALL ON FUNCTION private.has_moderation_role() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION private.has_moderation_role() TO authenticated;

-- 2.3 CATEGORIES
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  category_type TEXT NOT NULL CHECK (category_type IN ('equipment', 'professional')),
  icon_name TEXT,
  image_url TEXT,
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.4 EQUIPMENT
CREATE TABLE IF NOT EXISTS public.equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  description TEXT,
  daily_price NUMERIC(10, 2) NOT NULL,
  weekly_price NUMERIC(10, 2),
  pricing_type TEXT DEFAULT 'per_day',
  condition TEXT,
  accessories TEXT,
  city TEXT DEFAULT 'Cairo',
  area TEXT,
  availability_status TEXT DEFAULT 'available_now' CHECK (availability_status IN ('available_now', 'available_tomorrow', 'busy', 'unavailable')),
  approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_equipment_updated_at ON public.equipment;
CREATE TRIGGER set_equipment_updated_at
  BEFORE UPDATE ON public.equipment
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 2.5 EQUIPMENT IMAGES
CREATE TABLE IF NOT EXISTS public.equipment_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  equipment_id UUID NOT NULL REFERENCES public.equipment(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  display_order INT DEFAULT 0,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.6 PROFESSIONAL PROFILES
CREATE TABLE IF NOT EXISTS public.professional_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  professional_title TEXT NOT NULL,
  bio TEXT,
  years_of_experience INT DEFAULT 0,
  experience_level TEXT,
  starting_price NUMERIC(10, 2),
  pricing_type TEXT DEFAULT 'per_day',
  willing_to_travel BOOLEAN DEFAULT false,
  linkedin_url TEXT,
  instagram_url TEXT,
  behance_url TEXT,
  vimeo_url TEXT,
  youtube_url TEXT,
  website_url TEXT,
  approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_professional_profiles_updated_at ON public.professional_profiles;
CREATE TRIGGER set_professional_profiles_updated_at
  BEFORE UPDATE ON public.professional_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 2.7 PORTFOLIO ITEMS
CREATE TABLE IF NOT EXISTS public.portfolio_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_profile_id UUID NOT NULL REFERENCES public.professional_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  media_url TEXT,
  media_type TEXT DEFAULT 'image' CHECK (media_type IN ('image', 'video')),
  external_url TEXT,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.8 FAVORITES (Unique constraint prevents duplicates)
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('equipment', 'professional')),
  target_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_user_favorite UNIQUE (user_id, target_type, target_id)
);

-- 2.9 REPORTS
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('equipment', 'professional')),
  target_id UUID NOT NULL,
  report_reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.10 APPROVAL HISTORY
CREATE TABLE IF NOT EXISTS public.approval_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type TEXT NOT NULL CHECK (target_type IN ('equipment', 'professional')),
  target_id UUID NOT NULL,
  admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  decision TEXT NOT NULL CHECK (decision IN ('approved', 'rejected', 'suspended')),
  comments TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2.11 CONTACT EVENTS
CREATE TABLE IF NOT EXISTS public.contact_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('equipment', 'professional')),
  target_id UUID NOT NULL,
  contact_type TEXT NOT NULL CHECK (contact_type IN ('phone', 'whatsapp', 'email', 'directions', 'linkedin', 'instagram', 'behance', 'vimeo', 'youtube', 'website')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. INDEXES FOR HIGH-PERFORMANCE LOOKUPS
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_user_roles_user ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON public.user_roles(role);

CREATE INDEX IF NOT EXISTS idx_equipment_owner ON public.equipment(owner_id);
CREATE INDEX IF NOT EXISTS idx_equipment_category ON public.equipment(category_id);
CREATE INDEX IF NOT EXISTS idx_equipment_approval ON public.equipment(approval_status);
CREATE INDEX IF NOT EXISTS idx_equipment_city ON public.equipment(city);

CREATE INDEX IF NOT EXISTS idx_equipment_images_equip ON public.equipment_images(equipment_id);

CREATE INDEX IF NOT EXISTS idx_pro_profile_user ON public.professional_profiles(profile_id);
CREATE INDEX IF NOT EXISTS idx_pro_profile_category ON public.professional_profiles(category_id);
CREATE INDEX IF NOT EXISTS idx_pro_profile_approval ON public.professional_profiles(approval_status);

CREATE INDEX IF NOT EXISTS idx_portfolio_pro_profile ON public.portfolio_items(professional_profile_id);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_target ON public.favorites(target_type, target_id);

CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);

CREATE INDEX IF NOT EXISTS idx_contact_events_target ON public.contact_events(target_type, target_id);

-- ==========================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_events ENABLE ROW LEVEL SECURITY;

-- 4.1 PROFILES POLICIES
CREATE POLICY "Users read own profile or active profiles"
  ON public.profiles FOR SELECT
  USING (
    is_active = true 
    OR (auth.uid() IS NOT NULL AND auth.uid() = id) 
    OR private.has_moderation_role()
  );

CREATE POLICY "Users update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 4.2 USER ROLES POLICIES (No public/user inserts, updates, or deletes permitted!)
CREATE POLICY "Admins read user roles"
  ON public.user_roles FOR SELECT
  USING (private.has_moderation_role());

-- 4.3 CATEGORIES POLICIES
CREATE POLICY "Public read active categories"
  ON public.categories FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins manage categories"
  ON public.categories FOR ALL
  USING (private.has_moderation_role());

-- 4.4 EQUIPMENT POLICIES
CREATE POLICY "Public read approved equipment"
  ON public.equipment FOR SELECT
  USING (
    approval_status = 'approved' 
    OR (auth.uid() IS NOT NULL AND (auth.uid() = owner_id OR private.has_moderation_role()))
  );

CREATE POLICY "LoggedIn providers insert own equipment"
  ON public.equipment FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners update own equipment"
  ON public.equipment FOR UPDATE
  USING (auth.uid() = owner_id OR private.has_moderation_role());

CREATE POLICY "Owners delete own equipment"
  ON public.equipment FOR DELETE
  USING (auth.uid() = owner_id OR private.has_moderation_role());

-- 4.5 EQUIPMENT IMAGES POLICIES
CREATE POLICY "Public read equipment images"
  ON public.equipment_images FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.equipment e
      WHERE e.id = equipment_images.equipment_id
      AND (
        e.approval_status = 'approved' 
        OR (auth.uid() IS NOT NULL AND (e.owner_id = auth.uid() OR private.has_moderation_role()))
      )
    )
  );

CREATE POLICY "Owners manage equipment images"
  ON public.equipment_images FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.equipment e
      WHERE e.id = equipment_images.equipment_id
      AND (e.owner_id = auth.uid() OR private.has_moderation_role())
    )
  );

-- 4.6 PROFESSIONAL PROFILES POLICIES
CREATE POLICY "Public read approved professional profiles"
  ON public.professional_profiles FOR SELECT
  USING (
    approval_status = 'approved' 
    OR (auth.uid() IS NOT NULL AND (auth.uid() = profile_id OR private.has_moderation_role()))
  );

CREATE POLICY "LoggedIn providers insert own professional profile"
  ON public.professional_profiles FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Owners update own professional profile"
  ON public.professional_profiles FOR UPDATE
  USING (auth.uid() = profile_id OR private.has_moderation_role());

CREATE POLICY "Owners delete own professional profile"
  ON public.professional_profiles FOR DELETE
  USING (auth.uid() = profile_id OR private.has_moderation_role());

-- 4.7 PORTFOLIO ITEMS POLICIES
CREATE POLICY "Public read portfolio items"
  ON public.portfolio_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.professional_profiles p
      WHERE p.id = portfolio_items.professional_profile_id
      AND (
        p.approval_status = 'approved' 
        OR (auth.uid() IS NOT NULL AND (p.profile_id = auth.uid() OR private.has_moderation_role()))
      )
    )
  );

CREATE POLICY "Owners manage portfolio items"
  ON public.portfolio_items FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.professional_profiles p
      WHERE p.id = portfolio_items.professional_profile_id
      AND (p.profile_id = auth.uid() OR private.has_moderation_role())
    )
  );

-- 4.8 FAVORITES POLICIES
CREATE POLICY "Users read own favorites"
  ON public.favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own favorites"
  ON public.favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own favorites"
  ON public.favorites FOR DELETE
  USING (auth.uid() = user_id);

-- 4.9 REPORTS POLICIES
CREATE POLICY "Users insert own reports"
  ON public.reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users read own reports"
  ON public.reports FOR SELECT
  USING (auth.uid() = reporter_id OR private.has_moderation_role());

CREATE POLICY "Admins manage reports"
  ON public.reports FOR ALL
  USING (private.has_moderation_role());

-- 4.10 APPROVAL HISTORY POLICIES
CREATE POLICY "Admins insert approval history"
  ON public.approval_history FOR INSERT
  WITH CHECK (private.has_moderation_role());

CREATE POLICY "Admins and target owners read approval history"
  ON public.approval_history FOR SELECT
  USING (
    private.has_moderation_role()
    OR (target_type = 'equipment' AND EXISTS (SELECT 1 FROM public.equipment WHERE id = target_id AND owner_id = auth.uid()))
    OR (target_type = 'professional' AND EXISTS (SELECT 1 FROM public.professional_profiles WHERE id = target_id AND profile_id = auth.uid()))
  );

-- 4.11 CONTACT EVENTS POLICIES
CREATE POLICY "Anyone insert contact events"
  ON public.contact_events FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Content owners and admins view contact events"
  ON public.contact_events FOR SELECT
  USING (
    private.has_moderation_role()
    OR (target_type = 'equipment' AND EXISTS (SELECT 1 FROM public.equipment WHERE id = target_id AND owner_id = auth.uid()))
    OR (target_type = 'professional' AND EXISTS (SELECT 1 FROM public.professional_profiles WHERE id = target_id AND profile_id = auth.uid()))
  );

-- ==========================================
-- 5. INITIAL SEED DATA (CATEGORIES)
-- ==========================================

INSERT INTO public.categories (name_en, name_ar, category_type, icon_name, display_order)
VALUES
  ('Cameras', 'كاميرات', 'equipment', 'camera_alt', 1),
  ('Lenses', 'عدسات', 'equipment', 'center_focus_strong', 2),
  ('Lighting', 'إضاءة', 'equipment', 'lightbulb', 3),
  ('Audio', 'صوتيات', 'equipment', 'mic', 4),
  ('Grip & Support', 'جريبو وحركة', 'equipment', 'tune', 5),
  ('Drones & Motion', 'درون وحركة', 'equipment', 'flight_takeoff', 6),
  ('Directors', 'مخرجون', 'professional', 'movie_creation', 1),
  ('Cinematographers', 'مديرو تصوير', 'professional', 'videocam', 2),
  ('Editors', 'مونتير', 'professional', 'video_settings', 3),
  ('Photographers', 'مصورون', 'professional', 'photo_camera', 4),
  ('Colorists', 'مصححو ألوان', 'professional', 'color_lens', 5),
  ('Sound Engineers', 'مهندسو صوت', 'professional', 'graphic_eq', 6),
  ('Stylists & Art', 'ديكور واستايلنج', 'professional', 'content_cut', 7)
ON CONFLICT DO NOTHING;

-- ==========================================
-- 6. STORAGE BUCKETS & RLS POLICIES
-- ==========================================

-- Public avatars storage bucket for user profile photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Allow public select from avatars bucket"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

CREATE POLICY "Allow authenticated uploads to avatars bucket"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Allow authenticated updates to avatars bucket"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'avatars');

CREATE POLICY "Allow authenticated deletes from avatars bucket"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'avatars');
