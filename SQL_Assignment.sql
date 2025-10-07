/* ============================================================================
QUESTION 1 (SQL Basics)
Create table employees with constraints:
============================================================================ */
CREATE TABLE IF NOT EXISTS employees (
    emp_id INT NOT NULL,
    emp_name VARCHAR(255) NOT NULL,
    age INT,
    email VARCHAR(255),
    salary DECIMAL(12,2) NOT NULL DEFAULT 30000.00,
    PRIMARY KEY (emp_id),
    UNIQUE KEY uq_employees_email (email),
    CONSTRAINT chk_employees_age CHECK (age >= 18)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*
QUESTION 2: Purpose of constraints & examples
Constraints are rules applied to enforce data integrity and consistency.
They help ensure valid and reliable data is maintained in the database.
Common constraints include:
1. PRIMARY KEY → Uniquely identifies a record.
2. UNIQUE → Prevents duplicate values.
3. NOT NULL → Ensures required fields have data.
4. CHECK → Validates a condition (e.g., age >= 18).
5. FOREIGN KEY → Maintains referential integrity between related tables.
6. DEFAULT → Provides default values if none supplied.
*/

/*
QUESTION 3: Why apply NOT NULL? Can primary key contain NULL?
NOT NULL ensures critical fields are always filled.
A primary key cannot contain NULL because it must uniquely identify each row.
NULL represents "unknown", so uniqueness would break if NULL were allowed.
*/

/*
QUESTION 4: Add or remove constraints (example)
*/
-- Add UNIQUE
ALTER TABLE employees ADD UNIQUE KEY uq_employees_email (email);
-- Remove UNIQUE
ALTER TABLE employees DROP INDEX uq_employees_email;

-- Add foreign key
ALTER TABLE employees ADD CONSTRAINT fk_mgr FOREIGN KEY (emp_id) REFERENCES employees(emp_id);

-- Remove foreign key
ALTER TABLE employees DROP FOREIGN KEY fk_mgr;

/*
QUESTION 5: What happens if constraints are violated?
Database rejects invalid data and returns error messages like:
ERROR 1062 (23000): Duplicate entry 'abc@mail.com' for key 'uq_employees_email'
ERROR 3819 (Check constraint 'chk_employees_age' is violated)
*/

/*
QUESTION 6: Alter products table to add primary key + default
*/
ALTER TABLE products
    MODIFY COLUMN product_id INT NOT NULL,
    ADD PRIMARY KEY (product_id);
ALTER TABLE products
    MODIFY COLUMN price DECIMAL(10,2) DEFAULT 50.00;
    /* ============================================================================
QUESTION 7: INNER JOIN students and classes
============================================================================ */
SELECT s.student_name, c.class_name
FROM students s
INNER JOIN classes c ON s.class_id = c.class_id;

/* ============================================================================
QUESTION 8: Show all order_id, customer_name, product_name (LEFT JOIN)
============================================================================ */
SELECT
    o.order_id,
    c.customer_name,
    p.product_name
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

/* ============================================================================
QUESTION 9: Total sales amount for each product
============================================================================ */
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC;

/* ============================================================================
QUESTION 10: order_id, customer_name, and total quantity using INNER JOIN
============================================================================ */
SELECT
    o.order_id,
    c.customer_name,
    SUM(oi.quantity) AS total_quantity
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_name;

/* ============================================================================
MAVEN MOVIES DATABASE QUERIES
============================================================================ */

-- 1. Identify primary keys and foreign keys in DB
SELECT
    TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE CONSTRAINT_SCHEMA = DATABASE()
  AND (CONSTRAINT_NAME = 'PRIMARY' OR REFERENCED_TABLE_NAME IS NOT NULL);

-- 2. List all details of actors
SELECT * FROM actor;

-- 3. List all customer information
SELECT * FROM customer;

-- 4. List different countries
SELECT DISTINCT country FROM country;

-- 5. Display all active customers
SELECT * FROM customer WHERE active = 1;

-- 6. List rental IDs for customer with ID 1
SELECT rental_id FROM rental WHERE customer_id = 1;

-- 7. Display all films with rental_duration > 5
SELECT * FROM film WHERE rental_duration > 5;

-- 8. Count of films with replacement_cost between 15 and 20
SELECT COUNT(*) AS films_count
FROM film
WHERE replacement_cost > 15 AND replacement_cost < 20;

-- 9. Count of unique actor first names
SELECT COUNT(DISTINCT first_name) AS unique_first_names FROM actor;

-- 10. First 10 customers
SELECT * FROM customer LIMIT 10;

-- 11. First 3 customers whose first name starts with ‘b’
SELECT * FROM customer WHERE first_name LIKE 'b%' LIMIT 3;

-- 12. First 5 movies rated ‘G’
SELECT title FROM film WHERE rating = 'G' LIMIT 5;

-- 13. Customers whose first name starts with 'a'
SELECT * FROM customer WHERE first_name LIKE 'a%';

-- 14. Customers whose first name ends with 'a'
SELECT * FROM customer WHERE first_name LIKE '%a';

-- 15. First 4 cities starting and ending with 'a'
SELECT city FROM city WHERE city LIKE 'a%a' LIMIT 4;

-- 16. Customers whose first name has 'NI'
SELECT * FROM customer WHERE first_name LIKE '%NI%' OR first_name LIKE '%ni%';

-- 17. Customers whose first name has 'r' in second position
SELECT * FROM customer WHERE first_name LIKE '_r%';

-- 18. Customers whose first name starts with 'a' and length ≥ 5
SELECT * FROM customer WHERE first_name LIKE 'a%' AND CHAR_LENGTH(first_name) >= 5;

-- 19. Customers whose first name starts with 'a' and ends with 'o'
SELECT * FROM customer WHERE first_name LIKE 'a%o';

-- 20. Films with rating PG or PG-13
SELECT * FROM film WHERE rating IN ('PG','PG-13');

-- 21. Films with length between 50 and 100
SELECT * FROM film WHERE length BETWEEN 50 AND 100;

-- 22. Top 50 actors
SELECT * FROM actor ORDER BY actor_id LIMIT 50;

-- 23. Distinct film_ids from inventory
SELECT DISTINCT film_id FROM inventory;

/* ============================================================================
FUNCTIONS AND AGGREGATES
============================================================================ */

-- 1. Total number of rentals
SELECT COUNT(*) AS total_rentals FROM rental;

-- 2. Average rental duration of rented movies
SELECT AVG(f.rental_duration) AS avg_rental_duration
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;

-- 3. Display customers’ names in uppercase
SELECT UPPER(first_name), UPPER(last_name) FROM customer;

-- 4. Extract month from rental_date
SELECT rental_id, MONTH(rental_date) AS rental_month FROM rental;

-- 5. Count of rentals for each customer
SELECT customer_id, COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id
ORDER BY rental_count DESC;

-- 6. Total revenue by each store
SELECT store_id, SUM(amount) AS total_revenue FROM payment GROUP BY store_id;

-- 7. Total rentals per category
SELECT c.name AS category_name, COUNT(*) AS rental_count
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY rental_count DESC;

-- 8. Average rental rate by language
SELECT l.name AS language_name, AVG(f.rental_rate) AS avg_rate
FROM film f
JOIN language l ON f.language_id = l.language_id
GROUP BY l.name;
/* ============================================================================
JOINS — Connecting Multiple Tables
============================================================================ */

-- 9. Display movie title and customer’s name who rented it
SELECT f.title, c.first_name, c.last_name
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id;

-- 10. Actors who appeared in the film “Gone with the Wind”
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.title = 'Gone with the Wind';

-- 11. Customers and their total spending
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 12. Movies rented by each customer in city 'London'
SELECT c.first_name, c.last_name, GROUP_CONCAT(DISTINCT f.title) AS movies_rented
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE ci.city = 'London'
GROUP BY c.first_name, c.last_name;

/* ============================================================================
ADVANCED JOINS AND GROUP BY
============================================================================ */

-- 13. Top 5 most rented movies
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 5;

-- 14. Customers who rented from both stores (store_id 1 and 2)
SELECT c.customer_id, c.first_name, c.last_name
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE s.store_id IN (1, 2)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT s.store_id) = 2;

