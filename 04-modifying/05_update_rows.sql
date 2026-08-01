-- =============================================================
-- 05 — UPDATE: changing existing rows
-- Database: office
-- =============================================================
--   UPDATE <table>
--   SET    <column> = <value>
--   WHERE  <condition>;
--
-- 🚨 THE MOST IMPORTANT RULE IN THIS ENTIRE COURSE
--    UPDATE without WHERE changes EVERY ROW IN THE TABLE.
--    There is no undo. There is no confirmation prompt.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Always SELECT before you UPDATE
-- -------------------------------------------------------------
-- Step 1 — run the WHERE clause as a SELECT and look at what comes back.
--          These are exactly the rows you are about to change.
SELECT *
FROM employees
WHERE employee_id = 102;

-- Step 2 — same WHERE, now as an UPDATE.
UPDATE employees
SET last_name = 'Haan'
WHERE employee_id = 102;

-- Step 3 — verify.
SELECT employee_id, first_name, last_name
FROM employees
WHERE employee_id = 102;

-- Do this every single time. It costs 5 seconds and prevents disasters.


-- -------------------------------------------------------------
-- 2. Updating several columns at once
-- -------------------------------------------------------------
-- One SET, columns separated by commas.
UPDATE employees
SET salary     = 17500,
    job_id     = 4
WHERE employee_id = 102;


-- -------------------------------------------------------------
-- 3. Updating from the column's own value
-- -------------------------------------------------------------
-- The right-hand side can reference the current value.
-- A 10% raise for everyone in department 9:
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 9;


-- -------------------------------------------------------------
-- 4. Safe update mode
-- -------------------------------------------------------------
-- MySQL Workbench turns this ON by default. While it is on, MySQL REFUSES
-- any UPDATE or DELETE whose WHERE clause doesn't use a key column.
-- If you see:
--     "Error Code: 1175. You are using safe update mode..."
-- that is the guard rail doing its job. Fix your WHERE clause first.

-- Turn it OFF (only when you know exactly which rows you're touching):
SET SQL_SAFE_UPDATES = 0;

-- Turn it back ON when you're done. Leave it ON as your normal state.
SET SQL_SAFE_UPDATES = 1;

-- ⚠️ In class we ran `SET SQL_SAFE_UPDATES = 1;` AFTER the update.
--    That re-enables the guard — it does not disable it. If an update
--    is blocked, set it to 0, run the update, then set it back to 1.


-- -------------------------------------------------------------
-- 5. The bulk-update pattern (used again in file 11)
-- -------------------------------------------------------------
-- Copying one column into another across the whole table is one of the
-- few legitimate no-WHERE updates. Be deliberate about it.
--
--   UPDATE employees
--   SET tmp_dep_id = department_id;
--
-- Safe-update mode will block this — which is correct, it IS a whole-table
-- write. Disable, run, re-enable.


-- -------------------------------------------------------------
-- 6. Transactions — the real safety net
-- -------------------------------------------------------------
-- Nothing is permanent until COMMIT. If the result looks wrong, ROLLBACK
-- undoes everything since START TRANSACTION.
START TRANSACTION;

UPDATE employees
SET salary = 9999
WHERE employee_id = 102;

SELECT employee_id, salary FROM employees WHERE employee_id = 102;  -- inspect

ROLLBACK;   -- undo it
-- COMMIT;  -- ...or keep it

-- Verify the rollback worked:
SELECT employee_id, salary FROM employees WHERE employee_id = 102;


-- =============================================================
-- TAKEAWAYS
--   • UPDATE without WHERE hits every row. No undo.
--   • SELECT with your WHERE first, every time
--   • SET col = a, col2 = b  — commas, one SET
--   • Safe update mode: 0 = off, 1 = on. Leave it on.
--   • START TRANSACTION / ROLLBACK is your actual undo button
-- =============================================================
