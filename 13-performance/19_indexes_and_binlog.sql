-- =============================================================
-- 19 — Indexes, storage engines, and the binary log
-- Database: office
-- =============================================================
-- Mostly conceptual this session — how a lookup gets fast, what
-- InnoDB vs MyISAM means, and what the binary log actually records.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. Why an indexed lookup is fast
-- -------------------------------------------------------------
-- employee_id is the PRIMARY KEY, so it already has an index — that's
-- why this returns instantly even on a huge table:
SELECT * FROM employees WHERE employee_id = 122;

-- Without an index, MySQL would have to check every single row (a
-- "full table scan") to find the one where employee_id = 122.
--
-- An index is organized as a B-tree: rows are grouped into sorted
-- pages, and each page "knows" the range of values it holds. Looking
-- up 122 means comparing against page boundaries and picking a side —
-- "is 122 in the page covering 100–120, or the one covering 120–140?"
-- — narrowing down to the exact page in a handful of comparisons,
-- instead of reading the whole table. The same idea as flipping
-- straight to the right section of a phone book instead of reading it
-- front to back.


-- -------------------------------------------------------------
-- 2. Adding an index to a column that didn't have one
-- -------------------------------------------------------------
-- phone_number had no index before this — filtering or joining on it
-- meant a full table scan. This adds one:
CREATE INDEX idx_trans_id
ON employees(phone_number);

-- Indexes aren't free: every INSERT/UPDATE/DELETE now also has to keep
-- this extra index up to date. Add one for columns you actually
-- filter, join, or sort on often — not every column by default.


-- -------------------------------------------------------------
-- 3. Storage engines, in one line each
-- -------------------------------------------------------------
-- InnoDB (the default, and everything used throughout this course):
--   transactions, foreign keys, row-level locking.
-- MyISAM (older, mostly legacy):
--   no transactions, no foreign keys, table-level locking.
-- Use InnoDB unless you have a specific reason not to — you already
-- have been, every table in `office` is InnoDB.


-- -------------------------------------------------------------
-- 4. A real DELETE, and what got recorded
-- -------------------------------------------------------------
-- ⚠️ SQL_SAFE_UPDATES was switched off back in file 17 and never
--    switched back on before this ran. This genuinely removed employee
--    122 with no corresponding re-insert anywhere later in the
--    session. If you're following along on your own database, decide
--    first whether you actually want that row gone.
DELETE FROM employees
WHERE employee_id = 122;


-- -------------------------------------------------------------
-- 5. The binary log (binlog)
-- -------------------------------------------------------------
-- The binlog is a running, ordered record of every statement that
-- CHANGED data — every INSERT/UPDATE/DELETE/ALTER — each with a
-- timestamp and transaction id. It's what makes two things possible:
--   • replication — a second server ("replica") replays the same
--     binlog to stay in sync with the primary
--   • point-in-time recovery — restore a backup, then re-apply the
--     binlog up to just before a mistake, instead of losing everything
--     since the backup
--
-- Is logging turned on for this server?
SHOW VARIABLES LIKE 'log_bin';

-- What log files exist?
SHOW BINARY LOGS;

-- What's actually inside one of them? Each row is one recorded
-- statement — you'd see the DELETE above appear here as its own event,
-- with its own transaction id.
SHOW BINLOG EVENTS IN 'binlog.000055';


-- -------------------------------------------------------------
-- 6. Replication lag — a term, not a query
-- -------------------------------------------------------------
-- When a replica applies the primary's binlog with a delay, reads
-- against that replica can return slightly stale data for a moment.
-- Nothing to run here — just a concept worth recognizing by name.


-- =============================================================
-- TAKEAWAYS
--   • An index lets MySQL narrow a lookup to one B-tree page instead
--     of scanning every row — but every write now maintains it too
--   • InnoDB (transactions, FKs, row locks) vs MyISAM (none of that,
--     legacy) — default to InnoDB
--   • The binlog records every data-changing statement, in order —
--     it's what powers both replication and point-in-time recovery
--   • SQL_SAFE_UPDATES left off from file 17 meant this session's
--     DELETE ran with no safety net — remember to set it back to 1
-- =============================================================
