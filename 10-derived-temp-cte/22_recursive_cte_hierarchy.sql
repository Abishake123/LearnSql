-- =============================================================
-- 22 — Recursive CTEs: walking a manager -> reportee chain
-- Database: office
-- =============================================================
-- File 16 named "recursive CTE" as a topic not yet covered — this is
-- that lesson. A normal CTE (file 16) is just a subquery with a name.
-- A RECURSIVE CTE is different in kind: it references ITSELF, and
-- MySQL keeps re-running it until a pass turns up nothing new.
--
-- A visual, step-by-step walkthrough of exactly how this executes —
-- worth pulling up in class — lives here:
--   https://claude.ai/code/artifact/4af0a8b3-160d-45bd-a626-2568bc57c48f
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The problem: employees.manager_id only points ONE level up
-- -------------------------------------------------------------
-- The self-join from file 07 gets you an employee and THEIR manager —
-- exactly one level. It cannot get you the whole chain up to the top,
-- or the whole tree down from a given manager, because a JOIN has a
-- fixed number of hops baked into the query. A recursive CTE doesn't:
-- it keeps hopping until there's nowhere left to go.
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
-- ^ one level only. To go arbitrarily deep, you need recursion.


-- -------------------------------------------------------------
-- 2. The recursive CTE, in full
-- -------------------------------------------------------------
-- MySQL requires the keyword RECURSIVE even though the CTE is just
-- called employee_hierarchy everywhere else in the query — leave it
-- out and the self-reference below becomes a syntax error.
WITH RECURSIVE employee_hierarchy AS (

    -- ANCHOR MEMBER — runs exactly ONCE.
    -- Finds the top of the tree: whoever has no manager.
    SELECT employee_id, first_name, last_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- RECURSIVE MEMBER — runs once per PASS, not once total.
    -- Note the self-reference: `JOIN employee_hierarchy` is what makes
    -- this recursive. Each pass finds "everyone whose manager was
    -- found in the previous pass."
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id

)
SELECT employee_id, first_name, last_name, manager_id, level
FROM employee_hierarchy
ORDER BY level, manager_id;

-- ⚠️ UNION ALL, not UNION. Plain UNION would de-duplicate, which means
--    comparing every new row against everything found so far on every
--    single pass — wasted work, since two different employees at the
--    same level were never duplicates to begin with.


-- -------------------------------------------------------------
-- 3. What actually happens, execution-model style
-- -------------------------------------------------------------
--   Pass 0 (the anchor): finds Steven King (level 1). This becomes
--            both part of the result AND the "current batch."
--   Pass 1: JOIN employees to the CURRENT BATCH ONLY (Steven King) on
--            manager_id — finds Neena Kochhar and Lex De Haan (level
--            2). They become the result's newest rows AND the next
--            current batch.
--   Pass 2: JOIN employees to Pass 1's new rows only — finds Alexander
--            Hunold (level 3, reporting to Lex De Haan).
--   Pass 3: JOIN employees to Pass 2's new row only — finds Bruce
--            Ernst, David Austin, Valli Pataballa (level 4).
--   Pass 4: JOIN employees to Pass 3's new rows — finds NOBODY.
--            An empty pass is the one and only stop condition. It is
--            not a row-count check or a fixed number of iterations —
--            the recursion runs exactly as many passes as the tree is
--            deep, whatever that turns out to be.
--
-- The critical detail: each pass joins against ONLY the rows the
-- PREVIOUS pass added, not the whole accumulated result so far. That's
-- what keeps the work in each pass proportional to one level of the
-- tree, and it's also why the recursive member's FROM/JOIN naming the
-- CTE really does mean "the batch that was just produced," not
-- "everything found to date."


-- -------------------------------------------------------------
-- 4. Making the depth readable
-- -------------------------------------------------------------
-- The `level` column is useful on its own, but printing the
-- indentation directly is a nice touch for a report:
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, first_name, last_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT
    CONCAT(REPEAT('  ', level - 1), first_name, ' ', last_name) AS org_chart,
    level
FROM employee_hierarchy
ORDER BY level, manager_id;


-- -------------------------------------------------------------
-- 5. Going the other direction: up to the top, not down
-- -------------------------------------------------------------
-- Same mechanism, mirrored. Instead of anchoring at "no manager" and
-- joining DOWN via manager_id, anchor at a specific employee and join
-- UP via manager_id — this gives you one employee's full chain of
-- command, all the way to the top.
WITH RECURSIVE chain_of_command AS (
    SELECT employee_id, first_name, last_name, manager_id, 1 AS steps_up
    FROM employees
    WHERE employee_id = 104   -- Bruce Ernst

    UNION ALL

    SELECT m.employee_id, m.first_name, m.last_name, m.manager_id, cc.steps_up + 1
    FROM employees m
    JOIN chain_of_command cc ON m.employee_id = cc.manager_id
)
SELECT employee_id, first_name, last_name, steps_up
FROM chain_of_command
ORDER BY steps_up;


-- -------------------------------------------------------------
-- 6. Bad data can loop forever — MySQL caps it
-- -------------------------------------------------------------
-- If a manager_id chain ever formed a CYCLE (A reports to B, B reports
-- to A — a data bug, but a possible one), the recursion would never
-- hit an empty pass on its own. MySQL's cte_max_recursion_depth
-- (default 1000) throws an error once a query recurses past that many
-- levels, so a cycle fails loudly instead of hanging the connection.
SHOW VARIABLES LIKE 'cte_max_recursion_depth';

-- Raise it only for a query that's genuinely deep, not to paper over
-- a suspected cycle:
--   SET SESSION cte_max_recursion_depth = 5000;


-- =============================================================
-- TAKEAWAYS
--   • A normal CTE names a subquery; a RECURSIVE CTE calls itself
--   • WITH RECURSIVE is mandatory in MySQL — plain WITH errors on the
--     self-reference
--   • Anchor member runs once; recursive member runs once per PASS,
--     each time joining only the previous pass's new rows
--   • UNION ALL, not UNION — duplicates aren't the concern, wasted
--     de-dup comparisons are
--   • The loop's only exit is a pass that finds zero new rows
--   • The same shape works upward (chain of command) or downward (org
--     chart) — only the anchor and the join direction change
--   • cte_max_recursion_depth is the safety net against a data cycle
-- =============================================================
