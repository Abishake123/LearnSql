# SQL Practice Tasks — Joins, GROUP BY & HAVING

**Database:** `office` (the HR schema — see [`00-schema/schema-notes.md`](../00-schema/schema-notes.md))

Write each answer yourself before checking any lesson file. Save your answers in a file of your own, e.g. `my_answers_03.sql`.

Lessons to revise first: joins (`05-joins`, files 06–08 and 20) and aggregates (`06-aggregates`, files 09, 12 and 13).

**Topics covered:**

- `INNER JOIN`
- `LEFT JOIN` / `RIGHT JOIN`
- Multi-table joins (3–5 tables)
- Self join
- `WHERE` on a joined result
- `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
- `GROUP BY`
- `HAVING`
- `WHERE` + `GROUP BY` + `HAVING` together
- `ORDER BY` / `LIMIT` on grouped results

> **Tip:** questions name departments, jobs, cities and regions by **name**, not ID.
> Run `SELECT * FROM departments;` (and the same for `jobs`, `locations`, `countries`, `regions`) once before you start, so you know what's there.

## Part 1 – INNER JOIN (two tables)

1. Display each employee's first name, last name and department name.

2. Display each employee's first name and job title.

3. Display each department's name and the city it is located in.

4. Display each country's name and its region name.

5. Display each location's city and the name of its country.

6. Display each dependent's first name, relationship, and the first name of the employee they belong to.

7. Display each employee's first name, salary, job title, and the minimum and maximum salary for that job.

8. Display the employee ID, first name and department name of every employee, sorted by department name.

## Part 2 – LEFT JOIN / RIGHT JOIN

9. Display every department and the first names of its employees — include departments that have no employees.

10. Display all departments that have **no** employees at all.

11. Display every employee and the first names of their dependents — include employees who have no dependents.

12. Display all employees who have **no** dependents.

13. Display every country and the cities of its locations — include countries with no locations.

14. Display all countries that have **no** locations.

15. Display every job title and the first names of employees holding it — include jobs nobody holds.

16. Rewrite question 9 using a `RIGHT JOIN` instead of a `LEFT JOIN`, and get the same result.

## Part 3 – Multi-Table Joins

17. Display each employee's first name, department name and city.

18. Display each employee's first name, department name, city and country name.

19. Display each employee's first name and the region they work in.
    *(Hint: employees → departments → locations → countries → regions)*

20. Display each employee's first name, job title, department name and city.

21. Display each department's name, city, country name and region name.

22. Display each dependent's first name, the employee they belong to, and that employee's department name.

## Part 4 – Self Join

23. Display each employee's first name and their manager's first name.

24. Display every employee and their manager's first name — include the employee who has no manager.

25. Find the employee(s) who have no manager.

26. Display the first names of all employees who report to Steven King.

27. Display each employee's first name and salary next to their manager's first name and salary.

28. Find employees who earn **more** than their manager.

29. Find employees who were hired **before** their manager.

## Part 5 – JOIN + WHERE

30. Display the first names of all employees in the IT department.

31. Display the first names and salaries of employees who work in Seattle.

32. Display all employees whose job title is 'Programmer'.

33. Display all employees who work in the 'Americas' region.

34. Display employees in the Sales department who earn more than 10000.

35. Display employees in the IT or Finance departments, sorted by salary from highest to lowest.

36. Display employees whose job title contains the word 'Clerk'.

37. Display employees who work in the United Kingdom.

38. Display employees who work in Europe and were hired after 1997-01-01.

39. Display all dependents whose relationship is 'Child', along with the first name of the employee they belong to.

40. Display the 5 highest-paid employees who work in the 'Americas' region.

## Part 6 – Aggregate Functions (recap, with WHERE)

41. Find the total number of employees.

42. Find the total, average, highest and lowest salary — all in one query.

43. Find the number of employees who earn more than 10000.

44. Find the average salary of employees hired after 1997-01-01.

45. Find the number of distinct job IDs used in the employees table.

46. Find the number of employees who have a phone number. *(Compare `COUNT(*)` and `COUNT(phone_number)`.)*

47. Find the number of employees who have a manager.

48. Find the most recent and the earliest hire date.

## Part 7 – GROUP BY (single table)

49. Find the number of employees in each department ID.

50. Find the total salary paid in each department ID.

51. Find the average salary for each job ID.

52. Find the highest and lowest salary in each department ID.

53. Find the number of employees reporting to each manager ID.

54. Find the number of employees hired in each year. *(Hint: `YEAR(hire_date)`)*

55. Find the number of countries in each region ID.

56. Find the number of dependents each employee ID has.

## Part 8 – GROUP BY + JOIN

57. Find the number of employees in each department — show the department **name**.

58. Find the average salary of each department, by department name.

59. Find the number of employees holding each job title.

60. Find the total salary paid in each city.

61. Find the number of employees in each country.

62. Find the number of employees in each region.

63. Find the number of locations in each country, by country name.

64. Find the number of dependents each employee has, showing the employee's first name.

65. Find the number of employees in **every** department, including departments with 0 employees.
    *(⚠️ Watch out: `COUNT(*)` vs `COUNT(e.employee_id)` after a `LEFT JOIN` — see lesson 09.)*

66. Find the number of direct reports each manager has, showing the manager's first name.

## Part 9 – HAVING

67. Find the department IDs that have more than 5 employees.

68. Find the departments (by name) that have more than 5 employees.

69. Find the job titles held by more than 3 employees.

70. Find the departments whose average salary is greater than 8000.

71. Find the departments whose total salary is greater than 50000.

72. Find the managers (by first name) who have more than 4 direct reports.

73. Find the departments where the lowest salary is greater than 5000.

74. Find the countries that have exactly one location.

75. Find the employees (by first name) who have 2 or more dependents.

76. Find the years in which more than 5 employees were hired.

## Part 10 – WHERE + GROUP BY + HAVING Together

77. Considering only employees who earn more than 5000, find the departments that have more than 3 such employees.

78. Considering only employees hired after 1995-01-01, find the departments whose average salary is greater than 7000.

79. Considering only employees in the 'Americas' region, find the departments with more than 2 employees.

80. Considering only job titles that contain 'Clerk', find the job titles held by more than 2 employees.

81. Considering only employees who have a manager, find the managers whose team's average salary is greater than 8000.

82. Find the departments, excluding the Executive department, whose highest salary is greater than 10000.

83. For each city, count the employees earning more than 6000 — show only cities with at least 2 such employees.

84. For each region, find the average salary of employees hired before 1998-01-01 — show only regions where that average is greater than 6000.

## Part 11 – Combination Questions (with ORDER BY / LIMIT)

85. Display the department names and headcount of every department, sorted from largest to smallest.

86. Find the 3 departments with the highest average salary.

87. Find the job title with the most employees.

88. Find the region with the highest total salary.

89. Find the city with the fewest employees (ignore cities with no employees).

90. Find the 5 managers with the most direct reports.

91. For each department, show the department name, number of employees, and average salary rounded to 2 decimal places — only departments with more than 2 employees, sorted by average salary descending.

92. For each country, show the country name, the number of employees, and the highest salary — sorted by country name.

## Part 12 – Mini Challenge

93. Find each department's name, its number of employees, and the total salary of those employees — only for departments in the 'Americas' region whose total salary is greater than 20000.

94. Find the job titles where the average salary of employees is higher than 10000, sorted from highest to lowest average.

95. Find the managers (by first name) whose direct reports earn a combined salary of more than 30000.

96. Find, for each region, the number of departments located there.

97. Find the departments that have employees in more than 2 different job titles. *(Hint: `COUNT(DISTINCT ...)`)*

98. Find employees who have more than 1 dependent, and display their first name, department name and number of dependents.

99. Find the number of employees per department **and** job title, showing both names — only combinations with more than 1 employee.

100. Find the department(s) in Seattle with the highest average salary — show the department name and the average.

## Bonus – Think Before Writing the Query

For every question, first identify:

1. Which tables do I need?
2. How are those tables connected? (Which column links each pair?)
3. Do I need rows that have **no** match? → `LEFT JOIN`
4. Which rows should I filter **before** grouping? → `WHERE`
5. What should each output row represent? → `GROUP BY`
6. Which aggregate do I need? → `COUNT` / `SUM` / `AVG` / `MIN` / `MAX`
7. Which groups should I filter **after** grouping? → `HAVING`
8. Do I need `ORDER BY` or `LIMIT`?

Remember the clause order:

```sql
SELECT    ...
FROM      ...
JOIN      ... ON ...
WHERE     ...      -- filters ROWS
GROUP BY  ...
HAVING    ...      -- filters GROUPS
ORDER BY  ...
LIMIT     ...;
```

**Important:**
`WHERE` cannot use an aggregate — `WHERE COUNT(*) > 5` is an error. If the condition uses `COUNT`, `SUM`, `AVG`, `MIN` or `MAX`, it belongs in `HAVING`.
