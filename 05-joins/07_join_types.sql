-- =============================================================
-- 07 — The four join types
-- Database: office
-- =============================================================
--   INNER JOIN   only rows that match on BOTH sides
--   LEFT  JOIN   every row from the LEFT table  + matches (NULL if none)
--   RIGHT JOIN   every row from the RIGHT table + matches (NULL if none)
--   FULL OUTER   everything from both sides
--
-- The only question you ever need to ask:
--   "Do I want to keep rows that have NO match?"
--   No  → INNER.   Yes, from the first table → LEFT.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Set up the picture: who has a department, who doesn't?
-- -------------------------------------------------------------
SELECT * FROM employees   WHERE employee_id = 100;
SELECT * FROM departments WHERE department_id = 9;

-- Employees with no department at all — these are the rows that make
-- INNER and LEFT behave differently.
SELECT employee_id, first_name, department_id
FROM employees
WHERE department_id IS NULL;


-- -------------------------------------------------------------
-- 2. INNER JOIN — matches only
-- -------------------------------------------------------------
-- Plain `JOIN` means `INNER JOIN`. The words are interchangeable.
-- An employee with a NULL department_id DISAPPEARS from this result.
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Spelled out — identical query:
SELECT e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;


-- -------------------------------------------------------------
-- 3. LEFT JOIN — keep everything on the left
-- -------------------------------------------------------------
-- "LEFT" = the table named in FROM. Every employee appears, whether or
-- not they have a department. Unmatched ones get NULL for department_name.
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- Compare the row counts. If they differ, that gap is your unmatched rows:
SELECT COUNT(*) AS inner_rows
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

SELECT COUNT(*) AS left_rows
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- The classic use of LEFT JOIN: FIND the unmatched rows.
-- Employees who belong to no department:
SELECT e.employee_id, e.first_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;


-- -------------------------------------------------------------
-- 4. RIGHT JOIN — keep everything on the right
-- -------------------------------------------------------------
-- Every department appears, even ones with zero employees.
SELECT e.first_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- RIGHT JOIN is just LEFT JOIN with the tables swapped. Most teams write
-- everything as LEFT JOIN because reading right-to-left is confusing:
SELECT e.first_name, d.department_name
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id;

-- Departments nobody works in:
SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;


-- -------------------------------------------------------------
-- 5. FULL OUTER JOIN — everything from both sides
-- -------------------------------------------------------------
-- ⚠️ MySQL does NOT support FULL OUTER JOIN. (Postgres and SQL Server do.)
--    Emulate it with a LEFT JOIN unioned to a RIGHT JOIN:
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id

UNION

SELECT e.first_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- UNION removes duplicates. UNION ALL keeps them and is faster.


-- -------------------------------------------------------------
-- 6. SELF JOIN — a table joined to itself
-- -------------------------------------------------------------
-- `employees.manager_id` points at another row in `employees`.
-- Aliases are MANDATORY here — they're the only way to tell the two
-- copies of the table apart.
SELECT
    e.first_name   AS employee,
    m.first_name   AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- LEFT, not INNER: the top boss has manager_id = NULL and an INNER JOIN
-- would silently drop them.


-- =============================================================
-- TAKEAWAYS
--   • JOIN == INNER JOIN — matched rows only
--   • LEFT JOIN keeps all rows from the FROM table, NULL-filling the rest
--   • LEFT JOIN + WHERE right_col IS NULL = "find the orphans"
--   • Prefer LEFT over RIGHT; swap table order instead
--   • MySQL has no FULL OUTER JOIN — emulate with UNION
--   • Self-join for manager/parent hierarchies; aliases required
-- =============================================================
