/* On which day-channel pair did the most events occur */
SELECT DATE_TRUNC('day', occurred_at) day, channel, COUNT(*) events
FROM web_events
GROUP BY 1, 2
ORDER BY 3 DESC;
/* Here you can see that to get the entire table in question 1 back, we included an * in our SELECT
statement. You will need to be sure to alias your table */
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2
          ORDER BY 3 DESC) sub;
/* Match each channel to its corresponding average number of events per day */
SELECT channel, AVG(events) avg_events_per_day
FROM (SELECT DATE_TRUNC('day', occurred_at) day, channel, COUNT(*) events
      FROM web_events
      GROUP BY 1, 2) sub
GROUP BY 1,
ORDER BY 2;
/* Use DATE_TRUNC to pull month level information about the first order ever placed in the orders
table */
SELECT DATE_TRUNC('month', MIN(occurred_at)) first_month
FROM orders
/* Use the result of the previous query to find only the orders that took place in the same month
and year as the first order, and then pull the average for each type of paper qty in this month */
SELECT AVG(standard_qty) avg_standard, AVG(poster_qty) avg_poster, AVG(glossy_qty) avg_glossy
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) first_month FROM orders);
/* The total amount spent on all orders on the first month that any order was placed in the order
table (in term of usd). */
SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) first_month FROM orders);
/* Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales */
SELECT t3.rep_name, t3.reg_name, t2.max_amt
FROM (SELECT reg_name, MAX(total_amt) max_amt
      FROM (SELECT s.name rep_name, r.name reg_name, SUM(o.total_amt_usd) total_amt
             FROM region r
             JOIN sales_reps s
             ON s.region_id = r.id
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders
             ON o.account_id = a.id
             GROUP BY 1, 2) t1
     GROUP BY 1, 2) t2
JOIN (SELECT s.name rep_name, r.name reg_name, SUM(o.total_amt_usd) total_amt
      FROM region r
      JOIN sales_reps s
      ON s.region_id = r.id
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders
      ON o.account_id = a.id
      GROUP BY 1, 2
      ORDER BY 3 DESC) t3
ON t3.reg_name = t2.reg_name AND t3.total_amt = t2.max_amt
/* For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders
were placed */
SELECT r.name, COUNT(*) num_orders
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total_amt_usd) =
       (SELECT MAX(total_amt) max_amt
        FROM (SELECT s.name rep_name, r.name reg_name, SUM(o.total_amt_usd) total_amt
              FROM region r
              JOIN sales_reps s
              ON s.region_id = r.id
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders
              ON o.account_id = a.id) sub);
/*For the name of the account that purchased the most (in total over their lifetime as a customer)
standard_qty paper, how many accounts still had more in total purchases */
SELECT COUNT(*)
FROM(
      SELECT a.name
      FROM accounts a
      JOIN orders
      ON o.account_id = a.id
      GROUP BY 1
      HAVING SUM(o.total) >
             (SELECT total
              FROM(
                   SELECT a.name, SUM(o.standard_qty), SUM(o.total) total
                   FROM accounts a
                   JOIN orders o
                   ON o.account_id = a.id
                   GROUP BY 1
                   ORDER BY 2 DESC
                   LIMIT 1) inner)
                 ) counter_tab;
/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel */
SELECT a.name, w.channel, COUNT(*)
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN orders o
ON o.account_id = a.id AND a.id = (
       SELECT id
       FROM(
            SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
            FROM accounts a
            JOIN orders o
            ON o.account_id = a.id
            GROUP BY 1, 2
            ORDER BY 3 DESC
            LIMIT 1) inner_tab)
GROUP BY 1, 2
ORDER BY 3 DESC;
/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total
spending accounts */
SELECT AVG(total_spent) avg_spent
FROM (
      SELECT a.id, a.name SUM(o.total_amt_usd) total_spent
              FROM accounts a
              JOIN orders o
              ON o.account_id = a.id
              GROUP BY 1, 2
              ORDER BY 3 DESC
              LIMIT 10);
/* What is the lifetime average amount spent in terms of total_amt_usd for only the companies
that spent more than the average of all orders */
SELECT AVG(total_spent)
FROM (
      SELECT o.account_id, o.total_amt_usd total_spent
      FROM orders o
      GROUP BY 1
      HAVING AVG(o.total_amt_usd) > (
                             SELECT AVG(total_amt_usd) avg_all
                             FROM orders))
/* Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales
*/
WITH table1 AS (SELECT s.name rep_name, r.name reg_name, SUM(o.total_amt_usd) total_spent
                FROM region r
                JOIN sales_reps s
                ON s.region_id = r.id
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders
                ON o.account_id = a.id
                GROUP BY 1, 2),
     table2 AS (SELECT reg_name, MAX(total_spent) max_spent
                FROM table1
                GROUP BY 1)
SELECT table1.rep_name, table2.reg_name, table3.max_spent
FROM table1
JOIN table2
ON table1.reg_name = table2.reg_name AND table1.total_spent = table2.max_spent
GROUP BY 1, 2
ORDER BY 3 DESC;
/* For the region with the largest sales total_amt_usd, how many total orders were placed */
WITH t1 AS (SELECT r.name reg_name, SUM(o.total_amt_usd) total_spent
            FROM region r
            JOIN sales_reps s
            ON s.region_id = r.id
            JOIN accounts a
            ON a.sales_rep_id = s.id
            JOIN orders
            ON o.account_id = a.id
            GROUP BY 1),
     t2 AS (SELECT reg_name, MAX(total_spent) max_spent
             FROM t1)
SELECT reg_name, COUNT(*)
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = (SELECT (*)
                               FROM t2);
                               
/* For the account that purchased the most (in total over their lifetime as a customer)
standard_qty paper, how many accounts still had more in total purchases */


/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel */


/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending
accounts */


/* What is the lifetime average amount spent in terms of total_amt_usd for only the companies that
spent more than the average of all accounts */
