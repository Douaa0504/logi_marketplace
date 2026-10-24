BEGIN;

-- PostgREST peut filtrer par ID pour les mutations sans exposer buyer_id.
GRANT SELECT (id) ON public.product_reviews TO authenticated;

COMMIT;
