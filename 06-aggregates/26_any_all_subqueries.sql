-- =============================================================
-- 26 — ANY and ALL: comparing against a whole list of values
-- Database: office
-- =============================================================
-- File 10 used `= (subquery)` for one value and `IN (subquery)` for
-- many. ANY and ALL cover the remaining case: >, <, >=, <= against
-- EVERY value a subquery returns.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The list we'll compare against
-- -------------------------------------------------------------
SELECT salary
FROM employees
WHERE department_id = 10;
-- e.g. (12000, 9000, 8200, 7700, ...)


-- -------------------------------------------------------------
-- 2. > ALL — bigger than EVERY value in the list
-- -------------------------------------------------------------
-- Employees who earn more than everyone in department 10:
SELECT *
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 10
);

-- Bigger than every value = bigger than the BIGGEST value. So this is
-- the same as:
SELECT *
FROM employees
WHERE salary > (SELECT MAX(salary) FROM employees WHERE department_id = 10);


-- -------------------------------------------------------------
-- 3. > ANY — bigger than AT LEAST ONE value in the list
-- -------------------------------------------------------------
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 10
);

-- Bigger than at least one = bigger than the SMALLEST. Same as:
SELECT *
FROM employees
WHERE salary > (SELECT MIN(salary) FROM employees WHERE department_id = 10);

-- Cheat sheet:
--   > ALL (list)  ≡  > MAX(list)
--   > ANY (list)  ≡  > MIN(list)
--   < ALL (list)  ≡  < MIN(list)
--   < ANY (list)  ≡  < MAX(list)
--   = ANY (list)  ≡  IN (list)


-- -------------------------------------------------------------
-- 4. ⚠️ ANY / ALL need a SUBQUERY, not a typed-out list
-- -------------------------------------------------------------
-- What we tried:
--
--   SELECT * FROM employees
--   WHERE salary > ANY (12000, 9000, 6800);
--
--   → ERROR 1064: syntax error near '12000,9000,6800)'
--
-- MySQL only accepts ANY/ALL in front of a subquery. For a hand-typed
-- list, work out the equivalent yourself — "> ANY" of those three is
-- "> the smallest", so:
SELECT *
FROM employees
WHERE salary > 6800;

-- Or, if you really want the list form, turn it into a subquery:
SELECT *
FROM employees
WHERE salary > ANY (SELECT 12000 UNION SELECT 9000 UNION SELECT 6800);


-- -------------------------------------------------------------
-- 5. Exact matches — = ANY is just IN
-- -------------------------------------------------------------
-- "Salary is exactly 16000, 19000 or 9000." The long way:
SELECT * FROM employees e
WHERE e.salary = 16000 OR e.salary = 19000 OR e.salary = 9000;

-- The short way (file 02):
SELECT * FROM employees e
WHERE e.salary IN (16000, 19000, 9000);


-- =============================================================
-- TAKEAWAYS
--   • > ALL = beats every value → same as > MAX
--   • > ANY = beats at least one → same as > MIN
--   • = ANY is IN
--   • ANY/ALL only work with a subquery — not a literal (a, b, c) list
--   • ⚠️ An empty subquery makes > ALL TRUE for every row (nothing to
--     beat), and > ANY FALSE for every row
-- =============================================================
