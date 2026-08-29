-- =============================================================
-- 18 — Users & privileges, and Views
-- Database: office
-- =============================================================
-- Two unrelated admin topics covered back to back in this session:
-- creating a restricted login, and packaging a query up as a named,
-- reusable VIEW.
-- =============================================================


-- -------------------------------------------------------------
-- 1. mysql.user — the server's own account list
-- -------------------------------------------------------------
-- Every MySQL server keeps its accounts in a system table. Reading it
-- requires admin-level privileges.
SELECT * FROM mysql.user;


-- -------------------------------------------------------------
-- 2. Creating a login
-- -------------------------------------------------------------
-- CREATE USER '<name>'@'<host>' IDENTIFIED BY '<password>'
--   '<host>' scopes WHERE the login is allowed to connect from.
--   'localhost' means: only connections originating from the same
--   machine the MySQL server runs on. The same username connecting
--   from 'localhost' vs '%' (anywhere) are two DIFFERENT accounts as
--   far as MySQL is concerned.
CREATE USER 'junior'@'localhost' IDENTIFIED BY '1234';

-- ⚠️ '1234' is a throwaway password used purely to demonstrate the
--    syntax on a local practice database. Never use anything this
--    weak, or hardcode a plaintext password in a script, outside a
--    disposable local setup.

-- A freshly created user has NO privileges at all — they can log in,
-- but can't read or write a single table until something is granted.
-- The command that grants access is GRANT, not shown in this session's
-- script, but it's the mirror of REVOKE below:
--   GRANT SELECT ON office.* TO 'junior'@'localhost';


-- -------------------------------------------------------------
-- 3. REVOKE
-- -------------------------------------------------------------
REVOKE UPDATE ON office.* FROM 'junior'@'localhost';

-- ⚠️ Because 'junior' was never GRANTed UPDATE in the first place, this
--    REVOKE is a no-op — there was nothing to take away. It's included
--    here to show the syntax, not because it changes anything for a
--    brand-new user. REVOKE only removes a privilege that GRANT
--    previously added.


-- -------------------------------------------------------------
-- 4. FLUSH PRIVILEGES
-- -------------------------------------------------------------
FLUSH PRIVILEGES;

-- Reloads the server's in-memory privilege tables from disk. Modern
-- MySQL applies CREATE USER / GRANT / REVOKE immediately on their own,
-- so this is mostly a habit carried over from directly editing the
-- grant tables with raw INSERT/UPDATE statements — harmless to run,
-- and a common safety net after any privilege change.

SELECT * FROM mysql.user WHERE user = 'junior';


-- -------------------------------------------------------------
-- 5. VIEWS — naming a query so you can SELECT FROM it
-- -------------------------------------------------------------
-- A VIEW stores no data of its own. Every time you query it, MySQL
-- re-runs the SELECT behind it. This one packages up the exact 5-table
-- join chain from file 08, so nobody has to retype it.
USE office;

CREATE VIEW employee_details AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.phone_number,
    e.hire_date,
    e.salary,
    j.job_title,
    d.department_name,
    l.city,
    c.country_name,
    r.region_name
FROM employees e
LEFT JOIN jobs j
    ON e.job_id = j.job_id
LEFT JOIN departments d
    ON e.department_id = d.department_id
LEFT JOIN locations l
    ON d.location_id = l.location_id
LEFT JOIN countries c
    ON l.country_id = c.country_id
LEFT JOIN regions r
    ON c.region_id = r.region_id;

-- Now query it exactly like a table:
SELECT * FROM employee_details;

SELECT first_name, region_name
FROM employee_details
WHERE region_name = 'Europe';

-- A view is a good way to:
--   • hide a complex join behind a simple, memorable name
--   • control what a limited-privilege user (like 'junior' above) can
--     see, by granting SELECT on the VIEW instead of on the base tables
--
-- ⚠️ This view is effectively READ-ONLY. MySQL only allows INSERT/
--    UPDATE through a "simple" view — one built on a single table with
--    no joins or aggregates. A 5-table join like this one can be
--    queried, but not written through.
--
-- Clean-up, if you no longer need it:
--   DROP VIEW employee_details;


-- =============================================================
-- TAKEAWAYS
--   • A new CREATE USER starts with zero privileges — GRANT adds them,
--     REVOKE removes them; REVOKE on something never granted is a no-op
--   • FLUSH PRIVILEGES reloads the grant tables — rarely required after
--     GRANT/REVOKE/CREATE USER, but a harmless habit
--   • A VIEW is a named, reusable SELECT — no data of its own, re-run
--     fresh on every query
--   • A multi-table VIEW is generally read-only; only simple
--     single-table views support INSERT/UPDATE
-- =============================================================
