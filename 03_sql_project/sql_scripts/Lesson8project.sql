/* Query that creates a table with the following details: actor's first and last name combined as
full_name, film title and length of the movies */
SELECT a.first_name, a.last_name,
       CONCAT(a.first_name, ' ', a.last_name) full_name, f.title, f.length
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id;
/* Write a query that creates a list of actors and movies where the movie length was more than 60
minutes */
SELECT a.first_name, a.last_name,
       CONCAT(a.first_name, ' ', a.last_name) full_name, f.title, f.length
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
WHERE f.length>60;
/* Write a query that captures the full name of the actor, and counts the number of movies each
actor has made. Identify the actor who has made the maximum number of movies */
SELECT full_name, COUNT(film_title) num_movie
FROM(
  SELECT a.first_name, a.last_name,
         CONCAT(a.first_name, ' ', a.last_name) full_name, f.title film_title
  FROM actor a
  JOIN film_actor fa
  ON a.actor_id = fa.actor_id
  JOIN film f
  ON fa.film_id = f.film_id) t1
GROUP BY 1
ORDER BY 2 DESC;
/* Write a query that creates a table with 4 columns: actor's full name, film title, length of
movie, and a column name "filmlen_groups" that classifies movies based on their length.
Filmlen_groups should include 4 categories: 1 hour or less, Between 1-2 hours, Between 2-3 hours,
More than 3 hours */
WITH t1 AS (SELECT film_id, title, length,
            CASE WHEN length <= 60 THEN 'less_than_1hr'
                 WHEN length > 60 AND length <= 120 THEN 'between_1_2hr'
                 WHEN length > 120 AND length <= 180 THEN 'between_2_3hr'
                 ELSE 'more_than_3hr' END AS filmlen_groups
                 FROM film),
      t2 AS (SELECT a.first_name, a.last_name,
                    CONCAT(a.first_name, ' ', a.last_name) full_name, f.film_id, f.title film_title
            FROM actor a
            JOIN film_actor fa
            ON a.actor_id = fa.actor_id
            JOIN film f
            ON fa.film_id = f.film_id)
SELECT t2.full_name, t2.film_title, t1.length, t1.filmlen_groups
FROM t1
JOIN t2
ON t1.film_id = t2.film_id;
/* Write a query you to create a count of movies in each of the 4 filmlen_groups: 1 hour or less,
Between 1-2 hours, Between 2-3 hours, More than 3 hours */
WITH t1 AS (SELECT film_id, title, length,
            CASE WHEN length <= 60 THEN 'less_than_1hr'
                 WHEN length > 60 AND length <= 120 THEN 'between_1_2hr'
                 WHEN length > 120 AND length <= 180 THEN 'between_2_3hr'
                 ELSE 'more_than_3hr' END AS filmlen_groups
                 FROM film)
SELECT filmlen_groups, COUNT(title) num_title
FROM t1
GROUP BY 1
ORDER BY 2 DESC;
/* alternatively */
SELECT    DISTINCT(filmlen_groups),
          COUNT(title) OVER (PARTITION BY filmlen_groups) AS filmcount_bylencat
FROM
         (SELECT title,length,
          CASE WHEN length <= 60 THEN '1 hour or less'
          WHEN length > 60 AND length <= 120 THEN 'Between 1-2 hours'
          WHEN length > 120 AND length <= 180 THEN 'Between 2-3 hours'
          ELSE 'More than 3 hours' END AS filmlen_groups
          FROM film ) t1
