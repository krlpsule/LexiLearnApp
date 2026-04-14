# LexiLearnApp

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)

> A full-stack Learning Management System developed as a comprehensive database course project.

## 📖 About The Project

This repository houses a full-stack Learning Management System (LMS) engineered to facilitate seamless interactions between students and professors. The architecture combines a responsive **Flutter** mobile application for the frontend, a robust **Java** backend acting as the secure middleman, and a structured **MySQL** relational database to handle complex data storage and querying.

## ✨ Core Features (Current Sprint)

* **🔐 Authentication & Role Management:** Secure sign-up and login workflows with distinct access levels for Students and Professors.
* **👤 Profile Management:** Dedicated interfaces for users to seamlessly update their personal credentials.
* **🧭 Intuitive Navigation:** A streamlined left-hand drawer and dynamic dashboard header for efficient app traversal.
* **📚 Course & Content Creation (Professors):** Advanced tools for educators to establish new study domains, categorize difficulty levels, and author interactive questions.
* **📈 Student Dashboard:** A personalized hub for students to track ongoing progress and discover new academic modules.

## 🗄️ Database Architecture

The system's backbone is a 6-table relational database designed for optimal data integrity:

| Table | Primary Key | Description | Foreign Key Relationships |
| :--- | :--- | :--- | :--- |
| **Users** | `user_id` | Core account data for all roles | None |
| **Domains** | `domain_id` | Academic disciplines | `created_by` references Users |
| **Studies** | `study_id` | Specific study modules | `domain_id` references Domains |
| **Questions** | `question_id` | Assessment material | `study_id` references Studies |
| **User_Progress** | `progress_id` | Tracks student completion rates | References Users & Studies |
| **User_Answers** | `answer_id` | Tracks completed questions | References Users & Questions |

## 📊 Sprint Details

* **Total Sprint Estimate:** 39 Story Points
* **Initial Velocity:** 0.7
* **Team Capacity:** 49 Points

## 🚀 Installation & Setup

### 1. Database Initialization (MySQL)
1. Launch your local MySQL server (e.g., MySQL Workbench).
2. Execute the schema generation script located at `database_scripts/01_create_tables.sql`.
3. Populate the initial test environment by running `database_scripts/02_insert_mock_data.sql`.

### 2. Backend API (Java)
1. Open the `backend` directory in your preferred IDE.
2. Ensure the `mysql-connector-j` dependency is included in your project build path.
3. Update `DatabaseManager.java` with your local MySQL credentials.
4. Run the main application to start the local server.

### 3. Mobile Client (Flutter)
1. Navigate to the `frontend_app` directory via terminal.
2. Run `flutter pub get` to fetch required packages.
3. **Important:** If testing on an Android Emulator, ensure the backend API URL in your Dart files is set to `http://10.0.2.2:8080`.
4. Launch the app using `flutter run`.
