-- =============================================================
-- 02 — WHERE: filtering rows
-- Database: office
-- =============================================================
-- WHERE runs once per row and keeps only the rows where the condition is TRUE.
--
--   SELECT <columns>
--   FROM   <table>
--   WHERE  <condition>;
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Equality
-- -------------------------------------------------------------
-- Numbers need no quotes.
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary = 7000;

-- Text does. Use SINGLE quotes — the SQL standard.
-- (MySQL also accepts "David", but single quotes work in every database.)
SELECT *
FROM employees
WHERE first_name = 'David';

-- Filtering on the primary key returns at most one row.
SELECT *
FROM employees
WHERE employee_id = 105;


-- -------------------------------------------------------------
-- 2. Not-equal
-- -------------------------------------------------------------
-- != and <> are identical. <> is the SQL standard; != is more familiar.
SELECT COUNT(*)
FROM employees
WHERE salary != 7000;

SELECT COUNT(*)
FROM employees
WHERE salary <> 7000;

-- ⚠️ CAREFUL: a NULL salary is neither = 7000 nor != 7000.
-- NULL means "unknown", and comparing to unknown gives unknown, not TRUE.
-- So these two counts will NOT add up to COUNT(*) if any salary is NULL.
-- To test for NULL you must use IS NULL / IS NOT NULL:
SELECT COUNT(*) FROM employees WHERE salary IS NULL;


-- -------------------------------------------------------------
-- 3. Comparison operators
-- -------------------------------------------------------------
SELECT * FROM employees WHERE salary >  7000;
SELECT * FROM employees WHERE salary >= 7000;
SELECT * FROM employees WHERE salary <  5000;


-- -------------------------------------------------------------
-- 4. BETWEEN — inclusive range
-- -------------------------------------------------------------
-- BETWEEN a AND b is shorthand for  >= a AND <= b.  Both ends included.
SELECT *
FROM employees
WHERE salary BETWEEN 5000 AND 7000;

-- Identical result, written the long way:
SELECT *
FROM employees
WHERE salary >= 5000
  AND salary <= 7000;


-- -------------------------------------------------------------
-- 5. BETWEEN on dates — and the mistake we made in class
-- -------------------------------------------------------------
-- ⚠️ THIS RETURNS ZERO ROWS. Why?
--    BETWEEN needs the SMALLER value first. We wrote 1999 then 1997,
--    which asks for "hire_date >= 1999-01-01 AND hire_date <= 1997-01-01".
--    No date can satisfy both. SQL does not warn you — it just returns nothing.
SELECT *
FROM employees
WHERE hire_date BETWEEN DATE('1999-01-01') AND DATE('1997-01-01');

-- ✅ THE FIX — low bound first, high bound second.
SELECT *
FROM employees
WHERE hire_date BETWEEN '1997-01-01' AND '1999-01-01';

-- Lesson: an empty result is not proof there's no matching data.
-- It often means the condition is wrong. Always sanity-check with a
-- broader query first.

-- Exact date match. MySQL happily compares a DATE column to a
-- 'YYYY-MM-DD' string, so the DATE() wrapper is optional here.
SELECT * FROM employees WHERE hire_date = DATE('1987-06-17');
SELECT * FROM employees WHERE hire_date = '1987-06-17';

-- Check the column's type before writing date filters —
-- DATE and DATETIME behave differently at midnight boundaries.
DESCRIBE employees;


-- -------------------------------------------------------------
-- 6. IN — match any value in a list
-- -------------------------------------------------------------
-- Look at what job_ids actually exist before filtering on them.
SELECT * FROM jobs;

SELECT *
FROM employees
WHERE job_id IN (6, 7, 8);

-- IN is just a shorter OR chain:
SELECT *
FROM employees
WHERE job_id = 6 OR job_id = 7 OR job_id = 8;

-- NOT IN inverts it.
SELECT *
FROM employees
WHERE job_id NOT IN (6, 7, 8);


-- -------------------------------------------------------------
-- 7. Combining conditions: AND / OR
-- -------------------------------------------------------------
-- AND binds tighter than OR. When you mix them, use parentheses so the
-- intent is explicit — do not rely on precedence.
SELECT *
FROM employees
WHERE salary > 5000
  AND department_id = 9;

SELECT *
FROM employees
WHERE (salary > 15000 OR job_id = 4)
  AND department_id IS NOT NULL;


-- =============================================================
-- TAKEAWAYS
--   • WHERE keeps rows where the condition is TRUE
--   • Single quotes for text, none for numbers
--   • BETWEEN is inclusive and needs LOW value first
--   • NULL is not equal to anything — use IS NULL
--   • IN (…) is a compact OR
--   • Zero rows usually means a wrong condition, not missing data
-- =============================================================
