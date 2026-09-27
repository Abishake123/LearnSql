-- =============================================================
-- 23 — Window functions, part 2: PARTITION BY, RANK, DENSE_RANK,
--      LEAD, NTILE
-- Database: office
-- =============================================================
-- File 21 introduced OVER() — an aggregate that keeps every row.
-- This session filled in the rest of the toolkit: scoping the window
-- per group (PARTITION BY), ranking rows, and peeking at the NEXT row.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. PARTITION BY — a separate window per group
-- -------------------------------------------------------------
-- Recap of the GROUP BY version: one row per department.
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id;

-- Now the window version, scoped PER DEPARTMENT. Every employee row
-- survives, and each one carries the total of ITS OWN department.
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       e.department_id,
       e.salary,
       SUM(e.salary) OVER (PARTITION BY e.department_id) AS dept_total_salary
FROM employees e
WHERE e.department_id = 10;

-- Sanity check — add these salaries up by hand and compare:
SELECT e.first_name, e.salary
FROM employees e
WHERE e.department_id = 10;

-- Try it: add `ORDER BY e.employee_id` inside the OVER(), after the
-- PARTITION BY. The total stops being fixed and becomes a RUNNING total
-- — each row sums itself plus every row before it in that order.


-- -------------------------------------------------------------
-- 2. RANK vs DENSE_RANK
-- -------------------------------------------------------------
-- Both number the rows in the order given by the OVER(ORDER BY ...).
-- They only differ in what happens AFTER a tie.
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
       e.salary,
       RANK() OVER (ORDER BY e.salary DESC) AS salary_rank
FROM employees e;

SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
       e.salary,
       DENSE_RANK() OVER (ORDER BY e.salary DESC) AS salary_rank
FROM employees e;

-- Two people tied on 17000 for 2nd place:
--   RANK()        → 1, 2, 2, 4   (skips 3 — "two people are ahead of you")
--   DENSE_RANK()  → 1, 2, 2, 3   (no gaps — "you're the 3rd distinct salary")
-- Use DENSE_RANK for "the Nth highest salary" questions.
--
-- The third member of the family, ROW_NUMBER(), was named on the agenda
-- but not run: it gives 1, 2, 3, 4 — every row a unique number, with
-- ties broken arbitrarily.


-- -------------------------------------------------------------
-- 3. Ranking INSIDE each department
-- -------------------------------------------------------------
-- PARTITION BY + ORDER BY together: the ranking restarts at 1 for
-- every department.
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
       e.salary,
       e.department_id,
       RANK() OVER (PARTITION BY e.department_id
                    ORDER BY e.salary DESC) AS dept_rank
FROM employees e;


-- -------------------------------------------------------------
-- 4. "Highest paid in each department" — you can't WHERE a window
-- -------------------------------------------------------------
-- ⚠️ What we tried first:
--
--   SELECT ..., RANK() OVER (...) AS ranks
--   FROM employees e
--   WHERE ranks = 1;
--
--   → ERROR 1054: Unknown column 'ranks' in 'where clause'
--
-- (In class there was also a stray `;` after `FROM employees e`, which
-- turns `WHERE ranks = 1` into a separate, broken statement — but even
-- without it, the query fails.)
--
-- Why: WHERE runs BEFORE the SELECT list is computed, and window
-- functions are computed as part of the SELECT list. At WHERE time,
-- `ranks` doesn't exist yet.
--
-- ✅ The fix: compute the rank in a derived table (file 16), then filter
-- the finished result from the outside.
SELECT *
FROM (
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
           e.salary,
           e.department_id,
           RANK() OVER (PARTITION BY e.department_id
                        ORDER BY e.salary DESC) AS dept_rank
    FROM employees e
) dt
WHERE dt.dept_rank = 1;
-- A department with a tie at the top returns BOTH people — that's
-- RANK doing its job. Use ROW_NUMBER if you need exactly one per group.


-- -------------------------------------------------------------
-- 5. LEAD — looking at the next row
-- -------------------------------------------------------------
-- LEAD(col) = the value of col from the NEXT row in the window's order.
-- LAG(col)  = the value from the PREVIOUS row.
-- "How much more does each person earn than the next person down?"
SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
       e.salary,
       LEAD(e.salary) OVER (ORDER BY e.salary DESC) AS next_salary,
       e.salary - LEAD(e.salary) OVER (ORDER BY e.salary DESC) AS gap
