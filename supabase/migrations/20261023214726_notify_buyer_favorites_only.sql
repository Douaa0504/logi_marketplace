BEGIN; -- Keep the notification rule update atomic.

CREATE OR REPLACE FUNCTION public.create_favorite_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.seller_notifications (
    seller_id,
    notification_type,
    message,
    product_id,
    product_title,
    event_key
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
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS buyer
      WHERE buyer.id = NEW.user_id
        AND buyer.role::text = 'buyer'
    )
  ON CONFLICT (seller_id, event_key) DO NOTHING;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.create_favorite_notification()
  FROM PUBLIC, anon, authenticated;

COMMIT;
