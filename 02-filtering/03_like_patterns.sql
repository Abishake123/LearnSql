-- =============================================================
-- 03 — LIKE: pattern matching on text
-- Database: office
-- =============================================================
-- `=` matches text exactly. LIKE matches a PATTERN.
--
-- Two wildcards, and only two:
--   %   any sequence of characters, including none
--   _   exactly one character
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. % — "starts with", "ends with", "contains"
-- -------------------------------------------------------------
-- Starts with 'Jo':  Jones, John, Joanna …
SELECT * FROM employees WHERE first_name LIKE 'Jo%';

-- Ends with 'a':  Anna, Nandita, Sarath …
SELECT * FROM employees WHERE first_name LIKE '%a';

-- Contains 'ann' anywhere: Joanna, Hannah …
SELECT * FROM employees WHERE first_name LIKE '%ann%';

-- Starts with J AND ends with n: John, Jason, Jean …
-- Anything is allowed in the middle, including nothing.
SELECT * FROM employees WHERE first_name LIKE 'J%n';


-- -------------------------------------------------------------
-- 2. _ — exactly one character, no more, no less
-- -------------------------------------------------------------
-- 'Ur_a_' is a FIVE-character name: U, r, anything, a, anything.
-- Matches 'Urman', 'Urbah'. Does NOT match 'Urma' (too short)
-- or 'Urmania' (too long).
SELECT *
FROM employees
WHERE last_name LIKE 'Ur_a_';

-- Any 4-letter first name.
SELECT * FROM employees WHERE first_name LIKE '____';

-- Mix them: starts with A, then any single char, then anything.
SELECT * FROM employees WHERE first_name LIKE 'A_%';


-- -------------------------------------------------------------
-- 3. Combining LIKE with AND
-- -------------------------------------------------------------
-- Both conditions must hold on the same row.
SELECT *
FROM employees
WHERE first_name LIKE 'Jo%'
  AND last_name  LIKE 'Ur_a_';


-- -------------------------------------------------------------
-- 4. NOT LIKE
-- -------------------------------------------------------------
SELECT *
FROM employees
WHERE first_name NOT LIKE 'J%';


-- -------------------------------------------------------------
-- 5. Two things worth knowing
-- -------------------------------------------------------------
-- (a) Case sensitivity depends on the column's COLLATION.
--     MySQL's default collation is case-INsensitive, so 'jo%' and 'Jo%'
--     usually return the same rows. Do not rely on that across databases.
SELECT * FROM employees WHERE first_name LIKE 'jo%';

-- (b) A LEADING % cannot use an index. 'Jo%' can jump straight to the
--     right place in a sorted index; '%jo' has to read every single row.
--     Fine on 40 rows. Very slow on 40 million.
--        LIKE 'Jo%'   → fast   (index-friendly)
--        LIKE '%jo'   → slow   (full table scan)


-- =============================================================
-- TAKEAWAYS
--   • %  = any number of characters (including zero)
--   • _  = exactly one character
--   • 'Ur_a_' is a fixed-length pattern; 'Ur%' is not
--   • Leading % kills index usage — avoid it on large tables
-- =============================================================
