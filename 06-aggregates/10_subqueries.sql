-- =============================================================
-- 10 — Subqueries: a query inside a query
-- Database: office
-- =============================================================
-- A subquery runs first; its result is fed to the outer query.
-- Use one when the value you want to filter by is itself the answer to
-- another question.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The problem a subquery solves
-- -------------------------------------------------------------
-- You want countries in the "Africa" region, but you only know the NAME,
-- and `countries` stores the region_id.

-- Without a subquery: two steps, and you hardcode the answer in between.
SELECT region_id FROM regions WHERE region_name LIKE '%Africa%';   -- → 4
SELECT * FROM countries WHERE region_id = 4;                       -- hardcoded ⚠️

-- Hardcoding breaks the moment the ids change. Let SQL look it up:
SELECT *
FROM countries
WHERE region_id = (
    SELECT region_id
    FROM regions
    WHERE region_name LIKE '%Africa%'
);


-- -------------------------------------------------------------
-- 2. Scalar subquery — must return exactly ONE value
-- -------------------------------------------------------------
-- With `=`, the subquery must return one row and one column. If it returns
-- more, MySQL errors: "Subquery returns more than 1 row".
SELECT region_id
FROM regions
WHERE region_name LIKE '%America%';
-- → this returns TWO rows (North America, South America), so `=` fails.

-- ✅ Use IN when the subquery can return several values:
SELECT *
FROM countries
WHERE region_id IN (
    SELECT region_id
    FROM regions
    WHERE region_name LIKE '%America%'
);

-- Rule: `=` for one value, `IN` for a list. When unsure, use IN.


-- -------------------------------------------------------------
-- 3. Counting through a subquery
-- -------------------------------------------------------------
-- How many countries are in Africa?
SELECT COUNT(*) AS african_countries
FROM countries
WHERE region_id = (
    SELECT region_id FROM regions WHERE region_name LIKE '%Africa%'
);

-- The same answer via a JOIN. Usually preferred: it's readable and the
-- optimiser handles it better.
SELECT r.region_name, COUNT(c.country_id) AS country_count
FROM regions r
LEFT JOIN countries c ON c.region_id = r.region_id
WHERE r.region_name LIKE '%Africa%'
GROUP BY r.region_name;


-- -------------------------------------------------------------
-- 4. Subqueries with aggregates — where they really shine
-- -------------------------------------------------------------
-- Employees earning more than the company average. You cannot write
-- `WHERE salary > AVG(salary)` — aggregates aren't allowed in WHERE.
-- The subquery computes the average first, then WHERE compares against it.
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- The single highest-paid employee (handles ties, unlike LIMIT 1):
SELECT first_name, last_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);


-- -------------------------------------------------------------
-- 5. Correlated subquery — re-runs for each outer row
-- -------------------------------------------------------------
-- Note `e.department_id` inside the subquery: it references the outer
-- query, so the average is recomputed per department.
-- Employees earning above their OWN department's average:
SELECT e.first_name, e.department_id, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- ⚠️ Powerful but slow — it executes once per outer row. Fine on small
--    tables, a problem on large ones.


-- -------------------------------------------------------------
-- 6. Subquery in FROM — a "derived table"
-- -------------------------------------------------------------
-- Treat a query's result as a temporary table. The alias (here `dept`)
-- is REQUIRED by MySQL.
SELECT dept.department_id, dept.headcount
FROM (
    SELECT department_id, COUNT(*) AS headcount
    FROM employees
    GROUP BY department_id
) AS dept
WHERE dept.headcount > 3
ORDER BY dept.headcount DESC;


-- -------------------------------------------------------------
-- 7. EXISTS — "is there at least one?"
-- -------------------------------------------------------------
-- Stops at the first match, so it can be faster than IN.
-- Employees who have at least one dependent:
SELECT e.employee_id, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM dependents dp
    WHERE dp.employee_id = e.employee_id
);

-- NOT EXISTS — employees with no dependents:
SELECT e.employee_id, e.first_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM dependents dp WHERE dp.employee_id = e.employee_id
);


-- =============================================================
-- TAKEAWAYS
--   • A subquery replaces a hardcoded value with a lookup
--   • `=` needs exactly one row back; `IN` accepts many
--   • Aggregates can't go in WHERE — put them in a subquery
--   • Correlated subqueries re-run per row; watch performance
--   • Subquery in FROM = derived table, and it needs an alias
--   • If a JOIN expresses it clearly, prefer the JOIN
-- =============================================================
