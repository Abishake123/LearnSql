# LearnSql

**SQL class — session notes & queries.**

Every query we wrote in class, cleaned up, grouped by topic, and commented.
Read the files in numbered order — each one builds on the one before it.

```bash
git clone git@github.com:Abishake123/LearnSql.git
```

We use two databases:

- **`office`** — the classic HR schema (employees, departments, jobs, locations, countries, regions, dependents). This is where almost everything happens.
- **`shop`** — a tiny two-table database (`personas`, `orders`) used only to introduce joins.

---

## Contents

| Folder | File | What you learn |
|---|---|---|
| `00-schema` | [`schema-notes.md`](00-schema/schema-notes.md) | The ER diagram, tables, keys, how they connect |
| `01-basics` | [`01_select_basics.sql`](01-basics/01_select_basics.sql) | `SELECT`, `COUNT`, `DESCRIBE`, database qualifying |
| `02-filtering` | [`02_where_filtering.sql`](02-filtering/02_where_filtering.sql) | `WHERE`, `=`, `!=`, `BETWEEN`, dates, `IN` |
| `02-filtering` | [`03_like_patterns.sql`](02-filtering/03_like_patterns.sql) | `LIKE`, `%` vs `_` |
| `03-sorting` | [`04_order_limit_distinct.sql`](03-sorting/04_order_limit_distinct.sql) | `ORDER BY`, `LIMIT`, `DISTINCT` |
| `04-modifying` | [`05_update_rows.sql`](04-modifying/05_update_rows.sql) | `UPDATE`, safe-update mode |
| `05-joins` | [`06_joins_intro.sql`](05-joins/06_joins_intro.sql) | First joins, on the `shop` database |
| `05-joins` | [`07_join_types.sql`](05-joins/07_join_types.sql) | `INNER` / `LEFT` / `RIGHT` / `FULL OUTER` |
| `05-joins` | [`08_multi_table_joins.sql`](05-joins/08_multi_table_joins.sql) | Chaining 5 tables: employee → region |
| `06-aggregates` | [`09_aggregates_group_by.sql`](06-aggregates/09_aggregates_group_by.sql) | `COUNT`, `GROUP BY`, `ONLY_FULL_GROUP_BY` |
| `06-aggregates` | [`10_subqueries.sql`](06-aggregates/10_subqueries.sql) | Subqueries in `WHERE` |
| `07-ddl` | [`11_alter_table.sql`](07-ddl/11_alter_table.sql) | `ALTER TABLE`, adding columns, fixing foreign keys |
| `06-aggregates` | [`12_aggregates_with_joins.sql`](06-aggregates/12_aggregates_with_joins.sql) | `LENGTH`/`CHAR_LENGTH`, aggregates over a JOIN, functional dependency |
| `06-aggregates` | [`13_having_without_groupby.sql`](06-aggregates/13_having_without_groupby.sql) | `HAVING` with no `GROUP BY`, `HAVING` on a SELECT alias |
| `08-functions` | [`14_field_and_format.sql`](08-functions/14_field_and_format.sql) | `FIELD()`, `FORMAT()` |
| `09-case-expressions` | [`15_case_expressions.sql`](09-case-expressions/15_case_expressions.sql) | `CASE WHEN ... THEN ... END`, bucketing values |
| `10-derived-temp-cte` | [`16_derived_temp_tables_and_ctes.sql`](10-derived-temp-cte/16_derived_temp_tables_and_ctes.sql) | Derived tables, `TEMPORARY TABLE`, `WITH` (CTEs), chained CTEs |
| `11-transactions` | [`17_savepoints.sql`](11-transactions/17_savepoints.sql) | `SAVEPOINT`, `ROLLBACK TO SAVEPOINT` |
| `12-admin` | [`18_users_and_views.sql`](12-admin/18_users_and_views.sql) | `CREATE USER`, `GRANT`/`REVOKE`, `CREATE VIEW` |
| `13-performance` | [`19_indexes_and_binlog.sql`](13-performance/19_indexes_and_binlog.sql) | `CREATE INDEX`, InnoDB vs MyISAM, the binary log |
| `05-joins` | [`20_cross_join_and_self_join_variant.sql`](05-joins/20_cross_join_and_self_join_variant.sql) | `CROSS JOIN`, reading a self-join's `ON` clause correctly |
| `14-window-functions` | [`21_window_functions_intro.sql`](14-window-functions/21_window_functions_intro.sql) | `OVER()` — aggregates that don't collapse rows |
| `10-derived-temp-cte` | [`22_recursive_cte_hierarchy.sql`](10-derived-temp-cte/22_recursive_cte_hierarchy.sql) | `WITH RECURSIVE` — walking a manager → reportee chain |
| — | [`cheatsheet.md`](cheatsheet.md) | One-page recap of everything |

---

## How to run these

Open MySQL Workbench (or any MySQL client), connect to your local server, then:

```sql
USE office;
```

Open a `.sql` file, highlight one statement, and run it. **Run one statement at a time** — these files are lesson notes, not a script to execute top to bottom (some statements intentionally return nothing so you can see *why*).

## Conventions used in these files

- Keywords in `UPPERCASE`, table/column names in `lower_snake_case`.
- String literals in **single quotes** — `'David'`, not `"David"`. MySQL accepts double quotes, but single quotes are the SQL standard and work everywhere.
- Table aliases (`employees e`) once more than one table is involved.
- Comments starting with `-- ⚠️` mark a mistake we made in class on purpose, and the fix.
