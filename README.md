# btluBook-Store  
### A Full-Stack Distributed AI-Powered Bookstore Ecosystem

btluBook-Store is a high-performance, cross-platform digital library platform designed for scalable book distribution and AI-driven content analysis. It combines a Go (Gin) backend with a Flutter frontend to deliver a seamless and efficient reading and learning experience.

---

## Overview

The platform transforms traditional digital reading into an interactive ecosystem by integrating cloud storage, relational data modeling, and generative AI.

It follows a microservice-inspired architecture focused on scalability, performance, and clean system design.

---

## Key Features

### Asynchronous Asset Management
- Optimized upload and download pipelines for PDF and eBook formats  
- Supabase Object Storage integration for high availability  

### AI-Driven Content Analysis
- Contextual explanations of book content  
- Automated summaries  
- Critical content insights using Google Gemini API  

### Automated Quiz Generation
- AI-generated multiple-choice questions  
- Short-answer and logic-based assessments  
- Enhances learning through interactive evaluation  

### Cross-Platform Application
- Single Flutter codebase supporting:
  - Android  
  - iOS  
  - Web  
  - Windows  
  - macOS  
  - Linux  

### Backend Architecture
- RESTful API built with Go (Gin)  
- JWT-based authentication  
- Middleware for validation and request handling  
- Designed for high concurrency and performance  

---

## Technology Stack

### Frontend
- Framework: Flutter (Dart)  
- State Management: Provider / BLoC (Clean Architecture)  
- Networking: REST APIs and WebSocket integration  

### Backend
- Language: Go (Golang)  
- Framework: Gin  
- Authentication: JWT  

### Data and Storage
- Database: PostgreSQL  
- Object Storage: Supabase Storage  
- ORM: GORM  

### AI Integration
- Google Gemini API  

---

## System Architecture

```
.
├── backend
│   └── bookstore
│       ├── cmd
│       ├── internal
│       └── pkg
├── mobile
│   ├── lib
│   │   ├── app
│   │   ├── core
│   │   ├── features
│   │   └── injections.dart
│   └── platform folders
```

---

## Installation and Setup

### Prerequisites

- Go (1.20 or higher)  
- Flutter SDK  
- PostgreSQL  
- Supabase account  

---

### Backend Setup

```bash
cd backend/bookstore
go mod tidy
go run main.go
```

The backend will start at:
```
http://localhost:8080
```

---

### Frontend Setup

```bash
cd mobile
flutter pub get
flutter run
```

---

## Environment Variables

Create a `.env` file inside the `/backend` directory and configure the following:

| Variable        | Description                          |
|----------------|--------------------------------------|
| GMNI_API_KEY   | Google Gemini API key                |
| SUPABASE_URL   | Supabase project URL                |
| SUPABASE_KEY   | Supabase service role key           |
| DB_URL         | PostgreSQL connection string        |
| JWT_SECRET     | Secret key for authentication       |

---

## Roadmap

- Advanced search using Elasticsearch  
- Social features (profiles, follows, reading lists)  
- Offline mode with local caching (SQLite/Hive)  
- Personalized recommendation system  
- Admin dashboard for analytics and moderation  

---

## Contribution

Contributions are welcome. Please follow the standard workflow:

```bash
git checkout -b feature/your-feature-name
git commit -m "Add your feature"
git push origin feature/your-feature-name
```

Then open a Pull Request.

---

## License

This project is licensed under the MIT License.

---

## Author

Bereket Aschalew  
Software Engineer  

- GitHub: https://github.com/Bereke1t2  
- LinkedIn: https://www.linkedin.com/in/bereket-aschalew  
