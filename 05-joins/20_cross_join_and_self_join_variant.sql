-- =============================================================
-- 20 — CROSS JOIN, and a self-join written the other direction
-- Database: office
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. CROSS JOIN — every row paired with every row
-- -------------------------------------------------------------
-- No ON clause. Every row of employees is paired with every row of
-- departments, regardless of whether department_id actually matches.
-- Result size = (rows in employees) × (rows in departments).
SELECT e.first_name, e.employee_id, e.department_id, d.department_name
FROM employees e
CROSS JOIN departments d;

-- This is not a mistake — a Cartesian product is the entire point of
-- CROSS JOIN. It's the right tool when you need every COMBINATION of
-- two sets: every product × every size, every date × every store shift.
-- Rare in day-to-day querying, but exactly right when that's the ask.

-- ⚠️ Easy to trigger by accident: old-style comma joins —
--     FROM employees e, departments d
--   — with no WHERE linking them produce the SAME Cartesian product,
--   silently. That's the classic accidental-Cartesian-product bug.
--   Always write an explicit JOIN ... ON (or a deliberate CROSS JOIN),
--   so the intent is unambiguous on the page.


-- -------------------------------------------------------------
-- 2. Self-join, written from the other side
-- -------------------------------------------------------------
-- File 07 wrote the manager self-join as:
--     employees e LEFT JOIN employees m ON e.manager_id = m.employee_id
-- This session wrote the same relationship starting from the opposite
-- table, with RIGHT JOIN instead of LEFT:
SELECT e.employee_id, e.first_name AS employee,
       m.employee_id, m.first_name AS manager
FROM employees e
RIGHT JOIN employees m ON e.employee_id = m.manager_id;

-- Read the JOIN CONDITION carefully, not the aliases: `e.employee_id =
-- m.manager_id` matches a row from `e` to a row from `m` when e's OWN
-- id equals m's manager_id — meaning `e` IS THE MANAGER, and `m` is
-- the one being managed.
--
-- ⚠️ The column labels say the opposite: `e.first_name AS employee` and
-- `m.first_name AS manager` are swapped relative to what the join
-- condition actually establishes. Never trust an alias name on its
-- own — trace the ON clause to find out each side's real role.
--
-- ✅ Corrected, with labels matching the actual roles:
SELECT m.employee_id, m.first_name AS employee,
       e.employee_id, e.first_name AS manager
FROM employees e
RIGHT JOIN employees m ON e.employee_id = m.manager_id;

-- This produces the same relationships as file 07's version — same
-- manager/report pairs, just walked from the opposite table with
-- RIGHT instead of LEFT. Either direction needs the OUTER side of the
-- join (LEFT there, RIGHT here) so the top boss — manager_id IS NULL —
-- still shows up with no manager row attached.


-- -------------------------------------------------------------
-- 3. Sanity-check the self-join with a plain COUNT
-- -------------------------------------------------------------
-- How many people report directly to employee 100? Compare this
-- number against how many rows the self-join produces for manager_id
-- = 100 — the same "verify with something simpler" habit as file 12 §4.
SELECT COUNT(*) FROM employees WHERE manager_id = 100;


-- =============================================================
-- TAKEAWAYS
--   • CROSS JOIN = deliberate Cartesian product, no ON clause needed
--   • An accidental comma-join with no WHERE is the same bug, silently
--   • In any join, the ON condition — not the alias names — tells you
--     which side actually plays which role
--   • The same self-join relationship can be written LEFT-from-one-side
--     or RIGHT-from-the-other; pick whichever reads clearer, but the
--     outer side always has to be the one that can be "manager-less"
-- =============================================================
