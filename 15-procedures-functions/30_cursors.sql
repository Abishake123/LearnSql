-- =============================================================
-- 30 — Cursors: processing a result one row at a time
-- Database: office
-- =============================================================
-- Everything so far has been SET-BASED: one statement acts on every
-- matching row at once. A CURSOR goes the other way — it walks a
-- result set row by row inside a stored procedure (file 24), so you
-- can run procedural logic on each row.
--
-- ⚠️ As in file 24, the procedure was built in Workbench's editor and
-- only the CALL was saved. The definition below is rebuilt from what
-- the call does.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. First, the set-based way — prefer this whenever it works
-- -------------------------------------------------------------
-- A +2000 raise for everyone earning over 15000. One statement, and
-- MySQL touches every matching row itself — no loop needed.
SELECT * FROM employees WHERE salary > 15000;   -- check the WHERE first

-- ⚠️ This really changes data. Run it inside a transaction if you want
-- to undo it (file 17), or skip it.
UPDATE employees
SET salary = salary + 2000
WHERE salary > 15000;

SELECT * FROM employees WHERE salary > 15000;   -- confirm


-- -------------------------------------------------------------
-- 2. A cursor, step by step
-- -------------------------------------------------------------
-- The four steps are always the same:
--   DECLARE the cursor  → which query it will walk
--   OPEN it             → run the query
--   FETCH in a loop     → pull one row into variables, each time round
--   CLOSE it            → release it
--
-- The only tricky part: how does the loop know it's finished? When
-- FETCH runs out of rows it raises a NOT FOUND condition. A HANDLER
-- catches that and flips a flag, and the loop checks the flag.
DELIMITER $$

CREATE PROCEDURE print_employee_names()
BEGIN
    -- 1. Variables FIRST, then the cursor, then the handler — MySQL
    --    insists on that order.
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_first_name VARCHAR(20);
    DECLARE v_last_name  VARCHAR(25);
    DECLARE v_all_names  TEXT DEFAULT '';

    DECLARE emp_cursor CURSOR FOR
        SELECT first_name, last_name
        FROM employees
        ORDER BY employee_id;

    -- When FETCH finds no more rows, set v_done = 1 and carry on.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- 2. OPEN
    OPEN emp_cursor;

    -- 3. FETCH in a loop
    read_loop: LOOP
        FETCH emp_cursor INTO v_first_name, v_last_name;

        IF v_done = 1 THEN
            LEAVE read_loop;        -- LEAVE = break out of the loop
        END IF;

        -- The per-row work. Here: build up one long list of names.
        SET v_all_names = CONCAT(v_all_names, v_first_name, ' ', v_last_name, '\n');
    END LOOP;

    -- 4. CLOSE
    CLOSE emp_cursor;

    SELECT v_all_names AS employee_names;
END $$

DELIMITER ;

CALL print_employee_names();

-- ⚠️ Check v_done straight after FETCH, BEFORE using the variables. If
-- you check it at the bottom of the loop instead, the last row gets
-- processed twice: the failed FETCH leaves the variables holding the
-- previous row's values.


-- -------------------------------------------------------------
-- 3. When a cursor is (and isn't) the right tool
-- -------------------------------------------------------------
-- This particular job doesn't need a cursor at all — one set-based
-- query does it:
SELECT GROUP_CONCAT(CONCAT(first_name, ' ', last_name)
                    ORDER BY employee_id SEPARATOR '\n') AS employee_names
FROM employees;
--
-- Cursors are slow — one row at a time instead of letting the engine
-- work on all of them at once. Reach for one only when each row needs
-- logic a single statement can't express, e.g. calling another
-- procedure per row, or a decision that depends on the rows processed
-- before it.


-- =============================================================
-- TAKEAWAYS
--   • Cursor lifecycle: DECLARE → OPEN → FETCH (loop) → CLOSE
--   • DECLARE order inside BEGIN: variables, cursors, handlers
--   • CONTINUE HANDLER FOR NOT FOUND is how the loop learns it's done
--   • Check the "done" flag right after FETCH, before using the row
--   • Set-based SQL first; a cursor only when row-by-row logic is
--     genuinely needed
-- =============================================================