/* ============================================================================
WINDOW FUNCTIONS (MySQL 8+)
============================================================================ */

-- 1. Rank customers by total amount spent
SELECT customer_id, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
) AS t;

-- 2. Cumulative revenue by film over time
SELECT film_id, title, payment_date, amount,
       SUM(amount) OVER (PARTITION BY film_id ORDER BY payment_date
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM (
    SELECT f.film_id, f.title, p.payment_date, p.amount
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
) AS t
ORDER BY film_id, payment_date;

-- 3. Average rental duration grouped by film length
SELECT film_id, title,
       AVG(rental_duration) OVER (PARTITION BY ROUND(length/10)) AS avg_duration_for_group
FROM film;

-- 4. Top 3 films in each category by rental count
WITH film_rental_counts AS (
    SELECT f.film_id, f.title, fc.category_id, COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title, fc.category_id
)
SELECT category_id, film_id, title, rental_count
FROM (
    SELECT category_id, film_id, title, rental_count,
           ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY rental_count DESC) AS rn
    FROM film_rental_counts
) AS ranked
WHERE rn <= 3
ORDER BY category_id, rental_count DESC;

-- 5. Monthly revenue trend
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
       SUM(amount) AS revenue
FROM payment
GROUP BY year_month
ORDER BY year_month;

