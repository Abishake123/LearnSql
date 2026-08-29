-- =============================================================
-- 17 — SAVEPOINT: a checkpoint inside a transaction
-- Database: office
-- =============================================================
-- File 05 covered START TRANSACTION / COMMIT / ROLLBACK. A SAVEPOINT
-- adds a named checkpoint partway through a transaction, so you can
-- undo back to that point WITHOUT throwing away everything before it.
-- =============================================================

USE office;

SET SQL_SAFE_UPDATES = 0;


-- -------------------------------------------------------------
-- 1. Walking through what actually survives
-- -------------------------------------------------------------
START TRANSACTION;

-- Change #1 — happens BEFORE any savepoint exists.
UPDATE employees e
SET e.salary = e.salary + 2000
WHERE e.employee_id = 101;

-- Mark a checkpoint here, named chk_inc.
SAVEPOINT chk_inc;

-- Change #2 — happens AFTER the savepoint.
UPDATE employees e
SET e.salary = e.salary + 1000
WHERE e.employee_id = 102;

-- Undo back to the checkpoint — this only undoes what happened SINCE
-- chk_inc was set. Change #2 (employee 102) is rolled back.
-- Change #1 (employee 101) happened before the savepoint and survives.
ROLLBACK TO SAVEPOINT chk_inc;

-- The transaction is still OPEN at this point — ROLLBACK TO SAVEPOINT
-- does not end it. COMMIT finalizes whatever is left standing:
-- employee 101's +2000 raise, and nothing for employee 102.
COMMIT;

-- ⚠️ THE KEY POINT: ROLLBACK TO SAVEPOINT undoes changes made SINCE
-- that savepoint — it does NOT undo the whole transaction, and it does
-- NOT close the transaction out. You still need a final COMMIT (or a
-- plain ROLLBACK with no savepoint name, to abandon everything) to
-- actually finish.

-- Verify the end state:
SELECT employee_id, salary FROM employees WHERE employee_id IN (101, 102);


-- -------------------------------------------------------------
-- 2. A savepoint needs a name
-- -------------------------------------------------------------
-- ⚠️ This is INVALID and will error:
--     SAVEPOINT;
-- SAVEPOINT always requires an identifier — SAVEPOINT <name>;. A bare
-- SAVEPOINT with nothing after it isn't a checkpoint you can roll back
-- to; it's a syntax error.


-- -------------------------------------------------------------
-- 3. Session hygiene — two things worth resetting
-- -------------------------------------------------------------
-- (a) SQL_SAFE_UPDATES was switched off at the top of this file, for
--     the UPDATEs above (they filter on employee_id, a key column, so
--     safe mode wouldn't actually have blocked them here — but it's
--     good practice to work with it off deliberately, then put it back).
SET SQL_SAFE_UPDATES = 1;

-- (b) Earlier in this same class session, file 11's foreign key was
--     dropped again on a different table —
--         ALTER TABLE dependents DROP FOREIGN KEY dependents_ibfk_1;
--     — with no matching ADD CONSTRAINT run afterward. If you followed
--     along on your own database, `dependents.employee_id` currently
--     has NO foreign key enforcing it. Decide whether to re-add it
--     using the same DROP + ADD pattern from file 11 §4 before moving on.


-- =============================================================
-- TAKEAWAYS
--   • SAVEPOINT <name> marks a checkpoint inside an open transaction
--   • ROLLBACK TO SAVEPOINT <name> undoes only what happened AFTER
--     that checkpoint — earlier changes in the same transaction survive
--   • The transaction stays open after a savepoint rollback; COMMIT
--     (or a full ROLLBACK) still has to close it
--   • SAVEPOINT always needs a name — there's no bare form
-- =============================================================
