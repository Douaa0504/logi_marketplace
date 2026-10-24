BEGIN; -- Apply the schema and access-control changes atomically.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS shop_name text,
  ADD COLUMN IF NOT EXISTS shop_description text,
  ADD COLUMN IF NOT EXISTS shop_logo_url text;

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_shop_name_length_chk,
  DROP CONSTRAINT IF EXISTS profiles_shop_description_length_chk,
  DROP CONSTRAINT IF EXISTS profiles_shop_logo_url_chk;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_shop_name_length_chk
    CHECK (shop_name IS NULL OR char_length(trim(shop_name)) BETWEEN 1 AND 80),
  ADD CONSTRAINT profiles_shop_description_length_chk
    CHECK (shop_description IS NULL OR char_length(trim(shop_description)) BETWEEN 1 AND 500),
  ADD CONSTRAINT profiles_shop_logo_url_chk
    CHECK (shop_logo_url IS NULL OR shop_logo_url ~ '^https?://');

CREATE INDEX IF NOT EXISTS idx_profiles_shop_name
  ON public.profiles (shop_name);

DROP VIEW IF EXISTS public.public_seller_shops;
CREATE VIEW public.public_seller_shops WITH (security_barrier = true) AS
SELECT
  profile.id,
  COALESCE(NULLIF(trim(profile.shop_name), ''), 'Seller Shop') AS shop_name,
  profile.shop_description,
  profile.shop_logo_url
FROM public.profiles AS profile
WHERE profile.role::text = 'seller';

REVOKE ALL ON public.public_seller_shops FROM PUBLIC;
GRANT SELECT ON public.public_seller_shops TO anon, authenticated;

CREATE TABLE IF NOT EXISTS public.product_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  buyer_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text text NOT NULL
    CHECK (char_length(trim(review_text)) BETWEEN 1 AND 2000),
  created_at timestamptz NOT NULL DEFAULT now(),
  verified_purchase boolean NOT NULL DEFAULT false,
  CONSTRAINT product_reviews_one_per_buyer UNIQUE (product_id, buyer_id)
);

CREATE INDEX IF NOT EXISTS idx_product_reviews_product_created
  ON public.product_reviews (product_id, created_at DESC);

ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS product_reviews_select_public ON public.product_reviews;
DROP POLICY IF EXISTS product_reviews_insert_buyer ON public.product_reviews;
DROP POLICY IF EXISTS product_reviews_update_buyer ON public.product_reviews;
DROP POLICY IF EXISTS product_reviews_delete_buyer ON public.product_reviews;
-- La policy autorise la lecture ; la vue publique contrôle les champs exposés.
CREATE POLICY product_reviews_select_public ON public.product_reviews
  FOR SELECT USING (true);
CREATE POLICY product_reviews_insert_buyer ON public.product_reviews
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = buyer_id
    AND rating BETWEEN 1 AND 5
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS buyer
      WHERE buyer.id = auth.uid()
        AND buyer.role::text = 'buyer'
    )
    AND EXISTS (
      SELECT 1 FROM public.products AS product
      WHERE product.id = product_id
        AND product.seller_id <> auth.uid()
    )
  );
CREATE POLICY product_reviews_update_buyer ON public.product_reviews
  FOR UPDATE TO authenticated
  USING (auth.uid() = buyer_id)
  WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY product_reviews_delete_buyer ON public.product_reviews
  FOR DELETE TO authenticated
  USING (auth.uid() = buyer_id);

CREATE OR REPLACE FUNCTION public.prevent_review_identity_changes()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.product_id IS DISTINCT FROM OLD.product_id
     OR NEW.buyer_id IS DISTINCT FROM OLD.buyer_id
     OR NEW.verified_purchase IS DISTINCT FROM OLD.verified_purchase THEN
    RAISE EXCEPTION 'Review ownership and product cannot be changed';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_review_identity_changes
  ON public.product_reviews;
CREATE TRIGGER trg_prevent_review_identity_changes
BEFORE UPDATE ON public.product_reviews
FOR EACH ROW
EXECUTE FUNCTION public.prevent_review_identity_changes();

-- La vue expose le contenu des avis sans publier l'identifiant du Buyer.
CREATE OR REPLACE VIEW public.product_reviews_public
  WITH (security_barrier = true) AS
SELECT
  review.id,
  review.product_id,
  review.rating,
  review.review_text,
  review.created_at,
  review.verified_purchase,
  review.buyer_id = auth.uid() AS is_mine
FROM public.product_reviews AS review;

