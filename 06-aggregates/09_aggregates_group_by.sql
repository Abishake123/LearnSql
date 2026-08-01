-- =============================================================
-- 09 — Aggregates and GROUP BY
-- Database: office
-- =============================================================
-- An aggregate collapses many rows into one value:
--   COUNT()  SUM()  AVG()  MIN()  MAX()
--
-- GROUP BY says WHICH rows collapse together. Without it, the whole
-- table is one group and you get exactly one row back.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Aggregates over the whole table
-- -------------------------------------------------------------
SELECT
    COUNT(*)    AS headcount,
    SUM(salary) AS total_payroll,
    AVG(salary) AS average_salary,
    MIN(salary) AS lowest,
    MAX(salary) AS highest
FROM employees;


-- -------------------------------------------------------------
-- 2. GROUP BY — one result row per group
-- -------------------------------------------------------------
-- "How many employees in each department?"
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY employee_count DESC;

-- THE RULE: every column in SELECT must either
--   (a) appear in GROUP BY, or
--   (b) be wrapped in an aggregate function.
-- Anything else is ambiguous — if 5 rows collapse into one, which of the
-- 5 first_names should the database show you? There is no right answer.


-- -------------------------------------------------------------
-- 3. ONLY_FULL_GROUP_BY — the error we hit in class
-- -------------------------------------------------------------
-- MySQL enforces the rule above through a setting called ONLY_FULL_GROUP_BY.
-- Break the rule and you get:
--   "Expression #1 of SELECT list is not in GROUP BY clause and contains
--    a nonaggregated column ... incompatible with sql_mode=only_full_group_by"
--
-- In class we switched it off to get moving:
SET SESSION sql_mode = REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', '');

-- ⚠️ That silences the error. It does NOT make the query correct — MySQL
--    now picks an arbitrary value from each group. Treat it as a temporary
--    workaround. The real fix is to write a proper GROUP BY.
--
-- Put it back when you're done:
--   SET SESSION sql_mode = CONCAT(@@sql_mode, ',ONLY_FULL_GROUP_BY');


-- -------------------------------------------------------------
-- 4. Employee count per region — the right way
-- -------------------------------------------------------------
-- In class we wrote a version with a subquery and no GROUP BY, which
-- needed ONLY_FULL_GROUP_BY disabled to run. Here it is done properly:
-- join the whole chain, then group by region.
SELECT
    r.region_name,
    COUNT(e.employee_id) AS employee_count
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id
GROUP BY r.region_name
ORDER BY employee_count DESC;

-- ⚠️ COUNT(*) vs COUNT(column) matters a lot here.
--    COUNT(*)              counts rows, including LEFT-JOIN NULL rows → never 0
--    COUNT(e.employee_id)  ignores NULLs → correctly reports 0 for empty regions
-- Use COUNT(<column from the joined table>) when counting across a LEFT JOIN.


-- -------------------------------------------------------------
-- 5. Countries per region
-- -------------------------------------------------------------
-- Every region and how many countries it contains — including regions
-- with none, thanks to the LEFT JOIN starting from regions.
SELECT
    r.region_name,
    COUNT(c.country_id) AS country_count
FROM regions r
LEFT JOIN countries c ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY country_count DESC;

-- Grouping by region_id as well as region_name is good practice: the id is
-- the real identity. Two regions could theoretically share a name.


-- -------------------------------------------------------------
-- 6. HAVING — WHERE, but for groups
-- -------------------------------------------------------------
--   WHERE  filters ROWS   — runs BEFORE grouping
--   HAVING filters GROUPS — runs AFTER grouping
-- You cannot use an aggregate in WHERE; it doesn't exist yet at that point.

-- Departments with more than 5 employees:
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY employee_count DESC;

-- Both together — count only well-paid staff, then keep busy departments:
SELECT
    department_id,
    COUNT(*)    AS well_paid_count,
    AVG(salary) AS avg_salary
FROM employees
WHERE salary > 5000              -- filters rows first
GROUP BY department_id
HAVING COUNT(*) >= 2             -- filters the resulting groups
ORDER BY avg_salary DESC;


-- -------------------------------------------------------------
-- 7. Counting with a date filter
-- -------------------------------------------------------------
-- "How many people were hired on a given date, per region?"
SELECT
    r.region_name,
    COUNT(e.employee_id) AS hires
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id
WHERE e.hire_date = '2026-08-01'
GROUP BY r.region_name;

-- Today's hires, without hardcoding the date:
SELECT
    r.region_name,
    COUNT(e.employee_id) AS hires_today
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id
WHERE e.hire_date = CURDATE()
GROUP BY r.region_name;

-- ⚠️ If hire_date were a DATETIME rather than a DATE, `= CURDATE()` would
--    only match rows stored at exactly midnight. For DATETIME columns use
--    a range instead:
--        WHERE hire_date >= CURDATE()
--          AND hire_date <  CURDATE() + INTERVAL 1 DAY
--    Check with DESCRIBE employees; before you write date filters.

-- Hires per month across the whole table:
SELECT
    YEAR(hire_date)  AS yr,
    MONTH(hire_date) AS mth,
    COUNT(*)         AS hires
FROM employees
GROUP BY YEAR(hire_date), MONTH(hire_date)
ORDER BY yr, mth;


-- =============================================================
-- TAKEAWAYS
--   • Aggregates: COUNT SUM AVG MIN MAX
--   • GROUP BY defines the groups; one output row per group
--   • Every SELECT column must be grouped or aggregated
--   • ONLY_FULL_GROUP_BY enforces that — don't disable it as a habit
--   • COUNT(col) not COUNT(*) when counting across a LEFT JOIN
--   • WHERE filters rows, HAVING filters groups
-- =============================================================
