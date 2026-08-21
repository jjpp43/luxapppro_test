-- Fixed dashboard rank (not TapMango CSV). Active-rate order as of the
-- TapMango Location Performance screenshot the PM matched:
--   1 West Sahara, 2 Craig, 3 East Twain, 4 Decatur, 5 Hollywood, 6 Hairway

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS sort_rank integer;

UPDATE public.stores
SET sort_rank = CASE name
  WHEN 'Lux Beauty Supply - West Sahara Avenue' THEN 1
  WHEN 'Lux Beauty Supply - Craig' THEN 2
  WHEN 'Lux Beauty Supply - East Twain' THEN 3
  WHEN 'Lux Beauty Supply - Decatur' THEN 4
  WHEN 'Hollywood Beauty' THEN 5
  WHEN 'Hairway 2 Heaven' THEN 6
END
WHERE sort_rank IS NULL;

ALTER TABLE public.stores
  ALTER COLUMN sort_rank SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS stores_sort_rank_key
  ON public.stores (sort_rank);
