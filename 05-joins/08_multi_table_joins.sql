-- =============================================================
-- 08 — Chaining joins across five tables
-- Database: office
-- =============================================================
-- There is NO column linking an employee to a region. To get there you
-- walk the chain, one join per arrow in the ER diagram:
--
--   employees → departments → locations → countries → regions
--
-- Each join adds exactly one link. Build it one line at a time and run
-- it after every line — that is the whole technique.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Build it up incrementally
-- -------------------------------------------------------------
-- Step 1 — employee + department
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- Step 2 — + the city that department sits in
SELECT e.first_name, d.department_name, l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id;

-- Step 3 — + the country
SELECT e.first_name, d.department_name, l.city, c.country_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id;

-- Step 4 — + the region. The full chain.
SELECT e.first_name, d.department_name, l.city, c.country_name, r.region_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id;


-- -------------------------------------------------------------
-- 2. The finished query: every employee and their region
-- -------------------------------------------------------------
-- CONCAT() glues strings together. Note the ' ' — without it you get
-- "StevenKing". CONCAT_WS(' ', a, b) does the same with a separator.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    r.region_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id;

-- ⚠️ CONCAT returns NULL if ANY argument is NULL. An employee with no
--    last_name gets NULL for the whole name, not just the missing part.
--    CONCAT_WS skips NULLs instead:
SELECT
    CONCAT_WS(' ', e.first_name, e.last_name) AS name,
    r.region_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id;


-- -------------------------------------------------------------
-- 3. Why LEFT JOIN all the way down
-- -------------------------------------------------------------
-- The chain is only as strong as its weakest link. With INNER JOINs, an
-- employee is dropped if ANY link is missing — no department, or a
-- department with no location, or a location with no country.
-- With LEFT JOINs, every employee stays; the missing parts show as NULL.
--
-- Rule: LEFT JOIN when you want to keep the driving table complete.
--       INNER JOIN when a missing link means the row is irrelevant.

-- Run this to see the difference in row count:
SELECT COUNT(*) AS with_left_joins
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id;

SELECT COUNT(*) AS with_inner_joins
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations   l ON d.location_id   = l.location_id
JOIN countries   c ON l.country_id    = c.country_id
JOIN regions     r ON c.region_id     = r.region_id;


-- -------------------------------------------------------------
-- 4. Filtering and sorting the chain
-- -------------------------------------------------------------
-- Everyone working in Europe, highest paid first.
SELECT
    CONCAT_WS(' ', e.first_name, e.last_name) AS name,
    e.salary,
    c.country_name,
    r.region_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations   l ON d.location_id   = l.location_id
LEFT JOIN countries   c ON l.country_id    = c.country_id
LEFT JOIN regions     r ON c.region_id     = r.region_id
WHERE r.region_name = 'Europe'
ORDER BY e.salary DESC;

-- ⚠️ Putting a filter on a LEFT-joined table in WHERE turns that LEFT
--    JOIN back into an INNER JOIN — rows where region_name is NULL fail
--    the condition and get dropped. That's usually what you want here,
--    but be aware it's happening.


-- =============================================================
-- TAKEAWAYS
--   • One JOIN per arrow in the ER diagram
--   • Build long joins one line at a time, running as you go
--   • LEFT all the way down keeps the driving table intact
--   • CONCAT() → NULL if any part is NULL; CONCAT_WS() skips NULLs
--   • WHERE on a LEFT-joined column silently makes it an INNER JOIN
-- =============================================================
