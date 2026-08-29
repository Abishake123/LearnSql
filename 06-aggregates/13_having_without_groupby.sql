-- =============================================================
-- 13 — HAVING beyond GROUP BY
-- Database: office
-- =============================================================
-- File 09 introduced HAVING as "WHERE, but for groups". This session
-- pushed on two edge cases that don't fit that description cleanly:
--   • HAVING with NO GROUP BY at all
--   • HAVING referencing a SELECT-list ALIAS, not a real column
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. HAVING with no GROUP BY — the whole table is one group
-- -------------------------------------------------------------
-- Without GROUP BY, an aggregate like COUNT(*) already collapses the
-- entire table into a single row (see file 09 §1). HAVING can still
-- filter that one row: if the condition is false, you get ZERO rows
-- back instead of the summary row.
SELECT COUNT(*) AS employee_count
FROM employees
HAVING employee_count > 10;

-- If the company had 10 or fewer employees, this returns nothing at
-- all — not an error, not a "false" value, just an empty result set.


-- -------------------------------------------------------------
-- 2. HAVING with no GROUP BY and no aggregate — legal, but not the
--    right tool
-- -------------------------------------------------------------
-- This runs. It even gives the right answer.
SELECT * FROM employees
HAVING salary < 5000;

-- ⚠️ It is functionally identical to:
SELECT * FROM employees
WHERE salary < 5000;

-- Use WHERE for this. Two reasons:
--   1. WHERE is the semantically correct clause for filtering rows —
--      HAVING exists to filter GROUPS. This isn't a group.
--   2. WHERE can use an index on `salary` to skip straight to the
--      matching rows. HAVING runs later in the query pipeline (after
--      grouping would have happened) and can't use that same shortcut
--      — MySQL has to evaluate it against every row that made it
--      through the earlier stages.
-- Reach for HAVING only when the condition needs an aggregate, or
-- needs to reference a SELECT alias WHERE genuinely cannot see — the
-- next section is exactly that second case.


-- -------------------------------------------------------------
-- 3. Why you'd ever WANT to reference a SELECT alias in HAVING
-- -------------------------------------------------------------
-- Clause execution order (see file 04's cheatsheet table) runs FROM →
-- WHERE → GROUP BY → HAVING → SELECT → ORDER BY... actually SELECT
-- sits between HAVING and ORDER BY, which is exactly the point: WHERE
-- runs BEFORE the SELECT list is evaluated, so an alias defined in
-- SELECT does not exist yet as far as WHERE is concerned. HAVING runs
-- AFTER SELECT, so it CAN see those aliases.
--
-- Standard SQL only allows HAVING to reference GROUP BY columns and
-- aggregates. MySQL relaxes this and also allows a SELECT alias —
-- which is what makes the trick in section 2 legal at all.


-- -------------------------------------------------------------
-- 4. A real GROUP BY + HAVING(alias) example
-- -------------------------------------------------------------
-- Every region with more than 10 employees. Two things worth noticing:
--   • the join chain starts at `regions` and walks OUTWARD to
--     `employees` — the reverse direction of file 08's chain, which
--     started at `employees` and walked up to `regions`. Same
--     relationships, either starting point works.
--   • HAVING references the alias `emp_count` directly, instead of
--     repeating `COUNT(e.employee_id) > 10` — shorter, and reads better.
SELECT r.region_name, COUNT(e.employee_id) AS emp_count
FROM regions r
LEFT JOIN countries   c ON c.region_id     = r.region_id
LEFT JOIN locations   l ON l.country_id    = c.country_id
LEFT JOIN departments d ON d.location_id   = l.location_id
LEFT JOIN employees   e ON e.department_id = d.department_id
GROUP BY r.region_name
HAVING emp_count > 10;

-- Compare with file 09's version, which repeats the full expression
-- instead of using the alias — both are valid MySQL:
--   HAVING COUNT(*) > 5


-- =============================================================
-- TAKEAWAYS
--   • No GROUP BY ⇒ the whole table is one group; HAVING can still
--     filter that single row down to zero
--   • HAVING with no aggregate and no GROUP BY works like WHERE, but
--     is the wrong tool — slower, and semantically misleading
--   • WHERE can't see SELECT-list aliases (it runs first); HAVING can
--     (it runs after SELECT) — that's the ONE legitimate reason to
--     reach for HAVING without an aggregate
--   • MySQL lets HAVING reference either the full aggregate expression
--     or its alias — pick whichever reads more clearly
-- =============================================================
