use sakila;

-- Step 1 : creating a view as a Customer Summaru Report
-- customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r 
ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

Select * from customer_summary_report;

-- had to change the ONLY_FULL_GROUP_BY mode from STRICT to Traditionnal to be able to run above code
SELECT @@sql_mode;
SET SESSION sql_mode = 'TRADITIONAL';

-- Step 2
-- Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
-- calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT crs.customer_id, 
       SUM(p.amount) AS total_paid
FROM customer_rental_summary AS crs
JOIN payment AS p 
ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;

select * from customer_payment_summary;

-- Step 3 
-- creating a CTA joining rental sumarr and payment summary

WITH customer_summary AS (
    SELECT crs.customer_id, crs.first_name, crs.last_name, crs.email, crs.rental_count, cps.total_paid, (cps.total_paid / NULLIF(crs.rental_count, 0)) AS average_payment_per_rental
    FROM customer_rental_summary AS crs
    JOIN customer_payment_summary AS cps 
    ON crs.customer_id = cps.customer_id
)
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name, email, rental_count, total_paid, average_payment_per_rental
FROM customer_summary
ORDER BY customer_id;