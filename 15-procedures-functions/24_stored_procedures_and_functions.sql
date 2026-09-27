-- =============================================================
-- 24 — Stored procedures, user variables, and stored functions
-- Database: office
-- =============================================================
-- A stored procedure is a named block of SQL saved INSIDE the
-- database. You run it with CALL, pass it parameters, and it can hand
-- values back through OUT parameters.
-- A stored function is similar, but it RETURNS a single value and can
-- be used right inside a SELECT, like CONCAT() or ROUND().
--
-- ⚠️ In class the procedures were created through MySQL Workbench's
-- "Create Stored Procedure" editor, so only the CALLs were saved. The
-- CREATE statements below are rebuilt from how each one was called —
-- the logic matches what the calls show, but the class versions may
-- differ in detail.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. DELIMITER — why every procedure is wrapped in $$
-- -------------------------------------------------------------
-- A procedure body contains several statements, each ending in `;`.
-- If the client still treated `;` as "end of statement", it would send
-- the CREATE PROCEDURE to the server half-finished. DELIMITER $$
-- temporarily makes `$$` the end marker, so the whole body travels as
-- one statement. Switch it back to `;` straight after.
-- (Workbench's procedure editor adds this for you.)


-- -------------------------------------------------------------
-- 2. IN parameters — passing values in
-- -------------------------------------------------------------
DELIMITER $$

-- All employees in one department.
CREATE PROCEDURE dep_employees(IN p_department_id INT)
BEGIN
    SELECT *
    FROM employees
    WHERE department_id = p_department_id;
END $$

-- Add two numbers. (A procedure doesn't have to touch a table.)
CREATE PROCEDURE maths_sum(IN p_a INT, IN p_b INT)
BEGIN
    SELECT p_a + p_b AS result;
END $$

-- One employee's full row.
CREATE PROCEDURE emp_details(IN p_employee_id INT)
BEGIN
    SELECT *
    FROM employees
    WHERE employee_id = p_employee_id;
END $$

DELIMITER ;

CALL dep_employees(4);
CALL maths_sum(2, 3);
CALL emp_details(200);


-- -------------------------------------------------------------
-- 3. User variables — @name
-- -------------------------------------------------------------
-- A variable starting with @ lives for your whole session (until you
-- disconnect). No declaring, no type — just SET it and use it.
SET @num1 = 10;
SET @num2 = 20;

SELECT @num1 + @num2 AS result;   -- → 30


-- -------------------------------------------------------------
-- 4. OUT parameters — getting values back
-- -------------------------------------------------------------
-- A procedure can't RETURN a value, but it can write into an OUT
-- parameter. The caller passes a @variable to receive it.
DELIMITER $$

CREATE PROCEDURE count_empl(IN p_department_id INT, OUT p_count INT)
BEGIN
    SELECT COUNT(*)
    INTO p_count                   -- SELECT ... INTO stores the result
    FROM employees
    WHERE department_id = p_department_id;
END $$

DELIMITER ;

CALL count_empl(10, @x);   -- how many employees in department 10?
SELECT @x;                 -- → the count

-- What we tried next: feed @x back IN as the department id.
CALL count_empl(@x, @y);   -- "how many employees in department <@x>?"
SELECT @y;
-- It works — any expression can be an IN argument — but it's a strange
-- question to ask. It shows that @x is just a value once it's set.

-- ⚠️ CALL count_empl();
--    → ERROR 1318: Incorrect number of arguments for PROCEDURE
--    Every parameter is required. MySQL has no default values for
--    procedure parameters.

-- The aggregates a procedure like this is built on:
SELECT COUNT(*), SUM(salary), MAX(salary), MIN(salary)
FROM employees;


-- -------------------------------------------------------------
-- 5. Logic inside a procedure — IF / CASE
-- -------------------------------------------------------------
-- Start with the plain query and get it right first:
SELECT e.salary,
       CASE WHEN e.salary > 10000 THEN 'Tax Eligible'
            ELSE 'Not a Tax Payer'
       END AS tax_status
FROM employees e
WHERE e.employee_id = 101;

-- ...then wrap it in a procedure with an IN and an OUT parameter.
DELIMITER $$

CREATE PROCEDURE salary_category(IN p_employee_id INT, OUT p_result VARCHAR(20))
BEGIN
    DECLARE v_salary DECIMAL(8, 2);   -- a LOCAL variable: no @, only
                                      -- exists inside this BEGIN...END
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = p_employee_id;

    IF v_salary > 10000 THEN
        SET p_result = 'Tax Eligible';
    ELSE
        SET p_result = 'Not a Tax Payer';
    END IF;
END $$

DELIMITER ;

CALL salary_category(101, @tax_result);
SELECT @tax_result;

-- @session_var  vs  DECLARE local_var
--   @x        — lives for the whole session, visible everywhere
--   DECLARE x — lives only inside the BEGIN...END block, must be
--               declared at the top of that block, with a type


-- -------------------------------------------------------------
-- 6. Stored functions — RETURNS a value, usable in SELECT
-- -------------------------------------------------------------
-- ⚠️ Our first CREATE FUNCTION failed with:
--    ERROR 1418: This function has none of DETERMINISTIC, NO SQL, or
--    READS SQL DATA in its declaration and binary logging is enabled
--
-- Why: the binary log (file 19) replays statements on replicas. MySQL
-- needs to know a function gives the same result for the same input,
-- or a replica could end up with different data.
--
-- What we ran in class — switches the check OFF for the whole server:
--    SET GLOBAL log_bin_trust_function_creators = 1;
--
-- ✅ The better fix: tell MySQL the truth in the function itself.
--    DETERMINISTIC = same inputs always give the same output.
DELIMITER $$

CREATE FUNCTION add_numbers(p_a INT, p_b INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN p_a + p_b;
END $$

-- A salary as a percentage of a total, rounded to 2 decimals.
CREATE FUNCTION salary_percent(p_total DECIMAL(12, 2), p_salary DECIMAL(8, 2))
RETURNS DECIMAL(5, 2)
DETERMINISTIC
BEGIN
    RETURN (p_salary / p_total) * 100;
END $$

DELIMITER ;

SELECT add_numbers(2, 4);                    -- → 6
SELECT salary_percent(335100.00, 17000.00);  -- → 5.07

-- A function can be used anywhere an expression can — here, fed by
-- the SUM() OVER() total from file 23:
SELECT dt.*,
       salary_percent(dt.total_salary, dt.salary) AS pct_of_total
FROM (
    SELECT e.first_name, e.salary, SUM(e.salary) OVER () AS total_salary
    FROM employees e
) dt;

-- Procedure vs function:
--   PROCEDURE — CALL proc(...); can return result sets and OUT params;
--               can't be used inside a SELECT
--   FUNCTION  — RETURNS exactly one value; used INSIDE a query


-- -------------------------------------------------------------
-- 7. Housekeeping
-- -------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'office';
SHOW FUNCTION STATUS WHERE Db = 'office';
SHOW CREATE PROCEDURE salary_category;

-- To change a procedure, drop it and create it again:
--   DROP PROCEDURE IF EXISTS salary_category;

-- Mentioned at the end of class: the EVENT SCHEDULER, which runs SQL
-- on a timer (like a cron job inside MySQL). Check whether it's on:
SHOW VARIABLES LIKE 'event_scheduler';


-- =============================================================
-- TAKEAWAYS
--   • Wrap procedure/function bodies in DELIMITER $$ ... $$
--   • IN = passed in, OUT = handed back through a @variable
--   • Every parameter is required — no defaults
--   • @var lives for the session; DECLARE var lives inside BEGIN...END
--   • SELECT ... INTO var stores a query result in a variable
--   • Functions RETURN one value and can sit inside a SELECT
--   • Mark functions DETERMINISTIC instead of turning on
--     log_bin_trust_function_creators server-wide
-- =============================================================
