-- =============================================================
-- 21 — Window functions: a first look at OVER()
-- Database: office
-- =============================================================
-- Everything so far that aggregates (SUM, COUNT, AVG...) has collapsed
-- rows down via GROUP BY. A window function computes the same kind of
-- aggregate, but WITHOUT collapsing anything — every row survives,
-- with the aggregate value attached alongside it.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The familiar starting point — GROUP BY collapses
-- -------------------------------------------------------------
-- One row per department. Individual employees are gone — you can't
-- get first_name back out of this result; GROUP BY threw it away.
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id;

-- No GROUP BY at all collapses the WHOLE table to one row:
SELECT SUM(salary) FROM employees;


-- -------------------------------------------------------------
-- 2. The new idea — OVER() keeps every row
-- -------------------------------------------------------------
-- SUM(e.salary) OVER() computes the exact same number as
-- `SELECT SUM(salary) FROM employees` — the company-wide total — but
-- instead of collapsing every row into that one total, it attaches the
-- total to EVERY row, alongside that row's own columns.
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       e.department_id,
       SUM(e.salary) OVER() AS company_total_salary
FROM employees e;

-- One row per EMPLOYEE — not per department, not one row overall —
-- each one carrying the same company-wide total next to their own
-- name. That's the entire point of a window function: it adds an
-- aggregate as another column, rather than using the aggregate to
-- decide how many rows survive. GROUP BY simply cannot do this; the
-- moment more than one row shares a department, GROUP BY is forced to
-- throw away which individual employee each row was.
--
-- The empty parentheses in OVER() mean "the window is the entire
-- result set" — no partitioning. `OVER (PARTITION BY department_id)`
-- would instead compute the sum PER department while STILL keeping
-- every individual row — file 23 runs it.


-- -------------------------------------------------------------
-- 3. Side by side, one more time
-- -------------------------------------------------------------
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id;
-- → few rows, one per department, no individual employee detail

SELECT e.employee_id, e.department_id, SUM(e.salary) OVER() AS total
FROM employees e;
-- → one row per employee, every row carrying the same overall total


-- -------------------------------------------------------------
-- 4. What's next
-- -------------------------------------------------------------
-- The class agenda also named RANK, ROW_NUMBER, LEAD, LAG, and
-- DENSE_RANK. Those — plus PARTITION BY in action — are covered in
-- file 23.


-- =============================================================
-- TAKEAWAYS
--   • GROUP BY collapses rows into one per group; a window function
--     (OVER()) keeps every row and attaches the aggregate alongside it
--   • OVER() with empty parentheses = window is the whole result set
--   • PARTITION BY (inside OVER) scopes the aggregate per group while
--     still keeping every row — see file 23
--   • RANK / DENSE_RANK / LEAD / NTILE — file 23
-- =============================================================
