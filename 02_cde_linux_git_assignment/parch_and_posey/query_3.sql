-- Find all the company names that start with a 'C' or 'W', and where the primary contact contains 'ana' or 'Ana', but does not contain 'eana'.

 SELECT *
 FROM public.region
 WHERE (name LIKE 'C%' OR name like 'W%') 
     AND (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
     AND (primary_poc NOT LIKE '%eana%');