FROM employees e;

-- ⚠️ In class this column was aliased `lag_salary` — but it's LEAD, not
-- LAG. The query works; the name lies. Sorted high → low, LEAD gives
-- the next LOWER salary. LAG over the same order would give the
-- previous, HIGHER one.
--
-- The last row has no next row, so LEAD returns NULL — and
-- salary - NULL is NULL.


-- -------------------------------------------------------------
-- 6. Replacing that NULL — COALESCE and IFNULL
-- -------------------------------------------------------------
-- Writing LEAD(...) twice is repetitive. Compute it once in a derived
-- table, then do the arithmetic outside:
SELECT dt.*,
       COALESCE(dt.salary - dt.next_salary, 'Nil') AS gap
FROM (
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS name,
           e.salary,
           LEAD(e.salary) OVER (ORDER BY e.salary DESC) AS next_salary
    FROM employees e
) dt;

-- The two NULL-replacing functions:
SELECT IFNULL('Hhhhh', 'Hi');         -- → 'Hhhhh' (first arg isn't NULL)
SELECT COALESCE(NULL, NULL, 'Hi');    -- → 'Hi'    (first non-NULL of ANY number of args)
-- IFNULL takes exactly two arguments and is MySQL-only.
-- COALESCE takes as many as you like and is standard SQL — prefer it.
--
-- ⚠️ COALESCE(number, 'Nil') mixes a number and a string, so the whole
-- column becomes TEXT. Fine for display; if you need to keep doing
-- maths on it, use COALESCE(..., 0) instead.


-- -------------------------------------------------------------
-- 7. Percentage of the total — SUM() OVER() doing real work
-- -------------------------------------------------------------
-- Each employee's salary as a % of the whole payroll. Without a window
-- function this would need a subquery for the total.
SELECT e.first_name,
       e.salary,
       SUM(e.salary) OVER () AS total_salary,
       ROUND(e.salary / SUM(e.salary) OVER () * 100, 2) AS pct_of_total
FROM employees e;

-- Same thing via a derived table — useful once the total is needed
-- more than once (file 24 wraps the % maths in a stored function):
SELECT dt.*,
       ROUND(dt.salary / dt.total_salary * 100, 2) AS pct_of_total
FROM (
    SELECT e.first_name, e.salary, SUM(e.salary) OVER () AS total_salary
    FROM employees e
) dt;


-- -------------------------------------------------------------
-- 8. NTILE — split the rows into N equal buckets
-- -------------------------------------------------------------
-- File 15 bucketed salaries with CASE, using thresholds WE picked:
SELECT first_name,
       salary,
       CASE
           WHEN salary > 15000 THEN 'High'
           WHEN salary > 10000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_tag
FROM employees;

-- NTILE(4) instead splits the sorted rows into 4 groups of (roughly)
-- equal SIZE — quartiles. No thresholds; bucket 1 is simply the top
-- quarter of earners, whatever their salaries happen to be.
SELECT first_name,
       salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
-- CASE  → buckets by VALUE (a bucket can be empty or hold everyone)
-- NTILE → buckets by COUNT (every bucket gets its fair share of rows)


-- =============================================================
-- TRY IT YOURSELF (set in class, no solution here yet)
--   1. Show each employee's department headcount on their own row —
--      WITHOUT COUNT(*) OVER (...). (Hint: a join to a GROUP BY.)
--   2. Build a salary ranking WITHOUT any window function. (Hint: for
--      each employee, count how many salaries are higher.)
--   3. CROSS JOIN employees with their managers and work out the
--      years-of-experience gap between each manager and reportee.
-- =============================================================


-- =============================================================
-- TAKEAWAYS
--   • OVER (PARTITION BY x) = a separate window per value of x
--   • Adding ORDER BY inside OVER() turns SUM into a running total
--   • RANK leaves gaps after ties; DENSE_RANK doesn't
--   • You can't filter on a window column in WHERE — wrap the query in
--     a derived table and filter outside
--   • LEAD = next row, LAG = previous row; the edge row gets NULL
--   • COALESCE (standard, any number of args) > IFNULL (MySQL, two)
--   • NTILE(n) splits rows into n equal-COUNT buckets; CASE splits by value
-- =============================================================
