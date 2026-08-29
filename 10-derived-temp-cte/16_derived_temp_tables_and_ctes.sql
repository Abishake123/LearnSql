-- =============================================================
-- 16 — Three ways to name an intermediate result: derived tables,
--       temporary tables, and CTEs
-- Database: office
-- =============================================================
-- All three solve the same problem — "I want to build on a query's
-- result without retyping it" — at three different scopes:
--   derived table   scoped to the ONE query it's nested in
--   CTE              scoped to the ONE statement (cleaner syntax,
--                     same lifetime as a derived table)
--   temporary table  scoped to the WHOLE SESSION — a real table you
--                     can INSERT/UPDATE/DELETE against
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Derived table — the same query, filtered two ways
-- -------------------------------------------------------------
-- File 09 covered a brief derived-table example. Here's a direct
-- head-to-head with HAVING, on the same question: which departments
-- have an average salary above 10,000?

-- HAVING — concise, one statement:
SELECT d.department_name, AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING avg_salary > 10000;

-- Derived table + WHERE — same result, more verbose, but the
-- aggregated result is now a first-class "table" you could join to
-- something else, paginate, or filter further:
SELECT *
FROM (
    SELECT d.department_name, AVG(e.salary) AS avg_salary
    FROM departments d
    LEFT JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.department_name
) dt
WHERE avg_salary > 10000;

-- Rule of thumb: HAVING for a single filter step; a derived table (or
-- CTE, below) once you need to build further on top of the aggregate.


-- -------------------------------------------------------------
-- 2. Temporary tables — a real, session-scoped table
-- -------------------------------------------------------------
-- CREATE TEMPORARY TABLE ... AS SELECT snapshots a query's result into
-- an actual table you can query, filter, and modify like any other.
CREATE TEMPORARY TABLE high_salary_emp AS
SELECT *
FROM employees
WHERE salary > 10000;

-- It shows up in your OWN session's SHOW TABLES, indistinguishable at
-- a glance from a permanent table:
SHOW TABLES;

SELECT * FROM high_salary_emp;

-- You can DELETE, UPDATE, or further SELECT from it exactly like a
-- normal table:
DELETE FROM high_salary_emp e
WHERE e.employee_id = 100;

-- Explicitly drop it when you're done:
DROP TEMPORARY TABLE high_salary_emp;

-- What makes it "temporary":
--   • SCOPE — only the connection that created it can see or use it,
--     even while it exists. A second person running the exact same
--     CREATE TEMPORARY TABLE high_salary_emp on their own connection
--     gets their OWN separate table, no collision, no shared data.
--   • LIFETIME — MySQL drops it automatically when the connection
--     closes. Still, explicitly DROP it in a long-running session or
--     script rather than relying on disconnect to clean up.
-- Good for a scratch snapshot you want to experiment on without
-- touching real data — not for anything another session needs to see.


-- -------------------------------------------------------------
-- 3. CTEs — a named result, scoped to one statement
-- -------------------------------------------------------------
--   WITH <name> AS (<query>)
--   SELECT ... FROM <name> ...
--
-- A CTE is essentially a derived table with a name and better syntax:
-- define it once at the top, then read the query top-to-bottom instead
-- of inside-out. It is NOT a real table — it doesn't appear in SHOW
-- TABLES, and it stops existing the instant this one statement ends.
WITH high_salary_emp AS (
    SELECT * FROM employees
    WHERE salary > 10000
)
SELECT * FROM high_salary_emp;

-- The same avg-salary-by-department query from section 1, as a CTE.
-- Compare directly with the derived-table version above: same logic,
-- read top-to-bottom instead of nested inside a FROM (...).
WITH cte AS (
    SELECT d.department_name, AVG(e.salary) AS avg_salary
    FROM departments d
    LEFT JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.department_name
)
SELECT * FROM cte
WHERE avg_salary > 10000;


-- -------------------------------------------------------------
-- 4. Multiple CTEs, chained together
-- -------------------------------------------------------------
-- Comma-separate several CTEs in one WITH clause. Each LATER CTE can
-- reference any EARLIER one — this builds a small pipeline, the same
-- thing you'd get from nesting derived tables inside each other, but
-- readable as a sequence of named steps instead of a stack of parens.
WITH dep_avg_salary AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
high_salary_dep AS (
    SELECT department_id, avg_salary
    FROM dep_avg_salary
    WHERE avg_salary > 10000
)
SELECT * FROM high_salary_dep;

-- Note: this session only covered ordinary (non-recursive) CTEs. A
-- RECURSIVE CTE (`WITH RECURSIVE`) is for querying a hierarchy — e.g.
-- walking employees.manager_id all the way up to the top boss in one
-- statement — and wasn't demonstrated yet.


-- =============================================================
-- TAKEAWAYS
--   • Derived table: nested subquery in FROM, scoped to that one query
--   • CTE: same lifetime as a derived table, but named and readable
--     top-to-bottom; can chain several, each seeing the earlier ones
--   • Temporary table: a REAL table, scoped to your whole session —
--     the only one of the three you can INSERT/UPDATE/DELETE against
--   • Recursive CTEs (hierarchies like manager chains) — not covered
--     yet, coming later
-- =============================================================
