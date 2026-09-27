-- =============================================================
-- 25 — Composite primary keys, TRUNCATE, and OFFSET revisited
-- Database: office
-- =============================================================
-- A grab-bag session: a primary key made of TWO columns, the fastest
-- way to empty a table, and another look at paging through rows.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Composite primary key — uniqueness across a PAIR of columns
-- -------------------------------------------------------------
-- A student takes many courses; a course has many students. Neither
-- student_id nor course_id is unique on its own in an enrollments
-- table — but the PAIR is: a student can't enroll in the same course
-- twice.
CREATE TABLE enrollments (
    student_id  INT,
    course_id   INT,
    course_name VARCHAR(50),
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollments VALUES (101, 234, 'Databases');
INSERT INTO enrollments VALUES (101, 235, 'Networks');    -- same student, new course: OK
INSERT INTO enrollments VALUES (102, 234, 'Databases');   -- same course, new student: OK

-- ⚠️ INSERT INTO enrollments VALUES (101, 234, 'Databases');
--    → ERROR 1062: Duplicate entry '101-234' for key 'PRIMARY'
--    The PAIR (101, 234) already exists.

-- Looking a row up by the full key uses the primary-key index:
SELECT *
FROM enrollments
WHERE student_id = 101 AND course_id = 234;

-- Column ORDER in the key matters. The index is sorted by student_id
-- first, then course_id — like a phone book sorted by surname, then
-- first name. So `WHERE student_id = 101` alone can still use it, but
-- `WHERE course_id = 234` alone can't (file 27 shows how to check
-- with EXPLAIN).


-- -------------------------------------------------------------
-- 2. TRUNCATE vs DELETE
-- -------------------------------------------------------------
-- Both empty a table. They are not the same thing.
TRUNCATE TABLE enrollments;
--
--                     DELETE FROM t                TRUNCATE TABLE t
--   Removes           rows matching WHERE          ALL rows, no WHERE
--   How               row by row                   drops & recreates the table
--   Speed             slow on big tables           near-instant
--   AUTO_INCREMENT    keeps counting               resets to 1
--   ROLLBACK?         yes, inside a transaction    NO — it's DDL, it commits
--   Triggers fire?    yes                          no
--
-- ⚠️ TRUNCATE can't be undone. Treat it like DROP, not like DELETE.

DROP TABLE enrollments;   -- tidy up the demo table


-- -------------------------------------------------------------
-- 3. OFFSET, again — pages of rows
-- -------------------------------------------------------------
-- File 04 introduced LIMIT n OFFSET m. OFFSET = how many rows to SKIP.
SELECT * FROM employees
ORDER BY employee_id
LIMIT 1 OFFSET 20;      -- just the 21st row

SELECT * FROM employees
ORDER BY employee_id
LIMIT 5 OFFSET 15;      -- rows 16–20 = page 4 of a 5-per-page list

-- Page p (starting from 1) with n rows per page:
--   LIMIT n OFFSET (p - 1) * n
--
-- ⚠️ In class these ran without ORDER BY. Without one, "the 21st row"
-- is whatever order MySQL happens to return — it can change between
-- runs. Always ORDER BY before you LIMIT/OFFSET.


-- =============================================================
-- TAKEAWAYS
--   • PRIMARY KEY (a, b) = the PAIR must be unique, not each column
--   • A composite index helps queries on its LEFTMOST column(s)
--   • TRUNCATE: all rows, instant, resets AUTO_INCREMENT, can't roll back
--   • DELETE: row by row, can use WHERE, can roll back
--   • LIMIT n OFFSET (p - 1) * n for page p — and always ORDER BY first
-- =============================================================
