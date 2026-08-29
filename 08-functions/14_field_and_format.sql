-- =============================================================
-- 14 — Two more functions: FIELD() and FORMAT()
-- Database: office
-- =============================================================
-- Short lesson, two functions. Neither filters or aggregates — they
-- transform a value, the same category as LENGTH()/CHAR_LENGTH() from
-- file 12.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. FIELD() — position within a list
-- -------------------------------------------------------------
-- FIELD(needle, val1, val2, val3, ...) returns the 1-based position of
-- `needle` in the list that follows. 0 if it isn't found anywhere.
SELECT FIELD('banana', 'apple', 'banana', 'banana') AS Position;
-- → 2 (first match wins; the SECOND 'banana' in the list is ignored)

SELECT FIELD('cherry', 'apple', 'banana') AS Position;
-- → 0, not found

-- The real use case: a CUSTOM sort order that isn't alphabetical or
-- numeric — e.g. a status pipeline where "PENDING" should sort before
-- "APPROVED" even though P comes after A.
SELECT first_name, job_id
FROM employees
ORDER BY FIELD(job_id, 9, 4, 1);
-- Employees with job_id 9 come first, then 4, then 1, then everyone
-- else (FIELD returns 0 for them, which sorts before the named values —
-- list job_id 0 explicitly in the FIELD() call if you need them last).


-- -------------------------------------------------------------
-- 2. FORMAT() — display formatting for numbers
-- -------------------------------------------------------------
-- FORMAT(number, decimal_places) rounds and adds thousands separators.
SELECT FORMAT(1234567.89999999999, 3) AS Formatted_Number;
-- → '1,234,568.000'

SELECT first_name, FORMAT(salary, 2) AS salary_display
FROM employees;

-- ⚠️ FORMAT() returns a STRING, not a number. '1,234,568.000' can't be
--    summed, compared with >, or used in further arithmetic without
--    stripping the commas back out first. Use it only at the point
--    you're about to DISPLAY a value — do your math on the raw column,
--    format the result last.
SELECT first_name, salary, FORMAT(salary, 0) AS display_only
FROM employees
WHERE salary > 10000        -- comparison uses the real numeric column
ORDER BY salary DESC;       -- so does the sort


-- =============================================================
-- TAKEAWAYS
--   • FIELD(val, list...) — 1-based position, 0 if not found; great
--     for a custom ORDER BY that isn't alphabetical
--   • FORMAT(num, decimals) — thousands separators + fixed decimals,
--     but the result is text — format last, after any math or sorting
-- =============================================================
