-- =============================================================
-- 06 — First joins, on the small `shop` database
-- Database: shop
-- =============================================================
-- Data is split across tables so nothing is stored twice. Customer details
-- live in `personas`; orders live in `orders`, holding only a person_id
-- pointing back. A JOIN is how you put them back together in one result.
-- =============================================================

USE shop;

SHOW TABLES;


-- -------------------------------------------------------------
-- 1. Look at each table on its own FIRST
-- -------------------------------------------------------------
-- Never write a join before you have seen both sides.
-- personas: person_id, name, age
SELECT * FROM personas;

-- orders: order_id, order_number, person_id
SELECT * FROM orders;

-- Notice: `orders` has no name in it. Just a person_id.
-- That number is the link. That is what we join on.


-- -------------------------------------------------------------
-- 2. Your first JOIN
-- -------------------------------------------------------------
--   JOIN <other table> ON <how the two tables match>
--
-- The ON clause is the rule: "this row in orders belongs with that row
-- in personas when their person_id values are equal."
SELECT *
FROM orders o
JOIN personas p ON o.person_id = p.person_id;

-- `o` and `p` are ALIASES — short nicknames for the tables. They save
-- typing and make it obvious which table each column came from.


-- -------------------------------------------------------------
-- 3. Selecting specific columns from a join
-- -------------------------------------------------------------
-- Written without aliases (works, but verbose):
SELECT order_number, name
FROM orders
JOIN personas ON orders.person_id = personas.person_id;

-- Same thing with aliases — this is the style to use:
SELECT o.order_number, p.name
FROM orders o
JOIN personas p ON o.person_id = p.person_id;

-- ⚠️ If a column name exists in BOTH tables, you MUST qualify it or MySQL
--    errors with "Column 'person_id' in field list is ambiguous".
--    Aliases make this painless.


-- -------------------------------------------------------------
-- 4. WHERE still works, on either table
-- -------------------------------------------------------------
-- Filter on a column from the joined table:
SELECT o.order_number, p.name, p.age
FROM orders o
JOIN personas p ON o.person_id = p.person_id
WHERE p.name LIKE 'J%';

-- You don't need a join at all if every column you want is in one table:
SELECT ps.name, ps.age
FROM personas ps
WHERE ps.name LIKE 'J%';

-- Rule of thumb: only join a table if you need a column FROM it,
-- or need to filter BY it.


-- -------------------------------------------------------------
-- 5. Order of clauses in a join query
-- -------------------------------------------------------------
--   SELECT   which columns to show
--   FROM     the first table
--   JOIN     the second table
--   ON       how they match          ← belongs to the JOIN
--   WHERE    which rows to keep      ← applied after the join
--   ORDER BY how to sort
--
-- ON and WHERE are different jobs. ON says how tables connect.
-- WHERE says which of the resulting rows survive.
SELECT o.order_number, p.name
FROM orders o
JOIN personas p ON o.person_id = p.person_id
WHERE p.age > 25
ORDER BY p.name;


-- =============================================================
-- TAKEAWAYS
--   • A join reconnects tables through a shared key column
--   • ON = the matching rule; WHERE = the row filter
--   • Always SELECT each table alone before joining them
--   • Use short aliases (o, p) and qualify your columns
-- =============================================================
