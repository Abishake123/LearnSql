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

**One question decides it:** do you want rows that have no match? No → `INNER`. Yes → `LEFT`.

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

## Subqueries

```sql
WHERE region_id = (SELECT region_id FROM regions WHERE region_name = 'Africa')   -- one value
WHERE region_id IN (SELECT region_id FROM regions WHERE region_name LIKE '%America%')  -- many
WHERE salary > (SELECT AVG(salary) FROM employees)                              -- aggregate
WHERE EXISTS (SELECT 1 FROM dependents d WHERE d.employee_id = e.employee_id)   -- any match?
FROM (SELECT ... ) AS t                                                          -- derived table
```

`=` needs exactly one row back. `IN` accepts many. When in doubt, `IN`.

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
```

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

---

## Habits worth keeping

1. `DESCRIBE` the table before writing the query.
2. `SELECT` your `WHERE` clause before you `UPDATE` or `DELETE` with it.
3. Build long joins one line at a time, running as you go.
4. Alias your tables (`employees e`) and qualify your columns (`e.salary`).
5. Empty result ≠ no data. Suspect your condition first.
6. Single quotes for strings, `UPPERCASE` keywords, one clause per line.
