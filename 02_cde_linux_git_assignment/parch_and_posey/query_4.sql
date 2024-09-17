-- Provide a table that shows the region for each sales rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) by account name.

 SELECT r.name as region_name, 
        s.name as sales_rep_nam, 
        a.name as account_name
 FROM public.accounts AS a
 INNER JOIN public.sales_reps AS s ON a.sales_rep_id = s.id
 INNER JOIN public.region AS r ON s.region_id = r.id
 ORDER BY s.name ASC; 







