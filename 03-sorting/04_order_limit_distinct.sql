-- =============================================================
-- 04 — ORDER BY, LIMIT, DISTINCT: shaping the result set
-- Database: office
-- =============================================================
-- These three run AFTER the rows have been selected and filtered.
-- They change how the result is presented, not which rows qualify.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. ORDER BY — sort the output
-- -------------------------------------------------------------
-- ⚠️ Without ORDER BY, row order is NOT guaranteed. It may look stable
--    today and change tomorrow. If order matters, say so explicitly.

-- ASC = ascending (A→Z, small→large). It is the default, so it's optional.
SELECT first_name, salary
FROM employees
ORDER BY first_name ASC;

-- DESC = descending (Z→A, large→small).
SELECT first_name, salary
FROM employees
ORDER BY salary DESC;

-- Sort by more than one column: ties in the first are broken by the second.
SELECT department_id, first_name, salary
FROM employees
ORDER BY department_id ASC, salary DESC;


-- -------------------------------------------------------------
-- 2. LIMIT — cap the number of rows returned
-- -------------------------------------------------------------
-- Just the first 2 rows. Useful for peeking at a big table.
SELECT *
FROM employees
LIMIT 2;

-- LIMIT without ORDER BY gives you an ARBITRARY 2 rows.
-- LIMIT with ORDER BY gives you a MEANINGFUL 2 rows.


-- -------------------------------------------------------------
-- 3. The three together — clause order matters
-- -------------------------------------------------------------
-- SQL requires this exact sequence:
--     SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
--
-- Read this query the way the database executes it:
--   1. FROM     take the employees table
--   2. WHERE    keep only rows with salary > 7000
--   3. ORDER BY sort those by first_name, Z→A
--   4. LIMIT    return the first 2 of the sorted result
SELECT *
FROM employees
WHERE salary > 7000
ORDER BY first_name DESC
LIMIT 2;

-- This ordering is why "top N" queries work:
--   the 3 highest-paid employees.
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- OFFSET skips rows first — this is how pagination is built.
-- Page 2, three per page:
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;


-- -------------------------------------------------------------
-- 4. DISTINCT — remove duplicate rows
-- -------------------------------------------------------------
-- Every first name that appears, each listed once.
SELECT DISTINCT first_name
FROM employees;

-- ⚠️ DISTINCT applies to the WHOLE row, not just the first column.
--    This does NOT give one row per first_name — it gives one row per
--    unique (first_name, last_name) PAIR, which is almost every row.
SELECT DISTINCT first_name, last_name
FROM employees;

-- To answer "how many different first names are there?", use COUNT DISTINCT:
SELECT COUNT(DISTINCT first_name) AS unique_first_names
FROM employees;

-- Common real use: what values does this column actually hold?
SELECT DISTINCT department_id FROM employees;
SELECT DISTINCT job_id        FROM employees;


-- =============================================================
-- TAKEAWAYS
--   • No ORDER BY ⇒ no guaranteed order
--   • LIMIT is only meaningful together with ORDER BY
--   • Clause order is fixed: WHERE → ORDER BY → LIMIT
--   • DISTINCT de-duplicates the entire selected row
--   • LIMIT n OFFSET m = pagination
-- =============================================================
