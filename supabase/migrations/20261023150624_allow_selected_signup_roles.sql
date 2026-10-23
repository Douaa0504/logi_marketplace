CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  requested_role text := new.raw_user_meta_data ->> 'role';
  signup_role public.user_role;
BEGIN
  IF requested_role IS NULL THEN
    signup_role := 'buyer'::public.user_role;
  ELSIF requested_role = 'buyer' THEN
    signup_role := 'buyer'::public.user_role;
  ELSIF requested_role = 'seller' THEN
    signup_role := 'seller'::public.user_role;
  ELSE
    RAISE EXCEPTION 'Invalid signup role';
  END IF;

  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data ->> 'full_name', 'User'),
    signup_role
  );
  RETURN new;
END;
$function$;
