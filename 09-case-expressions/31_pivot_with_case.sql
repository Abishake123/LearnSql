-- =============================================================
-- 31 — Pivoting: turning row values into columns with CASE
-- Database: office
-- =============================================================
-- GROUP BY gives you one ROW per combination. Sometimes you want a
-- grid instead — departments down the side, job titles (or regions)
-- across the top. MySQL has no PIVOT keyword; the standard trick is
-- CASE inside an aggregate (file 15), a.k.a. "conditional aggregation".
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The building block: counting only the rows you care about
-- -------------------------------------------------------------
-- CASE turns each row into a 1 (match) or 0 (no match); SUM adds up
-- the 1s. The result is a count of matching rows.
SELECT SUM(CASE WHEN department_id = 9 THEN 1 ELSE 0 END) AS executives
FROM employees;
-- Same answer as `SELECT COUNT(*) FROM employees WHERE department_id = 9`
-- — but because the condition lives INSIDE the SELECT, you can put
-- several of them side by side. That's the whole pivot trick.


-- -------------------------------------------------------------
-- 2. The "long" version — one row per (department, job)
-- -------------------------------------------------------------
SELECT d.department_name,
       j.job_title,
       COUNT(*) AS headcount
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN jobs j        ON j.job_id = e.job_id
GROUP BY e.department_id, e.job_id;
-- Correct, but hard to scan: to compare departments you have to hunt
-- through the rows.


-- -------------------------------------------------------------
-- 3. The pivot — one row per department, one COLUMN per job
-- -------------------------------------------------------------
SELECT d.department_name,
       SUM(CASE WHEN j.job_title = 'Stock Clerk' THEN 1 ELSE 0 END) AS stock_clerk,
       SUM(CASE WHEN j.job_title = 'Programmer'  THEN 1 ELSE 0 END) AS programmer
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN jobs j        ON j.job_id = e.job_id
GROUP BY e.department_id;
-- Every department appears; the columns count how many of each job
-- it has (0 where it has none).
--
-- The catch: you must list every column by hand. A new job title
-- won't appear until you add another SUM(CASE ...) line.


-- -------------------------------------------------------------
-- 4. A bigger pivot — employees per department, per region
-- -------------------------------------------------------------
-- ⚠️ What we tried first:
--
--   SELECT department_id, COUNT(employee_id) FROM employees
--   GROUP BY deparmtnet_id, region_id;
--
--   → ERROR 1054: Unknown column 'deparmtnet_id' in 'group statement'
--
-- Two problems: the typo, and region_id doesn't live on employees at
-- all. Region is four hops away (file 08):
--   employees → departments → locations → countries → regions
--
-- COUNT(CASE WHEN ... THEN e.employee_id END) is the other spelling of
-- the trick: with no ELSE, a non-match gives NULL, and COUNT skips
-- NULLs — so it counts only the matches.
SELECT d.department_name,
       COUNT(CASE WHEN r.region_name = 'Americas'               THEN e.employee_id END) AS americas,
       COUNT(CASE WHEN r.region_name = 'Europe'                 THEN e.employee_id END) AS europe,
       COUNT(CASE WHEN r.region_name = 'Asia'                   THEN e.employee_id END) AS asia,
       COUNT(CASE WHEN r.region_name = 'Middle East and Africa' THEN e.employee_id END) AS middle_east_africa
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN locations l   ON l.location_id = d.location_id
JOIN countries c   ON c.country_id = l.country_id
JOIN regions r     ON r.region_id = c.region_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;

-- Check the exact spellings before writing the CASEs:
SELECT * FROM regions;

-- SUM(CASE ... THEN 1 ELSE 0 END)  and  COUNT(CASE ... THEN x END)
-- give the same answer. Pick one and be consistent.


-- -------------------------------------------------------------
-- 5. Not a pivot, but ran alongside: top salary per department
-- -------------------------------------------------------------
SELECT d.department_name, MAX(e.salary) AS top_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id;
-- This gives the top SALARY. To get WHO earns it, use RANK() in a
-- derived table (file 23, section 4).
--
-- Grouping by d.department_id but selecting d.department_name works
-- under ONLY_FULL_GROUP_BY because department_id is the primary key —
-- the name is fully determined by it (file 12, functional dependency).


-- =============================================================
-- TAKEAWAYS
--   • MySQL has no PIVOT keyword — use an aggregate around CASE
--   • SUM(CASE WHEN cond THEN 1 ELSE 0 END) counts matching rows
--   • COUNT(CASE WHEN cond THEN col END) does the same via NULLs
--   • One CASE per output column, written by hand
--   • Region isn't on employees — walk the join chain to get it
-- =============================================================
