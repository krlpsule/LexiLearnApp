# LexiLearn Veritabanı Şeması

## Tablolar

### 1. courses (Kurslar)
| Kolon | Tip | Açıklama |
|-------|-----|----------|
| id | INTEGER (PK) | Benzersiz kurs ID |
| name | TEXT | Kurs adı |
| level | TEXT | Seviye (Beginner / Intermediate / Advanced) |
| created_at | DATETIME | Oluşturulma tarihi |

### 2. questions (Sorular)
| Kolon | Tip | Açıklama |
|-------|-----|----------|
| id | INTEGER (PK) | Benzersiz soru ID |
| course_id | INTEGER (FK) | Bağlı olduğu kurs (courses.id) |
| question_text | TEXT | Soru metni |
| created_at | DATETIME | Oluşturulma tarihi |

### 3. answers (Cevaplar)
| Kolon | Tip | Açıklama |
|-------|-----|----------|
| id | INTEGER (PK) | Benzersiz cevap ID |
| question_id | INTEGER (FK) | Bağlı olduğu soru (questions.id) |
| answer_text | TEXT | Cevap metni |
| is_correct | BOOLEAN | Doğru cevap mı? |

## İlişkiler
- Bir kursun birden fazla sorusu olabilir (courses → questions)
- Bir sorunun birden fazla cevabı olabilir (questions → answers)
- Her sorunun sadece bir doğru cevabı olabilir