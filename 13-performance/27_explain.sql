-- =============================================================
-- 27 — EXPLAIN: asking MySQL how it will run a query
-- Database: office
-- =============================================================
-- File 19 explained WHY an index makes a lookup fast. EXPLAIN lets you
-- check whether a query actually USES one. Put EXPLAIN in front of a
-- SELECT and MySQL shows its plan instead of running the query.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Lookup on the primary key
-- -------------------------------------------------------------
EXPLAIN
SELECT * FROM employees e
WHERE e.employee_id = 116;
--
--   type = const   key = PRIMARY   rows = 1
--
-- "const" is the best case: at most one matching row, found straight
-- through the primary-key index.


-- -------------------------------------------------------------
-- 2. Lookup on a column with NO index
-- -------------------------------------------------------------
EXPLAIN
SELECT * FROM employees e
WHERE e.email = 'shelli.baida@sqltutorial.org';
--
--   type = ALL   key = NULL   rows = (every row in the table)
--   Extra = Using where
--
-- "ALL" = a FULL TABLE SCAN: MySQL reads every row and checks the
-- WHERE on each. Fine on 40 rows; painful on 40 million.


-- -------------------------------------------------------------
-- 3. Fixing it — and proving the fix
-- -------------------------------------------------------------
CREATE INDEX idx_employees_email ON employees (email);

EXPLAIN
SELECT * FROM employees e
WHERE e.email = 'shelli.baida@sqltutorial.org';
--
--   type = ref   key = idx_employees_email   rows = 1
--
-- Emails are unique in practice, so a UNIQUE index would be even
-- better: CREATE UNIQUE INDEX ... makes the lookup "const" again.

DROP INDEX idx_employees_email ON employees;   -- undo the demo


-- -------------------------------------------------------------
-- 4. Reading the columns that matter
-- -------------------------------------------------------------
--   type  — HOW rows are found, best to worst:
--             const  → one row via PK / unique index
--             eq_ref → one row per row of the previous table (joins)
--             ref    → a few rows via a non-unique index
--             range  → an index range (BETWEEN, >, <)
--             index  → reads the WHOLE index
--             ALL    → reads the WHOLE table ⚠️
--   key   — which index was actually chosen (NULL = none)
--   rows  — MySQL's ESTIMATE of rows it will examine
--   Extra — "Using where", "Using filesort", "Using temporary"... the
--           last two often point at a slow ORDER BY / GROUP BY
--
-- Query-optimization habit: EXPLAIN any slow query and look for
-- type = ALL on a big table. That's usually the column to index.


-- -------------------------------------------------------------
-- 5. COUNT(column) vs COUNT(*)
-- -------------------------------------------------------------
SELECT COUNT(employee_id) FROM employees;
SELECT COUNT(*) FROM employees;
-- Same answer here, because employee_id is the primary key and can't
-- be NULL. In general COUNT(col) skips NULLs and COUNT(*) doesn't (file
-- 09). COUNT(*) is never slower — MySQL picks the cheapest index itself.


-- =============================================================
-- TAKEAWAYS
--   • EXPLAIN <query> shows the plan without running the query
--   • type = const / ref = index used; type = ALL = full table scan
--   • key tells you WHICH index; NULL means none
--   • Index the columns that show up as type = ALL in slow queries
-- =============================================================