-- 6. Top 20% customers by total spending
WITH spend_data AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
),
ranked AS (
    SELECT customer_id, total_spent,
           CUME_DIST() OVER (ORDER BY total_spent DESC) AS percentile
    FROM spend_data
)
SELECT customer_id, total_spent
FROM ranked
WHERE percentile <= 0.20
ORDER BY total_spent DESC;

-- 7. Running total of rentals per category
WITH category_rentals AS (
    SELECT c.name AS category_name, COUNT(r.rental_id) AS rental_count
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY c.name
)
SELECT category_name, rental_count,
       SUM(rental_count) OVER (ORDER BY rental_count DESC) AS running_total
FROM category_rentals;

-- 8. Films rented less than category average
WITH film_counts AS (
    SELECT f.film_id, f.title, fc.category_id, COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title, fc.category_id
),
category_avg AS (
    SELECT category_id, AVG(rental_count) AS avg_rentals
    FROM film_counts
    GROUP BY category_id
)
SELECT fc.film_id, fc.title, fc.category_id, fc.rental_count, ca.avg_rentals
FROM film_counts fc
JOIN category_avg ca ON fc.category_id = ca.category_id
WHERE fc.rental_count < ca.avg_rentals
ORDER BY fc.category_id, fc.rental_count;

-- 9. Top 5 months with highest revenue
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, SUM(amount) AS revenue
FROM payment
GROUP BY month
ORDER BY revenue DESC
LIMIT 5;

-- 10. Difference between each customer's rentals and the average
WITH customer_rentals AS (
    SELECT customer_id, COUNT(*) AS total_rentals
    FROM rental
    GROUP BY customer_id
),
avg_rentals AS (
    SELECT AVG(total_rentals) AS avg_all FROM customer_rentals
)
SELECT c.customer_id, c.total_rentals,
       (c.total_rentals - a.avg_all) AS diff_from_avg
FROM customer_rentals c CROSS JOIN avg_rentals a
ORDER BY diff_from_avg DESC;
/* ============================================================================
NORMALIZATION & CTEs (Descriptive + Executable Examples)
============================================================================ */

/*
-----------------------------
Normalization Theory Overview
-----------------------------
Normalization is a systematic process of organizing data to reduce redundancy
and improve data integrity. Each “Normal Form” (NF) builds on the previous one.

1️⃣ FIRST NORMAL FORM (1NF)
-----------------------------------
A table is in 1NF if:
 • All columns contain atomic (indivisible) values.  
 • There are no repeating groups or arrays.  
Example violation → Customer table storing “phone_numbers = '123, 456'”.  
Fix → Create customer_phone(customer_id, phone_number).

2️⃣ SECOND NORMAL FORM (2NF)
-----------------------------------
A table is in 2NF if it is in 1NF and every non-key column depends on the
entire composite primary key (not just a part of it).  
Example → OrderDetails(order_id, product_id, product_name, price).  
product_name and price depend only on product_id → violation.  
Fix → Move product_name and price to Products table.

3️⃣ THIRD NORMAL FORM (3NF)
-----------------------------------
A table is in 3NF if it is in 2NF and has no transitive dependencies —
i.e. non-key attributes don’t depend on other non-key attributes.  
Example → Employee(emp_id, dept_id, dept_name). dept_name depends on dept_id → move to Department table.

Benefits → Consistency, smaller storage footprint, easier updates,
and faster queries for specific data relationships.
*/

/* ============================================================================
CTE #1 — List each actor and the number of films they appeared in
============================================================================ */
WITH actor_film_counts AS (
    SELECT a.actor_id,
           CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
           COUNT(fa.film_id) AS film_count
    FROM actor a
    LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id, actor_name
)
SELECT * FROM actor_film_counts ORDER BY film_count DESC;

/* ============================================================================
CTE #2 — Combine Film and Language information
============================================================================ */
WITH film_lang AS (
    SELECT f.film_id, f.title, l.name AS language_name, f.rental_rate
    FROM film f LEFT JOIN language l ON f.language_id = l.language_id
)
SELECT * FROM film_lang ORDER BY title;

