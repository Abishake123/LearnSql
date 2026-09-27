-- =============================================================
-- 29 — String, date, and maths functions
-- Database: office
-- =============================================================
-- File 14 covered FIELD() and FORMAT(). This session added a few more
-- everyday built-ins for cutting up strings, turning text into dates,
-- and filtering by year.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Cutting strings
-- -------------------------------------------------------------
-- SUBSTRING(str, start, length) — positions start at 1, not 0.
SELECT SUBSTRING('Hello World', 7, 1) AS one_char;   -- → 'W'
SELECT SUBSTRING('Hello World', 7)    AS to_end;     -- → 'World' (no length = to the end)

-- LEFT / RIGHT — the first / last n characters.
SELECT LEFT('Hello World', 5)  AS left_part;    -- → 'Hello'
SELECT RIGHT('Hello World', 3) AS right_part;   -- → 'rld'
-- ⚠️ In class the RIGHT() result was aliased `LeftString`. Name it for
-- what it is — an alias that lies confuses whoever reads it next.

-- On real data: everyone's initials.
SELECT first_name, last_name,
       CONCAT(LEFT(first_name, 1), LEFT(last_name, 1)) AS initials
FROM employees;


-- -------------------------------------------------------------
-- 2. Text → date with STR_TO_DATE
-- -------------------------------------------------------------
-- STR_TO_DATE(text, format) — the format describes what the TEXT
-- looks like, so MySQL can read it.
SELECT STR_TO_DATE('25-12-2026', '%d-%m-%Y') AS converted_date;   -- → 2026-12-25
SELECT STR_TO_DATE('12/25/2026', '%m/%d/%Y') AS us_style;         -- → 2026-12-25
--
--   %d day (01–31)   %m month (01–12)   %Y 4-digit year   %y 2-digit year
--
-- What we ran in class had a 2-digit year with %Y:
SELECT STR_TO_DATE('25-12-26', '%d-%m-%Y') AS converted_date;     -- → 2026-12-25
-- MySQL lets it through and guesses the century (70–99 → 19xx,
-- 00–69 → 20xx). Use %y when the year really is 2 digits, so the
-- format says what you mean.


-- -------------------------------------------------------------
-- 3. Filtering by year — two ways, one much better
-- -------------------------------------------------------------
-- Everyone hired in 1997 (pick a year that exists in your data):
SELECT first_name, hire_date
FROM employees
WHERE YEAR(hire_date) = 1997;

-- Same rows with a date RANGE:
SELECT first_name, hire_date
FROM employees
WHERE hire_date >= '1997-01-01' AND hire_date < '1998-01-01';

-- ⚠️ What we wrote in class:
--    WHERE hire_date > '2018-01-01' AND hire_date < '2018-12-31'
-- misses anyone hired ON Jan 1 or ON Dec 31. The safe pattern is
-- `>= first day` and `< first day of the NEXT year`.
--
-- Why prefer the range over YEAR()? Wrapping a column in a function
-- stops MySQL using an index on that column — it has to compute
-- YEAR() for every row first. The range compares the raw column, so an
-- index on hire_date can be used. (Check with EXPLAIN, file 27.)


-- -------------------------------------------------------------
-- 4. Maths: % (modulo)
-- -------------------------------------------------------------
-- a % b = the REMAINDER when a is divided by b.
SELECT 14 % 2;   -- → 0  (14 is even)
SELECT 15 % 4;   -- → 3

-- Classic use: odd/even tests.
SELECT employee_id, first_name
FROM employees
WHERE employee_id % 2 = 0;   -- even ids only


-- =============================================================
-- TAKEAWAYS
--   • SUBSTRING(s, start, len) counts from 1; LEFT / RIGHT take n chars
--   • STR_TO_DATE(text, format) — the format describes the INPUT text
--   • Filter dates with >= start AND < next-start, not YEAR(col) = ...
--     (keeps indexes usable and doesn't lose the end dates)
--   • % gives the remainder — x % 2 = 0 means even
-- =============================================================
