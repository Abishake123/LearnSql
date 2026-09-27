# SQL Practice Tasks — Beginner Level

**Database:** `office` (the HR schema — see [`00-schema/schema-notes.md`](../00-schema/schema-notes.md))

Write each answer yourself before checking any lesson file. Save your answers in a file of your own, e.g. `my_answers.sql`.

**Topics covered:**

- `SELECT`
- `WHERE`
- Relational operators (`=`, `>`, `<`, `>=`, `<=`, `<>`)
- `AND / OR`
- `IN`
- `BETWEEN`
- `LIKE`
- `ORDER BY`
- `LIMIT`
- `OFFSET`
- `COUNT()`
- `SUM()`
- `AVG()`
- `MIN()`
- `MAX()`

## Part 1 – Basic SELECT

1. Display all employees.

2. Display only the employee ID, first name and last name of all employees.

3. Display the first name, last name and salary of all employees.

4. Display all records from the departments table.

5. Display all records from the jobs table.

6. Display the employee ID, first name, last name and hire date of all employees.

7. Display the first name and salary of all employees.

8. Display the department ID of all employees.

## Part 2 – Relational Operators

9. Find employees whose salary is greater than 5000.

10. Find employees whose salary is less than 5000.

11. Find employees whose salary is greater than or equal to 10000.

12. Find employees whose salary is less than or equal to 6000.

13. Find employees whose salary is exactly 8000.

14. Find employees whose salary is not equal to 5000.

15. Find employees whose employee ID is greater than 110.

16. Find employees whose employee ID is less than 110.

## Part 3 – AND / OR

17. Find employees whose salary is greater than 5000 AND less than 10000.

18. Find employees who belong to department 10 AND have a salary greater than 5000.

19. Find employees who belong to department 10 OR department 20.

20. Find employees whose salary is greater than 10000 OR whose department ID is 30.

21. Find employees who belong to department 20 AND whose salary is between 5000 and 10000.

22. Find employees whose salary is greater than 7000 AND whose first name starts with 'A'.

23. Find employees who belong to department 10 OR 20 AND have a salary greater than 5000.
    > ⚠️ Careful: `AND` is evaluated before `OR`. Run it with and without parentheses and compare the row counts.

## Part 4 – IN

24. Find employees who belong to departments 10, 20 or 30.

25. Find employees whose salary is one of the following: `5000, 6000, 7000, 8000`

26. Find employees whose department ID is NOT 10, 20 or 30.

27. Find employees whose employee ID is one of: `101, 105, 110, 115`

28. Find employees whose salary is NOT one of: `5000, 7000, 9000`

## Part 5 – BETWEEN

29. Find employees whose salary is between 5000 and 10000.

30. Find employees whose salary is between 7000 and 15000.

31. Find employees whose employee ID is between 105 and 115.

32. Find employees whose salary is NOT between 5000 and 10000.

33. Find employees whose hire date is between two given dates.

34. Find employees whose salary is between 5000 and 8000 AND who belong to department 20.

## Part 6 – LIKE

35. Find employees whose first name starts with 'A'.

36. Find employees whose first name starts with 'S'.

37. Find employees whose first name ends with 'n'.

38. Find employees whose first name contains the letter 'a'.

39. Find employees whose last name contains 'son'.

40. Find employees whose first name has exactly 5 characters.

41. Find employees whose first name starts with 'A' and ends with 'n'.

42. Find employees whose last name starts with 'S'.

43. Find employees whose first name contains the letter 'e'.

## Part 7 – ORDER BY

44. Display all employees ordered by salary from lowest to highest.

45. Display all employees ordered by salary from highest to lowest.

46. Display all employees ordered alphabetically by first name.

47. Display all employees ordered alphabetically by last name.

48. Display employees ordered by employee ID in descending order.

49. Display employees ordered by department ID and then salary.

50. Display employees ordered by salary descending. If two employees have the same salary, sort them by first name.

## Part 8 – LIMIT

51. Display the 5 highest-paid employees.

52. Display the 5 lowest-paid employees.

53. Display the first 10 employees ordered by employee ID.

54. Display the first 5 employees alphabetically by first name.

55. Display the top 3 employees whose salary is greater than 8000.

56. Display the 5 highest-paid employees from department 20.

## Part 9 – OFFSET

57. Display employees 6 to 10 when ordered by employee ID.

58. Display employees 11 to 15 when ordered by employee ID.

59. Display the second page of employees if each page contains 5 employees.

60. Display employees 6 to 10 when sorted by salary from highest to lowest.

61. Display employees 11 to 15 when sorted alphabetically by first name.

## Part 10 – Aggregate Functions

62. Find the total number of employees.

63. Find the total salary paid to all employees.

64. Find the average salary of all employees.

65. Find the highest salary.

66. Find the lowest salary.

67. Find the number of employees whose salary is greater than 8000.

68. Find the total salary of employees whose salary is greater than 5000.

69. Find the average salary of employees belonging to department 20.

70. Find the highest salary among employees belonging to department 30.

71. Find the lowest salary among employees belonging to department 10.

## Part 11 – Combination Questions

72. Find the 5 highest-paid employees whose salary is greater than 5000.

73. Find the 3 lowest-paid employees whose salary is between 5000 and 10000.

74. Find employees whose first name starts with 'A' and salary is greater than 5000.

75. Find employees whose first name contains 'a' and who belong to department 10, 20 or 30.

76. Find the highest-paid employee whose first name starts with 'S'.

77. Find the average salary of employees whose salary is between 5000 and 12000.

78. Find the total salary of employees belonging to departments 10, 20 and 30.

79. Find the number of employees whose salary is greater than 5000 AND whose first name starts with 'A'.

80. Find the 5 highest-paid employees whose first name contains the letter 'a'.

81. Find employees whose salary is greater than 7000 OR whose department ID is 20, and sort the result by salary descending.

82. Find the 3 highest-paid employees from departments 10, 20 and 30.

83. Find the average salary of employees whose first name starts with 'A'.

84. Find the highest salary among employees whose last name contains 'son'.

85. Find the total salary of employees whose salary is between 5000 and 15000.

## Part 12 – Mini Challenge

86. Find the 5 highest-paid employees whose salary is between 5000 and 15000.

87. Find employees whose first name starts with 'A' OR 'S', and whose salary is greater than 5000.

88. Find the 3 lowest-paid employees from departments 10, 20 and 30.

89. Find the average salary of employees whose first name contains the letter 'a'.

90. Find the total salary of employees whose salary is greater than 8000.

91. Find the number of employees whose first name starts with 'A'.

92. Find the highest salary among employees from departments 10, 20 and 30.

93. Find the lowest salary among employees whose first name contains 'e'.

94. Display the second page of employees, where each page contains 5 employees, sorted by salary descending.

95. Find the 5 highest-paid employees whose first name starts with 'A' and who belong to department 20 or 30.

## Bonus – Think Before Writing the Query

For every question, first identify:

1. Which table do I need?
2. Which columns do I need?
3. Do I need WHERE?
4. Which operator should I use?
5. Do I need AND or OR?
6. Can I use IN or BETWEEN?
7. Do I need LIKE?
8. Do I need ORDER BY?
9. Do I need LIMIT or OFFSET?
10. Do I need an aggregate function?

**Important:**
Try solving the questions without looking at previous queries.
The goal is to understand WHEN to use each SQL concept,
not just memorize the syntax.
