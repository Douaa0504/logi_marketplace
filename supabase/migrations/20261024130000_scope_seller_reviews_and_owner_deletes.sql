BEGIN;

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
FROM public.product_reviews AS review
WHERE COALESCE(
  (
    SELECT profile.role::text
    FROM public.profiles AS profile
    WHERE profile.id = auth.uid()
  ),
  ''
) <> 'seller'
OR EXISTS (
  SELECT 1
  FROM public.products AS product
  WHERE product.id = review.product_id
    AND product.seller_id = auth.uid()
);

DROP POLICY IF EXISTS product_reviews_update_buyer
  ON public.product_reviews;
CREATE POLICY product_reviews_update_buyer
  ON public.product_reviews
  FOR UPDATE TO authenticated
  USING (
    auth.uid() = buyer_id
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS buyer
      WHERE buyer.id = auth.uid()
        AND buyer.role::text = 'buyer'
    )
  )
  WITH CHECK (
    auth.uid() = buyer_id
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS buyer
      WHERE buyer.id = auth.uid()
        AND buyer.role::text = 'buyer'
    )
  );

DROP POLICY IF EXISTS product_reviews_delete_buyer
  ON public.product_reviews;
CREATE POLICY product_reviews_delete_buyer
  ON public.product_reviews
  FOR DELETE TO authenticated
  USING (
    auth.uid() = buyer_id
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS buyer
      WHERE buyer.id = auth.uid()
        AND buyer.role::text = 'buyer'
    )
  );

COMMIT;
