-- =============================================================
-- 12 — Aggregates combined with a JOIN, and a first string function
-- Database: office
-- =============================================================
-- This session revisited joins (nothing new there — see 06, 07, 08) and
-- pushed aggregates one step further: COUNT/MIN alongside a real column,
-- a string function (LENGTH), and grouping through a join.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. COUNT(column) vs COUNT(*) — a quick way to spot NULLs
-- -------------------------------------------------------------
-- COUNT(*) counts rows. COUNT(column) counts only rows where that
-- column is NOT NULL. Compare the two and any gap is missing data.
SELECT COUNT(*) FROM employees;
SELECT COUNT(e.tmp_dep_id) FROM employees e;

-- If the numbers differ, find the culprits:
SELECT employee_id FROM employees WHERE tmp_dep_id IS NULL;


-- -------------------------------------------------------------
-- 2. MIN / MAX on their own
-- -------------------------------------------------------------
SELECT MIN(e.salary) FROM employees e;
SELECT MAX(e.salary) FROM employees e;

-- MIN()/MAX() only return the number, not the row it came from.
-- To see who actually earns it, filter by the value:
SELECT * FROM employees WHERE salary = 24000;

-- More robust — works even if the exact number changes later, and
-- handles ties (multiple people at the max) correctly:
SELECT * FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);


-- -------------------------------------------------------------
-- 3. LENGTH() — your first string function
-- -------------------------------------------------------------
-- Returns the number of characters in a string. Runs once per row, like
-- any other expression in SELECT.
SELECT first_name, LENGTH(e.first_name) AS name_length
FROM employees e;

-- ⚠️ LENGTH() actually counts BYTES, not characters. For plain ASCII
--    names this is the same number. It stops being the same the moment
--    a name has a multi-byte character (é, ñ, emoji, …) under UTF-8.
--    CHAR_LENGTH() counts characters — prefer it once data isn't
--    guaranteed to be plain ASCII:
SELECT first_name, CHAR_LENGTH(e.first_name) AS name_length
FROM employees e;

-- Useful filter built on it — unusually short names:
SELECT * FROM employees WHERE LENGTH(first_name) <= 3;


-- -------------------------------------------------------------
-- 4. A simple lookup JOIN: employees + jobs
-- -------------------------------------------------------------
-- `jobs` is a reference table: job_id → job_title. Joining it turns a
-- meaningless number (job_id) into a readable label.
SELECT * FROM jobs;

SELECT e.first_name, j.job_title
FROM employees e
JOIN jobs j ON j.job_id = e.job_id;

-- Sanity-check a specific group manually before trusting an aggregate
-- over it — here, job_id 9 has 5 employees, counted by eye:
SELECT * FROM employees e WHERE job_id = 9;   -- 5 rows


-- -------------------------------------------------------------
-- 5. JOIN + GROUP BY together
-- -------------------------------------------------------------
-- How many employees hold each job title?
SELECT j.job_title, COUNT(e.employee_id) AS headcount
FROM employees e
JOIN jobs j ON j.job_id = e.job_id
GROUP BY e.job_id
ORDER BY headcount DESC;

-- Worth noticing: we GROUP BY e.job_id but SELECT j.job_title — a column
-- that isn't in the GROUP BY list. File 09 said exactly that is what
-- ONLY_FULL_GROUP_BY forbids. So why does this run cleanly with no error?
--
-- Because job_id is the PRIMARY KEY of jobs, and the join is
-- j.job_id = e.job_id. Each employees.job_id value can only ever match
-- ONE row in jobs, so job_title is "functionally dependent" on the
-- grouping column — there's no ambiguity about which title to display.
-- MySQL detects this specific shape (grouping by a column that
-- determines every other selected column via a key) and allows it, even
-- with ONLY_FULL_GROUP_BY switched on.
--
-- This is narrower than it looks: it works because we grouped by the
-- FOREIGN key side of the join (e.job_id), which maps to jobs' PRIMARY
-- key. Grouping by something that isn't a key wouldn't get the same pass
-- — you'd be back to the file-09 error.


-- =============================================================
-- TAKEAWAYS
--   • COUNT(col) vs COUNT(*) — a fast way to spot NULLs in a column
--   • LENGTH() counts bytes; CHAR_LENGTH() counts characters — prefer
--     CHAR_LENGTH() once data isn't guaranteed ASCII
--   • Joining a reference table (jobs) turns an id into a readable label
--   • GROUP BY the FK side of a join, and the joined table's other
--     columns become selectable under ONLY_FULL_GROUP_BY — because
--     they're functionally dependent on the grouped key
-- =============================================================
