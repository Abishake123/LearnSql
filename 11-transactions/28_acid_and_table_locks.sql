-- =============================================================
-- 28 — ACID, and locking a table
-- Database: office
-- =============================================================
-- Files 05 and 17 used START TRANSACTION / COMMIT / ROLLBACK /
-- SAVEPOINT. This session named the guarantees a transaction gives
-- you — ACID — and looked at locking a whole table by hand.
-- =============================================================

USE office;


-- -------------------------------------------------------------
-- 1. The four ACID properties
-- -------------------------------------------------------------
--   A — Atomicity    All the statements in a transaction happen, or
--                    NONE of them do. No half-finished work.
--   C — Consistency  A transaction moves the database from one valid
--                    state to another — keys, constraints, and rules
--                    still hold afterwards.
--   I — Isolation    Transactions running at the same time don't see
--                    each other's unfinished changes.
--   D — Durability   Once COMMIT returns, the change survives a crash
--                    or power cut.


-- -------------------------------------------------------------
-- 2. Atomicity — the bank-transfer example
-- -------------------------------------------------------------
-- In class we sketched this on a made-up table. Here's a real one to
-- run it on:
CREATE TABLE bank_accounts (
    username VARCHAR(20) PRIMARY KEY,
    amt      DECIMAL(10, 2) NOT NULL
);
INSERT INTO bank_accounts VALUES ('Jhon', 2000), ('Priya', 500);

-- Jhon pays Priya 1000. That's TWO updates, and they must happen
-- together: money leaves one account AND arrives in the other.
START TRANSACTION;

UPDATE bank_accounts SET amt = amt - 1000 WHERE username = 'Jhon';    -- t1
UPDATE bank_accounts SET amt = amt + 1000 WHERE username = 'Priya';   -- t2

COMMIT;

-- If anything goes wrong between t1 and t2 — an error, a crash, a
-- dropped connection — nothing is committed, and the money isn't lost
-- in between. To abandon it deliberately:
START TRANSACTION;
UPDATE bank_accounts SET amt = amt - 2000 WHERE username = 'Jhon';
-- Jhon only has 1000 left. Changed our minds:
ROLLBACK;

SELECT * FROM bank_accounts;   -- Jhon 1000, Priya 1500 — the rollback left no trace

-- ⚠️ Without START TRANSACTION, MySQL is in autocommit mode: EVERY
-- statement commits on its own the moment it finishes. t1 would be
-- permanent even if t2 then failed.


-- -------------------------------------------------------------
-- 3. LOCK TABLES — keeping everyone else out
-- -------------------------------------------------------------
-- InnoDB locks individual ROWS automatically during a transaction,
-- which is usually all you need. LOCK TABLES is the blunt instrument:
LOCK TABLES employees WRITE;
-- Now ONLY this session can read or write employees. Every other
-- session that touches it waits until we unlock.
--
--   READ  lock — everyone may read, nobody may write
--   WRITE lock — only the locking session may read or write
--
-- ⚠️ While tables are locked, this session can use ONLY the tables it
-- locked — a query on any other table errors out.

UNLOCK TABLES;   -- always release; disconnecting releases it too

DROP TABLE bank_accounts;   -- tidy up the demo table


-- =============================================================
-- TAKEAWAYS
--   • ACID = Atomicity, Consistency, Isolation, Durability
--   • Atomicity is why a transfer lives in ONE transaction: both
--     updates or neither
--   • Autocommit is on by default — START TRANSACTION turns it off
--     until COMMIT / ROLLBACK
--   • LOCK TABLES t WRITE locks out every other session; always
--     UNLOCK TABLES. InnoDB's automatic row locks usually suffice
-- =============================================================
