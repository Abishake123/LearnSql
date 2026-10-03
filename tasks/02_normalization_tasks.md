# SQL Practice Tasks — Normalization

**Goal:** take one big table where the same facts are stored again and again, split it into
clean tables, link them with keys, and join them back together.

**Topics covered:**

- Spotting repeated (redundant) data
- `PRIMARY KEY` and `FOREIGN KEY`
- `CREATE TABLE`, `INSERT`
- `JOIN` across three tables
- `WHERE` on a joined result

Work in a database of your own so you don't touch `office`:

```sql
CREATE DATABASE practice;
USE practice;
```

---

## Task 2 – Library / Book Borrowing

A library stores borrowing information in one table:

**`Library_Borrowing`**

| borrow_id | student_name | class | book_id | book_name | author | borrow_date |
|---|---|---|---|---|---|---|
| 1 | Arjun | 8 | B101 | Harry Potter | J.K Rowling | 2026-09-01 |
| 2 | Priya | 8 | B102 | Wings of Fire | Abdul Kalam | 2026-09-02 |
| 3 | Rahul | 8 | B101 | Harry Potter | J.K Rowling | 2026-09-03 |
| 4 | Arjun | 8 | B103 | The Jungle Book | Rudyard Kipling | 2026-09-05 |
| 5 | Priya | 8 | B102 | Wings of Fire | Abdul Kalam | 2026-09-07 |

### Problem

Identify the information that is being repeated. For example:

- Harry Potter and its author are stored again when another student borrows the same book.
- Student information is also repeated every time the student borrows another book.

### Your task

Split this into 3 tables. Suggested design:

| Students | Books | Borrowings |
|---|---|---|
| `student_id` | `book_id` | `borrow_id` |
| `student_name` | `book_name` | `student_id` |
| `class` | `author` | `book_id` |
| | | `borrow_date` |

> The original table has no `student_id` — you'll need to give each student one.

### Questions

1. What should be the PRIMARY KEY of `Students`?
2. What should be the PRIMARY KEY of `Books`?
3. What should be the PRIMARY KEY of `Borrowings`?
4. Which columns should be FOREIGN KEYS?
5. Draw the relationship between the tables.
6. Write `CREATE TABLE` queries.
7. Insert the data into the new tables.
8. Write a query to display:

   | Student Name | Book Name | Author | Borrow Date |
   |---|---|---|---|

9. Write a query to find all books borrowed by Arjun.

---

## Task 3 – Hospital / Patient Appointments

A hospital initially stores everything in one table:

**`Hospital_Appointment`**

| appointment_id | patient_name | age | doctor_id | doctor_name | specialization | appointment_date |
|---|---|---|---|---|---|---|
| 1 | Arjun | 35 | D101 | Dr. Ravi | Cardiology | 2026-09-10 |
| 2 | Priya | 29 | D102 | Dr. Kumar | Dermatology | 2026-09-11 |
| 3 | Rahul | 41 | D101 | Dr. Ravi | Cardiology | 2026-09-12 |
| 4 | Arjun | 35 | D102 | Dr. Kumar | Dermatology | 2026-09-15 |
| 5 | Priya | 29 | D101 | Dr. Ravi | Cardiology | 2026-09-17 |

### Problem

Look at the data carefully. You can see:

- Arjun's information is repeated.
- Priya's information is repeated.
- Dr. Ravi's information is repeated.
- Dr. Kumar's information is repeated.
- Doctor specialization is repeated whenever the doctor has another appointment.

### Your task

Split this into 3 tables. Suggested design:

| Patients | Doctors | Appointments |
|---|---|---|
| `patient_id` | `doctor_id` | `appointment_id` |
| `patient_name` | `doctor_name` | `patient_id` |
| `age` | `specialization` | `doctor_id` |
| | | `appointment_date` |

> The original table has no `patient_id` — you'll need to give each patient one.

### Questions

1. What should be the PRIMARY KEY of `Patients`?
2. What should be the PRIMARY KEY of `Doctors`?
3. What should be the PRIMARY KEY of `Appointments`?
4. Which columns should be FOREIGN KEYS?
5. Draw the relationship between the tables.
6. Write `CREATE TABLE` queries.
7. Insert the data into the new tables.
8. Write a query to display:

   | Patient Name | Doctor Name | Specialization | Appointment Date |
   |---|---|---|---|

9. Write a query to find all appointments of Arjun.
10. Write a query to find all patients who visited Dr. Ravi.

---

## Think before you build

For every split, ask:

1. What is each table **about**? (one thing per table — a student, a book, a borrowing)
2. Which column **uniquely identifies** a row in it? → primary key
3. Which columns **point at another table's** primary key? → foreign keys
4. Which table must be created and filled **first**, so the foreign keys have something to point at?
