
/*********************************************************************
Chapter 7: Subqueries
Database: Sakila
Date: November 17, 2026
*********************************************************************/


/*********************************************************************
Query 1: WHERE subquery returning one value
Count the number of payments that are greater than the average
*********************************************************************/

SELECT COUNT(*) AS payments_above_avg
FROM payment
WHERE amount > (
    SELECT AVG(amount)
    FROM payment
);


/*********************************************************************
Query 2: WHERE clause using IN operator subquery returning a list
2.A - Display all payments for customers associated with store id 2
*********************************************************************/

SELECT *
FROM payment
WHERE customer_id IN (
    SELECT customer_id
    FROM customer
    WHERE store_id = 2
)
ORDER BY customer_id, payment_date;


/*********************************************************************
Query 2: WHERE clause using IN operator subquery returning a list
2.B - Rewrite the query to use an INNER JOIN instead of a subquery
*********************************************************************/

SELECT p.*
FROM payment AS p
INNER JOIN customer AS c
    ON p.customer_id = c.customer_id
WHERE c.store_id = 2
ORDER BY p.customer_id, p.payment_date;


/*********************************************************************
Query 3: WHERE clause using the ALL operator subquery returning a list
3.A - Display payments greater than all of customer 1's payments
*********************************************************************/

SELECT *
FROM payment
WHERE amount > ALL (
    SELECT amount
    FROM payment
    WHERE customer_id = 1
)
ORDER BY customer_id, payment_date;


/*********************************************************************
Query 3: WHERE clause using the ALL operator subquery returning a list
3.B - Rewrite the query using the MAX aggregate function
*********************************************************************/

SELECT *
FROM payment
WHERE amount > (
    SELECT MAX(amount)
    FROM payment
    WHERE customer_id = 1
)
ORDER BY customer_id, payment_date;


/*********************************************************************
Query 4: WHERE correlated subquery running multiple times (once for each outer row)
4.A - Display each customer's average amount paid using AVG
*********************************************************************/

SELECT 
    customer_id, 
    AVG(amount) AS avg_amount_paid
FROM payment
GROUP BY customer_id
ORDER BY customer_id;


/*********************************************************************
Query 4: WHERE correlated subquery running multiple times (once for each outer row)
4.B - Count all customer's payments greater than the customer's average payment
*********************************************************************/

SELECT COUNT(*) AS above_customer_avg_count
FROM payment AS p1
WHERE p1.amount > (
    SELECT AVG(p2.amount)
    FROM payment AS p2
    WHERE p2.customer_id = p1.customer_id
);


/*********************************************************************
Query 5: WHERE subquery using EXISTS operator returning a Boolean value
5.A - Display customers who do not have any payments using NOT EXISTS
*********************************************************************/

SELECT c.*
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM payment AS p
    WHERE p.customer_id = c.customer_id
)
ORDER BY c.customer_id;


/*********************************************************************
Query 5: WHERE subquery using EXISTS operator returning a Boolean value
5.B - Rewrite the query to use a LEFT JOIN instead of a subquery
*********************************************************************/

SELECT c.*
FROM customer AS c
LEFT JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL
ORDER BY c.customer_id;


/*********************************************************************
Query 6: SELECT subquery returning a single value
6.A - Display each customer's MAX payment date using a correlated subquery
*********************************************************************/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    (
        SELECT MAX(p.payment_date)
        FROM payment AS p
        WHERE p.customer_id = c.customer_id
    ) AS last_payment_date
FROM customer AS c
ORDER BY c.customer_id DESC;


/*********************************************************************
Query 6: SELECT subquery returning a single value
6.B - Rewrite the query to use a LEFT JOIN instead of a subquery
*********************************************************************/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    MAX(p.payment_date) AS last_payment_date
FROM customer AS c
LEFT JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id DESC;


/*********************************************************************
Query 7: FROM subquery returning an inline view (temporary table)
7.A - Display the top customer based on total amount paid
*********************************************************************/

SELECT 
    customer_id, 
    SUM(amount) AS total_amount_paid
FROM payment
GROUP BY customer_id
ORDER BY total_amount_paid DESC
LIMIT 1;


/*********************************************************************
Query 7: FROM subquery returning an inline view (temporary table)
7.B - Display all payments for the top customer by joining the query to the payment table
*********************************************************************/

SELECT p.*
FROM payment AS p
INNER JOIN (
    SELECT 
        customer_id, 
        SUM(amount) AS total_amount_paid
    FROM payment
    GROUP BY customer_id
    ORDER BY total_amount_paid DESC
    LIMIT 1
) AS top_customer
    ON p.customer_id = top_customer.customer_id
ORDER BY p.payment_date;
