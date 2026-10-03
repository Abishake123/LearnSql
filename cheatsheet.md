# SQL Cheat Sheet — everything from the sessions on one page

## Clause order

You must **write** them in this order, and the database **executes** them in a different one:

| Written | Executed |
|---|---|
| `SELECT` | 5 |
| `FROM` / `JOIN` | 1 |
| `WHERE` | 2 |
| `GROUP BY` | 3 |
| `HAVING` | 4 |
| `ORDER BY` | 6 |
| `LIMIT` | 7 |

`FROM` runs first — that's why you can't use a `SELECT` alias inside `WHERE`, but you *can* use it in `ORDER BY`.

Full breakdown — every clause, what each one can see, and `INSERT`/`UPDATE`/`DELETE` order: [`clause-order.md`](clause-order.md).

---

## Reading data

```sql
USE office;                       -- pick the database
SHOW TABLES;                      -- what tables exist
DESCRIBE employees;               -- what columns, what types

SELECT * FROM employees;          -- everything (exploring only)
SELECT first_name, salary FROM employees;
SELECT COUNT(*) AS total FROM employees;
```

## Filtering

| Need | Write |
|---|---|
| Equal | `WHERE salary = 7000` |
| Not equal | `WHERE salary != 7000` or `<> 7000` |
| Range (inclusive) | `WHERE salary BETWEEN 5000 AND 7000` |
| One of several | `WHERE job_id IN (6, 7, 8)` |
| Text starts with | `WHERE name LIKE 'Jo%'` |
| Text, exactly 5 chars | `WHERE name LIKE 'Ur_a_'` |
| Missing value | `WHERE salary IS NULL` |
| Combine | `WHERE a = 1 AND (b = 2 OR c = 3)` |

**Wildcards:** `%` = any number of characters · `_` = exactly one.

**NULL traps:** `NULL = NULL` is not true. Always `IS NULL` / `IS NOT NULL`. The NULL-safe operator is `<=>`.

## Sorting and trimming

```sql
ORDER BY salary DESC              -- DESC = high→low, ASC = default
ORDER BY dept ASC, salary DESC    -- second column breaks ties
LIMIT 10                          -- first 10 rows
LIMIT 10 OFFSET 20                -- page 3, 10 per page
SELECT DISTINCT first_name        -- unique values
```

`LIMIT` without `ORDER BY` returns arbitrary rows.

---

## Joins

```sql
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

| Type | Keeps |
|---|---|
| `INNER JOIN` (= `JOIN`) | Only rows matching on both sides |
| `LEFT JOIN` | All rows from the `FROM` table; NULLs where no match |
| `RIGHT JOIN` | All rows from the joined table |
| `FULL OUTER JOIN` | Both sides — **not supported in MySQL**, emulate with `UNION` |
| Self join | A table joined to itself (`manager_id → employee_id`) |
| `CROSS JOIN` | Every row × every row — no `ON` clause, a deliberate Cartesian product |

**One question decides it:** do you want rows that have no match? No → `INNER`. Yes → `LEFT`.

**Self joins:** trust the `ON` condition, not the alias names, to figure out which side plays which role — `e.employee_id = m.manager_id` means `e` is the manager, even if a column is mislabeled `AS employee`.

**`CROSS JOIN`:** `FROM a, b` with no `WHERE` linking them is the *same* Cartesian product, written by accident. Always use an explicit `JOIN ... ON` or a deliberate `CROSS JOIN`.

**Find orphans:**

```sql
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL      -- employees with no department
```

**`ON` vs `WHERE`:** `ON` says how tables connect; `WHERE` says which resulting rows survive. A `WHERE` filter on a LEFT-joined column silently turns the join into an INNER one.

**The chain in this schema:**

```
employees → departments → locations → countries → regions
```

One `JOIN` per arrow. Build it one line at a time, running after each.

---

## Aggregates

```sql
COUNT(*)   SUM()   AVG()   MIN()   MAX()

