/* write a query with FULL OUTER JOIN to fit the above described Parch & Posey scenario (selecting
all of the columns in both of the relevant tables, accounts and sales_reps) then answer the
subsequent multiple choice quiz */
SELECT *
FROM accounts a
FULL OUTER JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL;
/* In the following SQL Explorer, write a query that left joins the accounts table and the
sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on
accounts.primary_poc and sales_reps.name */
SELECT a.name account_name, a.primary_poc poc_name, s.name sales_rep_name
FROM accounts a
LEFT JOIN sales_reps s
ON a.sales_rep_id = s.id AND accounts.primary_poc < sales_reps.name
/* Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to
perform the same interval analysis except for the web_events table */
/* change the interval to 1 day to find those web events that occurred after, but not more than
1 day after, another web event & add a column for the channel variable in both instances of the
table in your query */
SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at;
/* Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts
table. Then inspect the results and answer the subsequent quiz */
SELECT *
FROM accounts
UNION ALL
SELECT *
FROM accounts;
/* contd.. */
SELECT *
FROM accounts
WHERE name = 'Walmart'
UNION
SELECT *
FROM accounts
WHERE name = 'Disney';
/* Perform the union in your first query (under the Appending Data via UNION header) in a common
table expression and name it double_accounts. Then do a COUNT the number of times a name appears
in the double_accounts table. If you do this correctly, your query results should have a count of
2 for each name */
WITH t1 AS (SELECT *
            FROM accounts
            UNION ALL
            SELECT *
            FROM acco unts)
SELECT 1, COUNT(*) name_count
FROM t1
GROUP BY 1
ORDER BY 2 DESC;
/* JOINing subqueries, Instead of that */
SELECT DATE_TRUNC('day', o.occurred_at) AS date,
       COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
       COUNT(DISTINCT o.id) AS orders,
       COUNT(DISTINCT we.id) web_visits
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events we
ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;
/* use this to make query faster */
SELECT COALESCE(orders.date, web_events.date) AS date,
       orders.active_sales_reps,
       orders.orders,
       web_events.web_visits
FROM(
SELECT DATE_TRUNC('day', o.occurred_at) AS date,
       COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
       COUNT(DISTINCT o.id) AS orders
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
) orders
FULL JOIN(
SELECT COUNT(DISTINCT we.id) web_visits
FROM web_events we
GROUP BY 1
)web_events
ON web_events.date = orders.date
ORDER BY 1 DESC;
