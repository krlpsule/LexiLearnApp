# LexiLearn Database Schema

## Tables

### 1. courses
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Unique course ID |
| name | TEXT | Course name |
| level | TEXT | Level (Beginner / Intermediate / Advanced) |
| created_at | DATETIME | Creation date |

### 2. questions
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Unique question ID |
| course_id | INTEGER (FK) | Related course (courses.id) |
| question_text | TEXT | Question text |
| created_at | DATETIME | Creation date |

### 3. answers
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Unique answer ID |
| question_id | INTEGER (FK) | Related question (questions.id) |
| answer_text | TEXT | Answer text |
| is_correct | BOOLEAN | Is correct answer? |

## Relationships
- A course can have multiple questions (courses → questions)
- A question can have multiple answers (questions → answers)
- Each question can have only one correct answer