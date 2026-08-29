-- =============================================================
-- 15 — CASE expressions
-- Database: office
-- =============================================================
-- CASE is an inline if/elif/else that returns a VALUE, usable anywhere
-- an expression is allowed: SELECT, WHERE, ORDER BY, GROUP BY.
--
--   CASE
--     WHEN <condition> THEN <value>
--     WHEN <condition> THEN <value>
--     ELSE <value>                    -- optional; unmatched rows get NULL without it
--   END
--
-- Conditions are checked top to bottom; the FIRST match wins, the rest
-- are skipped — order your WHEN clauses from most to least specific.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. A literal CASE, no table involved
-- -------------------------------------------------------------
SELECT CASE WHEN 2 > 3 THEN 'Greater' ELSE 'Lesser' END;
-- → 'Lesser'


-- -------------------------------------------------------------
-- 2. A per-row CASE — bucketing salaries into labels
-- -------------------------------------------------------------
SELECT e.first_name, e.salary,
CASE
    WHEN e.salary > 15000 THEN 'High'
    WHEN e.salary > 10000 THEN 'Medium'
    ELSE 'Low'
END AS salary_tag,
e.hire_date
FROM employees e
HAVING salary_tag = 'high';

-- Why HAVING and not WHERE here? `salary_tag` only exists as a SELECT
-- alias — it isn't a real column. WHERE runs BEFORE the SELECT list is
-- evaluated (see file 13 §3), so `WHERE salary_tag = 'high'` would
-- fail with "Unknown column 'salary_tag' in WHERE clause". HAVING runs
-- AFTER SELECT, so it can see the alias — and works here even with no
-- GROUP BY, because with no GROUP BY every row is its own group of one
-- (same idea as file 13 §2).
--
-- ⚠️ Also notice 'high' matched 'High' — MySQL's default collation
-- compares text case-INsensitively, so this coincidentally works. That
-- is not guaranteed across every database or collation setting. Write
-- the exact case, or be explicit with LOWER()/UPPER():
--   HAVING LOWER(salary_tag) = 'high'


-- -------------------------------------------------------------
-- 3. The cleaner alternative — wrap it in a derived table, use WHERE
-- -------------------------------------------------------------
-- Push the CASE into a subquery. By the time the OUTER query's WHERE
-- runs, salary_tag is a real column of that derived table — no more
-- "alias doesn't exist yet" problem, so plain WHERE works normally.
SELECT *
FROM (
    SELECT first_name, salary,
    CASE
        WHEN salary > 15000 THEN 'High'
        WHEN salary > 10000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_tag,
    hire_date
    FROM employees
) e
WHERE e.salary_tag = 'High';

-- Prefer THIS pattern (or the CTE version in file 16) over repurposing
-- HAVING as a WHERE substitute in code you intend to keep. HAVING
-- without GROUP BY works, but it reads as "I meant WHERE" to anyone
-- reviewing it later.


-- -------------------------------------------------------------
-- 4. CASE + GROUP BY + HAVING together
-- -------------------------------------------------------------
-- How many employees land in each salary bucket, keeping only buckets
-- with more than 5 people:
SELECT e.first_name, e.salary,
CASE
    WHEN e.salary > 15000 THEN 'High'
    WHEN e.salary > 10000 THEN 'Medium'
    ELSE 'Low'
END AS salary_tag,
COUNT(*)
FROM employees e
GROUP BY salary_tag
HAVING COUNT(*) > 5;

-- ⚠️ Look closely: e.first_name and e.salary are in the SELECT list
-- but are NEITHER in GROUP BY NOR wrapped in an aggregate — exactly
-- what ONLY_FULL_GROUP_BY is supposed to reject (file 09 §3). This
-- only runs because that guard was switched off earlier in this same
-- session and MySQL's ONLY_FULL_GROUP_BY setting is per-SESSION, not
-- per-query — it stayed off. The first_name/salary shown next to each
-- bucket is an ARBITRARY employee from that bucket, not meaningful.
--
-- ✅ The correct version drops the non-grouped, non-aggregated columns:
SELECT
CASE
    WHEN e.salary > 15000 THEN 'High'
    WHEN e.salary > 10000 THEN 'Medium'
    ELSE 'Low'
END AS salary_tag,
COUNT(*) AS headcount
FROM employees e
GROUP BY salary_tag
HAVING headcount > 5;

-- Also notice: GROUP BY salary_tag references the SELECT alias too —
-- the same MySQL extension that lets HAVING do it (file 13 §3) applies
-- to GROUP BY as well. Without it you'd have to repeat the whole CASE
-- expression in the GROUP BY clause.


-- =============================================================
-- TAKEAWAYS
--   • CASE WHEN … THEN … ELSE … END — first match wins, top to bottom
--   • WHERE can't see a SELECT-list CASE alias; HAVING can (runs later)
--   • For real code, prefer a derived table (or CTE) + WHERE over
--     HAVING-without-GROUP-BY — same result, clearer intent
--   • GROUP BY and HAVING can both reference a SELECT alias in MySQL —
--     no need to repeat the full CASE expression
--   • If ONLY_FULL_GROUP_BY was disabled earlier in the session, it
--     stays off — watch for ungrouped, non-aggregated columns creeping
--     back into a GROUP BY query
-- =============================================================
