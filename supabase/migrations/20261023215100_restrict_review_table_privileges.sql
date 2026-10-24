BEGIN;

REVOKE ALL ON public.product_reviews FROM PUBLIC, anon, authenticated;
GRANT INSERT (product_id, buyer_id, rating, review_text)
  ON public.product_reviews TO authenticated;
GRANT UPDATE (rating, review_text)
  ON public.product_reviews TO authenticated;
GRANT DELETE ON public.product_reviews TO authenticated;

COMMIT;