SELECT department_id, COUNT(*) AS headcount
FROM employees
WHERE salary > 5000        -- filters ROWS, before grouping
GROUP BY department_id
HAVING COUNT(*) > 3        -- filters GROUPS, after grouping
ORDER BY headcount DESC;
```

- Every `SELECT` column must be in `GROUP BY` **or** inside an aggregate. `ONLY_FULL_GROUP_BY` enforces this — disabling it hides the error, it doesn't fix the query.
- `COUNT(*)` counts rows; `COUNT(col)` skips NULLs. **Across a LEFT JOIN, use `COUNT(col)`** or empty groups wrongly count as 1.
- Aggregates can't appear in `WHERE` — that's what `HAVING` and subqueries are for.
- **Exception to the GROUP BY rule:** if you `GROUP BY` a foreign key (`e.job_id`) that maps to another table's primary key, you *can* `SELECT` that other table's columns (`j.job_title`) without erroring — each group has exactly one possible value, so MySQL allows it even under `ONLY_FULL_GROUP_BY`:
  ```sql
  SELECT j.job_title, COUNT(e.employee_id) AS headcount
  FROM employees e
  JOIN jobs j ON j.job_id = e.job_id
  GROUP BY e.job_id;          -- fine: job_title is functionally dependent on e.job_id
  ```

**`HAVING` without `GROUP BY`:** legal, but usually the wrong tool.

```sql
SELECT COUNT(*) AS n FROM employees HAVING n > 10;   -- whole table = one group; 0 or 1 rows back
SELECT * FROM employees HAVING salary < 5000;        -- works like WHERE, but can't use an index — use WHERE
```

The one real reason to reach for it: `WHERE` runs *before* the `SELECT` list is evaluated, so it can't see a `SELECT`-list alias. `HAVING` runs *after*, so it can — that's what makes `HAVING salary_tag = 'High'` (where `salary_tag` is a `CASE` alias) legal. For real code, prefer wrapping the `CASE`/alias in a derived table or CTE and filtering with `WHERE` instead — same result, clearer intent.

## Subqueries

```sql
WHERE region_id = (SELECT region_id FROM regions WHERE region_name = 'Africa')   -- one value
WHERE region_id IN (SELECT region_id FROM regions WHERE region_name LIKE '%America%')  -- many
WHERE salary > (SELECT AVG(salary) FROM employees)                              -- aggregate
WHERE EXISTS (SELECT 1 FROM dependents d WHERE d.employee_id = e.employee_id)   -- any match?
FROM (SELECT ... ) AS t                                                          -- derived table
```

`=` needs exactly one row back. `IN` accepts many. When in doubt, `IN`.

```sql
WHERE salary > ALL (SELECT salary FROM employees WHERE department_id = 10)   -- beats every value  = > MAX
WHERE salary > ANY (SELECT salary FROM employees WHERE department_id = 10)   -- beats at least one = > MIN
```

`= ANY` is `IN`. `ANY`/`ALL` need a **subquery** — `> ANY (1, 2, 3)` is a syntax error.

## CASE expressions

```sql
CASE
    WHEN salary > 15000 THEN 'High'
    WHEN salary > 10000 THEN 'Medium'
    ELSE 'Low'
END AS salary_tag
```

First matching `WHEN` wins, top to bottom. No `ELSE` → unmatched rows get `NULL`. Works anywhere an expression is allowed: `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`.

**Pivot** (rows → columns) — MySQL has no `PIVOT`, so wrap `CASE` in an aggregate, one per output column:

```sql
SELECT d.department_name,
       SUM(CASE WHEN j.job_title = 'Programmer'  THEN 1 ELSE 0 END) AS programmer,
       SUM(CASE WHEN j.job_title = 'Stock Clerk' THEN 1 ELSE 0 END) AS stock_clerk
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN jobs j        ON j.job_id = e.job_id
GROUP BY d.department_id;
```

## Derived tables, temp tables, CTEs

Three ways to name an intermediate result, at three different scopes:

```sql
-- Derived table — scoped to this one query
SELECT * FROM (SELECT department_id, AVG(salary) AS avg_salary FROM employees GROUP BY department_id) dt
WHERE avg_salary > 10000;

-- CTE — same scope as a derived table, cleaner syntax, top-to-bottom
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary FROM employees GROUP BY department_id
)
SELECT * FROM dept_avg WHERE avg_salary > 10000;

-- Multiple CTEs — each can reference an earlier one
WITH a AS (SELECT ...), b AS (SELECT ... FROM a WHERE ...)
SELECT * FROM b;

