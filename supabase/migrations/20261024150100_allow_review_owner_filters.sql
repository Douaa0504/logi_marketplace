BEGIN;

GRANT SELECT (id) ON public.product_reviews TO authenticated;

COMMIT;
