-- =============================================================
-- 11 — ALTER TABLE: changing structure, and fixing a foreign key
-- Database: office
-- =============================================================
-- DDL (Data Definition Language) changes the SHAPE of a table:
-- CREATE, ALTER, DROP.  DML (SELECT/INSERT/UPDATE/DELETE) changes the DATA.
--
-- 🚨 In MySQL, DDL cannot be rolled back. An ALTER commits immediately —
--    START TRANSACTION / ROLLBACK will not save you. Test on a copy first.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Look before you change
-- -------------------------------------------------------------
DESCRIBE employees;

-- The full CREATE statement, including indexes and foreign key names —
-- this is how you find out what a constraint is actually called.
SHOW CREATE TABLE employees;


-- -------------------------------------------------------------
-- 2. Add a column
-- -------------------------------------------------------------
-- New column, added at the end, NULL for every existing row.
ALTER TABLE employees
ADD COLUMN tmp_dep_id INT;

DESCRIBE employees;   -- confirm it's there


-- -------------------------------------------------------------
-- 3. Backfill it
-- -------------------------------------------------------------
-- Copy an existing column's values across the whole table.
-- This is a legitimate no-WHERE update — safe update mode will block it,
-- so switch the guard off, run, and switch it back on.
SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET tmp_dep_id = department_id;

SET SQL_SAFE_UPDATES = 1;

-- Verify the copy worked before relying on it:
SELECT employee_id, department_id, tmp_dep_id
FROM employees
LIMIT 10;

-- Any row where the two disagree? Should be zero.
SELECT COUNT(*) AS mismatches
FROM employees
WHERE tmp_dep_id <=> department_id = 0;
-- <=> is the NULL-safe equality operator: NULL <=> NULL is TRUE,
-- whereas NULL = NULL is NULL. Use it when comparing nullable columns.

-- The temp column now works like the real one:
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.tmp_dep_id = d.department_id;


-- -------------------------------------------------------------
-- 4. Recreating a foreign key
-- -------------------------------------------------------------
-- A foreign key is a rule the database enforces: "the value in this
-- column must exist in that other table's primary key." It prevents an
-- employee pointing at a department that doesn't exist.
--
-- To change one you must DROP it and ADD it again — there is no ALTER.
-- The name (`employees_ibfk_2`) is MySQL's auto-generated one; get the
-- actual name for your table from SHOW CREATE TABLE above.

ALTER TABLE employees
DROP FOREIGN KEY employees_ibfk_2;

ALTER TABLE employees
ADD CONSTRAINT employees_ibfk_2
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- ⚠️ Between the DROP and the ADD there is NO constraint. If someone
--    inserts an invalid department_id in that window, the ADD will fail
--    with "Cannot add or update a child row". Clean the data first:
SELECT e.employee_id, e.department_id
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id IS NOT NULL
  AND d.department_id IS NULL;
-- Zero rows = safe to re-add the constraint.

-- Naming your own constraints is better than accepting `_ibfk_2` —
-- the intent is readable and the name is stable:
--   ADD CONSTRAINT fk_employees_department
--   FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- ON DELETE / ON UPDATE control what happens to children when the parent
-- goes away:
--   RESTRICT (default) block the delete
--   CASCADE           delete the children too
--   SET NULL          null out the child column


-- -------------------------------------------------------------
-- 5. Other ALTER operations
-- -------------------------------------------------------------
-- Change a column's type or nullability (MODIFY keeps the name):
ALTER TABLE employees
MODIFY COLUMN tmp_dep_id INT NULL;

-- Rename and retype at once (CHANGE takes old name then new definition):
-- ALTER TABLE employees
-- CHANGE COLUMN tmp_dep_id temp_department_id INT;

-- Add an index — this is what makes WHERE and JOIN fast on big tables:
-- CREATE INDEX idx_employees_hire_date ON employees(hire_date);

-- Drop the scratch column once you're finished with it. Leaving temporary
-- columns behind is how schemas rot.
ALTER TABLE employees
DROP COLUMN tmp_dep_id;

DESCRIBE employees;   -- confirm


-- =============================================================
-- TAKEAWAYS
--   • DDL commits immediately and cannot be rolled back
--   • SHOW CREATE TABLE reveals real constraint names
--   • ADD COLUMN → backfill with UPDATE → verify
--   • Foreign keys are DROP + ADD, never ALTER
--   • Check for orphan rows before re-adding a constraint
--   • <=> is NULL-safe equality
--   • Clean up temporary columns
-- =============================================================