-- Temporary table — scoped to your WHOLE SESSION, a real table
CREATE TEMPORARY TABLE high_salary_emp AS SELECT * FROM employees WHERE salary > 10000;
DROP TEMPORARY TABLE high_salary_emp;
```

A temp table is the only one of the three you can `INSERT`/`UPDATE`/`DELETE` against — and the only one visible in `SHOW TABLES` (to your session only; other connections can't see it).

## Recursive CTEs

```sql
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, first_name, manager_id, 1 AS level     -- anchor: runs ONCE
    FROM employees WHERE manager_id IS NULL

    UNION ALL                                                   -- ALL, not UNION — no dedup needed

    SELECT e.employee_id, e.first_name, e.manager_id, eh.level + 1   -- recursive: runs once per PASS
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id      -- self-reference = the mechanism
)
SELECT * FROM employee_hierarchy ORDER BY level;
```

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS number                                   -- anchor
    UNION ALL
    SELECT number + 1 FROM numbers WHERE number < 5      -- the WHERE is what stops it
)
SELECT * FROM numbers;                                   -- 1, 2, 3, 4, 5
```

`WITH RECURSIVE` is mandatory in MySQL even though the CTE is just named normally elsewhere. Each pass joins against only the *previous* pass's new rows, not the whole result so far — the recursion stops the instant a pass finds zero new rows. `cte_max_recursion_depth` (default 1000) is the safety net if bad data ever forms a cycle. Full visual walkthrough: [`22_recursive_cte_hierarchy.sql`](10-derived-temp-cte/22_recursive_cte_hierarchy.sql).

---

## Changing data

```sql
SELECT * FROM employees WHERE employee_id = 102;   -- 1. look
UPDATE employees                                    -- 2. change
SET last_name = 'Haan'
WHERE employee_id = 102;
SELECT * FROM employees WHERE employee_id = 102;   -- 3. verify
```

🚨 **`UPDATE` without `WHERE` rewrites every row. No undo, no prompt.**

```sql
SET SQL_SAFE_UPDATES = 0;   -- off: allows non-key WHERE
SET SQL_SAFE_UPDATES = 1;   -- on: the default guard. Leave it on.

START TRANSACTION;  ...  ROLLBACK;   -- the real undo button (DML only)

START TRANSACTION;
UPDATE employees SET salary = salary + 2000 WHERE employee_id = 101;
SAVEPOINT chk;                        -- named checkpoint, mid-transaction
UPDATE employees SET salary = salary + 1000 WHERE employee_id = 102;
ROLLBACK TO SAVEPOINT chk;            -- undoes ONLY what happened after chk (the 102 update)
COMMIT;                               -- transaction is still open — this finalizes what's left (the 101 update)
```

`SAVEPOINT` always needs a name — there's no bare form. `ROLLBACK TO SAVEPOINT` doesn't end the transaction; you still need a final `COMMIT` or full `ROLLBACK`.

**ACID** — **A**tomicity (all or nothing), **C**onsistency (valid state → valid state), **I**solation (no peeking at unfinished work), **D**urability (committed = survives a crash). A money transfer is two `UPDATE`s in one transaction for exactly this reason.

```sql
LOCK TABLES employees WRITE;   -- only this session can touch employees
UNLOCK TABLES;                 -- always release
```

**`TRUNCATE TABLE t`** empties a table instantly and resets `AUTO_INCREMENT` — but it's DDL: no `WHERE`, no `ROLLBACK`. `DELETE FROM t` is slower but can be filtered and undone.

## Changing structure

```sql
SHOW CREATE TABLE employees;                       -- real constraint names
ALTER TABLE employees ADD COLUMN tmp_dep_id INT;
ALTER TABLE employees MODIFY COLUMN tmp_dep_id INT NULL;
ALTER TABLE employees DROP COLUMN tmp_dep_id;

ALTER TABLE employees DROP FOREIGN KEY employees_ibfk_2;
ALTER TABLE employees
ADD CONSTRAINT fk_employees_department
FOREIGN KEY (department_id) REFERENCES departments(department_id);
```

DDL **auto-commits** — `ROLLBACK` cannot undo an `ALTER`.

```sql
CREATE TABLE enrollments (
    student_id INT,
    course_id  INT,
    PRIMARY KEY (student_id, course_id)   -- composite key: the PAIR must be unique
);
```