/* ============================================================================
CTE #3 — Total revenue generated by each customer
============================================================================ */
WITH customer_revenue AS (
    SELECT customer_id, SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, cr.total_revenue
FROM customer c JOIN customer_revenue cr ON c.customer_id = cr.customer_id
ORDER BY cr.total_revenue DESC;

/* ============================================================================
CTE #4 — Rank films by rental duration using window function
============================================================================ */
WITH ranked_films AS (
    SELECT film_id, title, rental_duration,
           RANK() OVER (ORDER BY rental_duration DESC) AS rental_rank
    FROM film
)
SELECT * FROM ranked_films WHERE rental_rank <= 50 ORDER BY rental_rank;

/* ============================================================================
CTE #5 — Customers who have made more than 2 rentals
============================================================================ */
WITH cust_more_than_two AS (
    SELECT customer_id, COUNT(*) AS rental_count
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 2
)
SELECT c.customer_id, c.first_name, c.last_name, cm.rental_count
FROM cust_more_than_two cm JOIN customer c ON cm.customer_id = c.customer_id
ORDER BY cm.rental_count DESC;

/* ============================================================================
CTE #6 — Monthly rental count trend
============================================================================ */
WITH monthly_rentals AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS year_month, COUNT(*) AS rentals
    FROM rental
    GROUP BY year_month
)
SELECT * FROM monthly_rentals ORDER BY year_month;

/* ============================================================================
CTE #7 — Pairs of actors who appeared in the same film
============================================================================ */
WITH film_cast AS (
    SELECT film_id, actor_id FROM film_actor
)
SELECT f1.film_id,
       CONCAT(a1.first_name,' ',a1.last_name) AS actor1,
       CONCAT(a2.first_name,' ',a2.last_name) AS actor2
FROM film_cast f1
JOIN film_cast f2 ON f1.film_id = f2.film_id AND f1.actor_id < f2.actor_id
JOIN actor a1 ON f1.actor_id = a1.actor_id
JOIN actor a2 ON f2.actor_id = a2.actor_id
ORDER BY f1.film_id;

/* ============================================================================
CTE #8 — Recursive search for employees reporting to a manager
============================================================================ */
WITH RECURSIVE reports_tree AS (
    SELECT staff_id, first_name, last_name, reports_to
    FROM staff WHERE staff_id = 1  -- starting manager ID
    UNION ALL
    SELECT s.staff_id, s.first_name, s.last_name, s.reports_to
    FROM staff s INNER JOIN reports_tree rt ON s.reports_to = rt.staff_id
)
SELECT * FROM reports_tree ORDER BY reports_to, staff_id;
/* ============================================================================
CTE #9 — CTE for Date Calculations (Monthly rental counts)
============================================================================ */
WITH monthly_stats AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS year_month,
           COUNT(*) AS rental_count
    FROM rental
    GROUP BY year_month
)
SELECT year_month, rental_count
FROM monthly_stats
ORDER BY year_month;

/* ============================================================================
CTE #10 — CTE and Filtering (Customers who rented more than twice)
============================================================================ */
WITH rental_counts AS (
    SELECT customer_id, COUNT(*) AS total_rentals
    FROM rental
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, rc.total_rentals
FROM rental_counts rc
JOIN customer c ON c.customer_id = rc.customer_id
WHERE rc.total_rentals > 2
ORDER BY rc.total_rentals DESC;

/* ============================================================================
CTE #11 — CTE with Window Function (Rank films by rental_duration)
============================================================================ */
WITH film_duration_rank AS (
    SELECT film_id, title, rental_duration,
           RANK() OVER (ORDER BY rental_duration DESC) AS duration_rank
    FROM film
)
SELECT * FROM film_duration_rank
ORDER BY duration_rank
LIMIT 20;

/* ============================================================================
CTE #12 — CTE for Aggregation (Total revenue by each customer)
============================================================================ */
WITH customer_payment_summary AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       cps.total_spent
FROM customer_payment_summary cps
JOIN customer c ON cps.customer_id = c.customer_id
ORDER BY cps.total_spent DESC;

/* ============================================================================
OPTIONAL TEST TABLES — Create minimal local setup for independent testing
============================================================================ */
DROP TABLE IF EXISTS classes;
CREATE TABLE classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(50)
);

DROP TABLE IF EXISTS students;
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100),
    class_id INT,
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100)
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2) DEFAULT 50.00
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

/* Sample Inserts for quick validation */
INSERT INTO classes (class_name) VALUES ('Math'), ('Science');
INSERT INTO students (student_name, class_id) VALUES ('Alice',1), ('Bob',2);

INSERT INTO customers (customer_name) VALUES ('Customer A'), ('Customer B');
INSERT INTO products (product_name, price) VALUES ('Widget', 60.00), ('Gadget', 40.00);
INSERT INTO orders (customer_id, order_date) VALUES (1, NOW()), (2, NOW());
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1,1,2,60.00), (2,2,1,40.00);