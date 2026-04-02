USE defaultdb;

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Student', 'Professor') NOT NULL
);
CREATE TABLE Domains (
    domain_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_name VARCHAR(100) NOT NULL
);
CREATE TABLE  Studies (
    study_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_id INT,
    level ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
    FOREIGN KEY (domain_id) REFERENCES Domains(domain_id) ON DELETE CASCADE
);
CREATE TABLE  Questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    study_id INT,
    question_text TEXT NOT NULL,
    correct_answer VARCHAR(255) NOT NULL,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
    FOREIGN KEY (study_id) REFERENCES Studies(study_id) ON DELETE CASCADE
);