## Users, privileges, and views

```sql
CREATE USER 'junior'@'localhost' IDENTIFIED BY '...';   -- starts with ZERO privileges
GRANT SELECT ON office.* TO 'junior'@'localhost';        -- add a privilege
REVOKE UPDATE ON office.* FROM 'junior'@'localhost';     -- remove one (no-op if never granted)
FLUSH PRIVILEGES;                                        -- reload grant tables (rarely required)

CREATE VIEW employee_details AS
SELECT e.first_name, j.job_title, r.region_name
FROM employees e
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN regions r ON ...;
-- query it like a table: SELECT * FROM employee_details;
```

A view stores no data — it re-runs its `SELECT` on every query. A multi-table view is generally read-only; only simple single-table views support `INSERT`/`UPDATE`.

## Indexes & internals

```sql
CREATE INDEX idx_phone ON employees(phone_number);
SHOW VARIABLES LIKE 'log_bin';
SHOW BINARY LOGS;
SHOW BINLOG EVENTS IN 'binlog.000055';
```

```sql
EXPLAIN SELECT * FROM employees WHERE employee_id = 116;   -- type = const → index lookup
EXPLAIN SELECT * FROM employees WHERE email = '...';       -- type = ALL   → full table scan
```

An index lets a lookup jump straight to the right B-tree page instead of scanning every row — but every write (`INSERT`/`UPDATE`/`DELETE`) now also maintains it, so add one for columns you actually filter/join/sort on, not everything. InnoDB (transactions, FKs, row locks) is the default engine over MyISAM (none of that). The **binlog** records every data-changing statement in order — it powers replication and point-in-time recovery.

## Window functions

```sql
SELECT department_id, SUM(salary) FROM employees GROUP BY department_id;   -- collapses to one row per group

SELECT employee_id, department_id, SUM(salary) OVER() AS company_total
FROM employees;                                                             -- keeps every row
```

`GROUP BY` collapses rows into groups. A window function (`OVER()`) computes the same kind of aggregate but keeps every row, attaching the aggregate as an extra column. `OVER()` with empty parens = the whole result set is the window; `OVER (PARTITION BY department_id)` scopes it per group while still keeping every row.

```sql
SUM(salary)  OVER (PARTITION BY department_id)                     -- per-department total on every row
RANK()       OVER (ORDER BY salary DESC)                           -- 1, 2, 2, 4  (gap after a tie)
DENSE_RANK() OVER (ORDER BY salary DESC)                           -- 1, 2, 2, 3  (no gap)
RANK()       OVER (PARTITION BY department_id ORDER BY salary DESC) -- restarts at 1 per department
LEAD(salary) OVER (ORDER BY salary DESC)                           -- next row's value (LAG = previous)
NTILE(4)     OVER (ORDER BY salary DESC)                           -- 4 equal-size buckets
```

You **can't** use a window column in `WHERE` — compute it in a derived table and filter outside:

```sql
SELECT * FROM (
    SELECT first_name, department_id,
           RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
    FROM employees
) dt
WHERE dept_rank = 1;    -- top earner(s) per department
```

## Stored procedures, functions, cursors

```sql
DELIMITER $$
CREATE PROCEDURE count_empl(IN p_dept INT, OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count FROM employees WHERE department_id = p_dept;
END $$
DELIMITER ;

CALL count_empl(10, @x);   SELECT @x;      -- OUT value lands in a session variable

DELIMITER $$
CREATE FUNCTION add_numbers(a INT, b INT) RETURNS INT DETERMINISTIC
BEGIN
    RETURN a + b;
END $$
DELIMITER ;

SELECT add_numbers(2, 4);                  -- functions go INSIDE queries
```

- `@var` lives for the session; `DECLARE var` lives inside one `BEGIN ... END`.
- Every procedure parameter is required — no defaults.
- Error 1418 on `CREATE FUNCTION` → add `DETERMINISTIC` (or `READS SQL DATA`), rather than `SET GLOBAL log_bin_trust_function_creators = 1`.
- **Cursor** = row-by-row loop inside a procedure: `DECLARE` → `OPEN` → `FETCH` in a `LOOP` → `CLOSE`, with `DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1` to end the loop. Slow — use set-based SQL whenever it can do the job.