REVOKE ALL ON public.product_reviews_public FROM PUBLIC;
GRANT SELECT ON public.product_reviews_public TO anon, authenticated;
REVOKE ALL ON public.product_reviews FROM PUBLIC, anon, authenticated;
GRANT INSERT (product_id, buyer_id, rating, review_text)
  ON public.product_reviews TO authenticated;
GRANT UPDATE (rating, review_text)
  ON public.product_reviews TO authenticated;
GRANT DELETE ON public.product_reviews TO authenticated;
REVOKE ALL ON FUNCTION public.prevent_review_identity_changes()
  FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS public.seller_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_type text NOT NULL
    CHECK (notification_type IN ('favorite', 'review', 'order')),
  message text NOT NULL,
  product_id uuid REFERENCES public.products(id) ON DELETE SET NULL,
  product_title text,
  event_key text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT seller_notifications_event_unique UNIQUE (seller_id, event_key)
);

CREATE INDEX IF NOT EXISTS idx_seller_notifications_seller_created
  ON public.seller_notifications (seller_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_seller_notifications_unread
  ON public.seller_notifications (seller_id, is_read, created_at DESC);

ALTER TABLE public.seller_notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS seller_notifications_select_own
  ON public.seller_notifications;
DROP POLICY IF EXISTS seller_notifications_update_own
  ON public.seller_notifications;
CREATE POLICY seller_notifications_select_own
  ON public.seller_notifications FOR SELECT TO authenticated
  USING (seller_id = auth.uid());
CREATE POLICY seller_notifications_update_own
  ON public.seller_notifications FOR UPDATE TO authenticated
  USING (seller_id = auth.uid())
  WITH CHECK (seller_id = auth.uid());

REVOKE ALL ON public.seller_notifications FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.seller_notifications TO authenticated;
GRANT UPDATE (is_read) ON public.seller_notifications TO authenticated;

CREATE OR REPLACE FUNCTION public.create_favorite_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.seller_notifications (
    seller_id, notification_type, message, product_id, product_title, event_key
  )
  SELECT
    product.seller_id,
    'favorite',
    'A buyer favorited your product.',
    NEW.product_id,
    product.title,
    'favorite:' || NEW.user_id::text || ':' || NEW.product_id::text
  FROM public.products AS product
  WHERE product.id = NEW.product_id
    AND product.seller_id <> NEW.user_id
  ON CONFLICT (seller_id, event_key) DO NOTHING;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_review_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.seller_notifications (
    seller_id, notification_type, message, product_id, product_title, event_key
  )
  SELECT
    product.seller_id,
    'review',
    'A buyer left a review for your product.',
    NEW.product_id,
    product.title,
    'review:' || NEW.id::text
  FROM public.products AS product
  WHERE product.id = NEW.product_id
    AND product.seller_id <> NEW.buyer_id
  ON CONFLICT (seller_id, event_key) DO NOTHING;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_order_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.stock_reserved IS TRUE
     AND NEW.checkout_request_id IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM public.checkout_requests AS request
       WHERE request.id = NEW.checkout_request_id
         AND request.buyer_id = NEW.buyer_id
     )
     AND NEW.seller_id <> NEW.buyer_id THEN
    INSERT INTO public.seller_notifications (
      seller_id, notification_type, message, product_id, product_title, event_key
    )
    VALUES (
      NEW.seller_id,
      'order',
      'A buyer placed an order for your product.',
      NEW.product_id,
      NEW.product_title_snapshot,
      'order:' || NEW.id::text
    )
    ON CONFLICT (seller_id, event_key) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.create_favorite_notification()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.create_review_notification()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.create_order_notification()
  FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_favorite_notification ON public.favorites;
CREATE TRIGGER trg_favorite_notification
AFTER INSERT ON public.favorites
FOR EACH ROW
EXECUTE FUNCTION public.create_favorite_notification();

DROP TRIGGER IF EXISTS trg_review_notification ON public.product_reviews;
CREATE TRIGGER trg_review_notification
AFTER INSERT ON public.product_reviews
FOR EACH ROW
EXECUTE FUNCTION public.create_review_notification();

DROP TRIGGER IF EXISTS trg_order_notification ON public.orders;
CREATE TRIGGER trg_order_notification
AFTER INSERT ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.create_order_notification();

DROP POLICY IF EXISTS seller_shop_logo_insert_own
  ON storage.objects;
CREATE POLICY seller_shop_logo_insert_own
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'products'
    AND name LIKE ('shop-logos/' || auth.uid()::text || '/%')
    AND owner_id = auth.uid()::text
    AND EXISTS (
      SELECT 1 FROM public.profiles AS seller
      WHERE seller.id = auth.uid()
        AND seller.role::text = 'seller'
    )
  );

COMMIT;