ORDER BY  filmlen_groups;
/* We want to understand more about the movies that families are watching. The following
categories are considered family movies: Animation, Children, Classics, Comedy, Family and
Music */
/* Create a query that lists each movie, the film category it is classified in, and the number
of times it has been rented out */
SELECT f.title film_title, c.name category_name, COUNT(*) rental_count
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY 1, 2
ORDER BY 2,1;
/* Now we need to know how the length of rental duration of these family-friendly movies
compares to the duration that all movies are rented for. Can you provide a table with the
movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and
final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across
all categories? Make sure to also indicate the category that these family-friendly movies fall
into */
SELECT f.title film_title, c.name category_name, f.rental_duration film_rental_duration,
       NTILE(4) OVER main_window AS standard_quarter
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
WINDOW main_window AS (ORDER BY f.rental_duration);
/* Finally, provide a table with the family-friendly film category, each of the quartiles, and
the corresponding count of movies within each combination of film category for each
corresponding rental duration category.
The resulting table should have three columns: Category, Rental length category, Count */
WITH t1 AS(
  SELECT f.title film_title, c.name category_name, f.rental_duration film_rental_duration,
       NTILE(4) OVER main_window AS standard_quarter
  FROM category c
  JOIN film_category fc
  ON c.category_id = fc.category_id
  JOIN film f
  ON fc.film_id = f.film_id
  WINDOW main_window AS (ORDER BY f.rental_duration))
SELECT category_name, standard_quarter, COUNT(*) num_movie
FROM t1
GROUP BY 1, 2
ORDER BY 1, 2;
/* We want to find out how the two stores compare in their count of rental orders during every
month for all the years we have data for. ** Write a query that returns the store ID for the
store, the year and month and the number of rental orders each store has fulfilled for that
month. Your table should include a column for each of the following: year, month, store ID and
count of rental orders fulfilled during that month */
WITH t1 AS (SELECT DATE_TRUNC('month', r.rental_date) rental_month, st.store_id, COUNT(*) count_rental
			FROM rental r
			JOIN staff s
			ON r.staff_id = s.staff_id
			JOIN store st
			ON s.store_id = st.store_id
			GROUP BY 1, 2
			ORDER BY 3 DESC),
	 t2 AS (SELECT DATE_TRUNC('month', rental_month) rental_month,
			CAST(DATE_TRUNC('month', rental_month) AS varchar) date,
			t1.store_id, t1.count_rental
           FROM t1),
     t3 AS (SELECT rental_month, LEFT(date, 7) date_month, t2.store_id, t2.count_rental
			FROM t2)
SELECT RIGHT(t3.date_month, 2) rental_mon, LEFT(t3.date_month, 4) rental_year,
      t3.store_id, t3.count_rental
FROM t3;
/* alternatively */
WITH t1 AS (SELECT DATE_TRUNC('month', rental_date) rental_month, rental_id
			FROM rental),
	 t2 AS (SELECT DATE_TRUNC('month', rental_month) rental_month,
			CAST(DATE_TRUNC('month', rental_month) AS varchar) date, t1.rental_id
           FROM t1),
     t3 AS (SELECT rental_month, LEFT(date, 7) date_month, t2.rental_id
			FROM t2)
SELECT t3.rental_month, RIGHT(t3.date_month, 2) rental_month, LEFT(t3.date_month, 4) rental_year,
      st.store_id, COUNT(*) count_rental
FROM t3
JOIN rental r
ON t3.rental_id = r.rental_id
JOIN staff s
ON r.staff_id = s.staff_id
JOIN store st
ON s.store_id = st.store_id
GROUP BY 1, 2, 3, 4
ORDER BY 1;


/* Project 1*/
/* We would like to know who were our top 10 paying customers, how many payments they made on
a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a
query to capture the customer name, month and year of payment, and total payment amount for
each month by these top 10 paying customers */




/* Project 2 */
/* Show the list of customers that paid higher than the median amount per customer. */
 



/* Project 3 */
/* Rank each month in the year 2007 according to it total payment amount and seperate date into year and
month. Then, use the case funtion to group the payment amount into large if payment amount is greater
10000 and small if the amount is less than 10000  */




  /* project 4 */
  /* for each of these top 10 paying cities, I would like to find out the difference
  across their monthly payments during 2007. Please go ahead and ** write a query to compare the
  payment amounts in each successive month.** Repeat this for each of these 10 paying cities.
  Also, it will be tremendously helpful if you can identify the city name who paid the most
  difference in terms of payments */
  