---

## Useful functions

| Function | Does |
|---|---|
| `CONCAT(a, ' ', b)` | Glue strings — **returns NULL if any part is NULL** |
| `CONCAT_WS(' ', a, b)` | Same, with a separator, skips NULLs |
| `CURDATE()` | Today's date |
| `YEAR(d)`, `MONTH(d)` | Extract date parts |
| `DATE('1987-06-17')` | Cast a string to a date |
| `COUNT(DISTINCT col)` | How many different values |
| `LENGTH(s)` | String length in **bytes** |
| `CHAR_LENGTH(s)` | String length in **characters** — prefer this once data isn't guaranteed ASCII |
| `FIELD(val, a, b, c)` | 1-based position of `val` in the list; `0` if not found — great for a custom `ORDER BY` |
| `FORMAT(num, decimals)` | Thousands separators + fixed decimals — returns **text**, format last |
| `SUBSTRING(s, start, len)` | Part of a string — positions start at **1** |
| `LEFT(s, n)`, `RIGHT(s, n)` | First / last `n` characters |
| `STR_TO_DATE('25-12-2026', '%d-%m-%Y')` | Text → date; the format describes the **input** |
| `COALESCE(a, b, c)` | First non-NULL argument (standard SQL) |
| `IFNULL(a, b)` | `b` if `a` is NULL (MySQL-only, two args) |
| `a % b` | Remainder — `x % 2 = 0` means even |

---

## Mistakes we actually made, and the fixes

| Mistake | What happened | Fix |
|---|---|---|
| `BETWEEN '1999-01-01' AND '1997-01-01'` | Zero rows, no error | Low bound first |
| `SET SQL_SAFE_UPDATES = 1` before an update | Guard still on, update blocked | Set to `0`, run, set back to `1` |
| Disabling `ONLY_FULL_GROUP_BY` | Error gone, arbitrary values returned | Write a real `GROUP BY` |
| `COUNT(*)` over a LEFT JOIN | Empty groups counted as 1 | `COUNT(joined_table.id)` |
| `= (subquery returning 2 rows)` | "Subquery returns more than 1 row" | Use `IN` |
| `"David"` (double quotes) | Works in MySQL only | Use `'David'` |
| `savepoint;` with no name | Syntax error | `SAVEPOINT <name>;` — always needs one |
| `ROLLBACK TO SAVEPOINT` alone | Transaction stays open | Still needs a final `COMMIT` (or full `ROLLBACK`) |
| Trusting a self-join alias name | `AS employee` / `AS manager` swapped vs. the real roles | Read the `ON` condition, not the alias, to see who's who |
| `ONLY_FULL_GROUP_BY` disabled earlier in a session | Stays off for every later query in that session | Watch for ungrouped, non-aggregated columns creeping back in |
| `WHERE ranks = 1` on a window-function alias | "Unknown column 'ranks'" | Wrap in a derived table, filter outside |
| `LEAD(...)` aliased `lag_salary` | Works, but the name lies | LEAD = next row, LAG = previous |
| `salary > ANY (12000, 9000, 6800)` | Syntax error | `ANY`/`ALL` need a subquery |
| `hire_date > '2018-01-01' AND hire_date < '2018-12-31'` | Misses Jan 1 and Dec 31 | `>= '2018-01-01' AND < '2019-01-01'` |
| `LIMIT 5 OFFSET 15` with no `ORDER BY` | "Page 4" is whatever order MySQL feels like | Always `ORDER BY` before paging |
| `CREATE FUNCTION` without `DETERMINISTIC` | Error 1418 (binary logging is on) | Declare `DETERMINISTIC` |
| `GROUP BY deparmtnet_id, region_id` | Typo, and `region_id` isn't on `employees` | Join through to `regions` (file 08) |

---

## Habits worth keeping

1. `DESCRIBE` the table before writing the query.
2. `SELECT` your `WHERE` clause before you `UPDATE` or `DELETE` with it.
3. Build long joins one line at a time, running as you go.
4. Alias your tables (`employees e`) and qualify your columns (`e.salary`).
5. Empty result ≠ no data. Suspect your condition first.
6. Single quotes for strings, `UPPERCASE` keywords, one clause per line.
