-- =============================================================
-- 01 — SELECT basics: reading data and inspecting tables
-- Database: office
-- =============================================================
-- SELECT is the only statement that reads data. Everything else in SQL
-- either changes data (INSERT/UPDATE/DELETE) or changes structure (CREATE/ALTER).
--
-- The minimum shape is:   SELECT <columns>  FROM <table>;
-- =============================================================


-- -------------------------------------------------------------
-- 1. Fully-qualified table name:  database.table
-- -------------------------------------------------------------
-- Use this when you have NOT picked a database yet, or when you want to
-- read from a different database than the one you're currently in.
SELECT * FROM office.employees;


-- -------------------------------------------------------------
-- 2. Pick a database once, then drop the prefix
-- -------------------------------------------------------------
-- USE sets the "current" database for the rest of your session.
USE office;

-- Now `employees` alone is enough — it means `office.employees`.
SELECT * FROM employees;

-- `SELECT *` means "every column". Convenient while exploring,
-- but in real code always list the columns you actually need:
--   it's faster, and it won't break when someone adds a column.
SELECT employee_id, first_name, last_name, salary
FROM employees;


-- -------------------------------------------------------------
-- 3. What tables exist? What's inside one?
-- -------------------------------------------------------------
-- List every table in the current database.
SHOW TABLES;

-- Show the columns of a table: name, data type, nullable, key, default.
-- This is the fastest way to answer "what can I even filter on?".
DESCRIBE employees;

-- DESC is a shorter alias for the exact same thing.
DESC employees;


-- -------------------------------------------------------------
-- 4. COUNT — your first aggregate function
-- -------------------------------------------------------------
-- An "aggregate" collapses many rows into a single value.
-- COUNT(*) counts rows. It returns ONE row, always.
SELECT COUNT(*) FROM employees;

-- AS renames the output column. Without it, the header reads "COUNT(*)",
-- which is ugly and hard to reference from application code.
SELECT COUNT(*) AS count_of_employees
FROM employees;

-- Note the difference:
--   COUNT(*)        → counts rows
--   COUNT(column)   → counts rows where that column is NOT NULL
SELECT
    COUNT(*)             AS total_rows,
    COUNT(department_id) AS rows_with_a_department
FROM employees;


-- -------------------------------------------------------------
-- 5. Other tables in this schema — go look at all of them
-- -------------------------------------------------------------
SELECT * FROM jobs;
SELECT * FROM departments;
SELECT * FROM locations;
SELECT * FROM countries;
SELECT * FROM regions;
SELECT * FROM dependents;


-- =============================================================
-- TAKEAWAYS
--   • USE <db>            sets the current database
--   • SELECT * FROM t     reads everything (exploring only)
--   • DESCRIBE t          shows the columns and their types
--   • COUNT(*)            collapses all rows to one number
--   • AS                  renames a column in the output
-- =============================================================
