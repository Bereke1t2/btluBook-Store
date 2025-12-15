#btluBook-Store

# 📚 Book Store App

A modern **bookstore application** built with **Flutter** and **Go (Gin)**.  
This app allows users to **upload, download, and share books**, and interact with an **AI assistant (GMNI)** to discuss books, generate summaries, reviews, and quizzes.  
Book files are stored securely using **Supabase**, and all user and book data is managed with **PostgreSQL**.

---

## ✨ Features

- 📤 **Upload books**  
  Users can upload PDFs or eBooks to share with others.

- 📥 **Download books**  
  Browse and download books uploaded by the community.

- 🤖 **AI Book Assistant (GMNI)**  
  Ask questions about any book and get:
  - Explanations
  - Summaries
  - Reviews

- 📝 **AI Quiz Generator**  
  Automatically generate quizzes from books:
  - Multiple-choice
  - Short answer
  - True / False

- 📱 **Cross-platform mobile app**  
  Built with Flutter for Android, iOS, Linux, macOS, web, and Windows.

- ⚙️ **Scalable backend (Go + Gin)**  
  Handles authentication, file uploads, AI integration, and API requests.

- ☁️ **Cloud storage with Supabase**  
  Books are uploaded and served via Supabase storage.

- 🗄️ **Database (PostgreSQL)**  
  Stores users, books, chats, and AI-generated content.

---

## 🛠 Tech Stack

### Frontend
- Flutter
- Dart
- REST / WebSocket communication

### Backend
- Go (Gin framework)
- GMNI AI integration
- JWT Authentication

### Database & Storage
- PostgreSQL
- Supabase Storage

---

## 📂 Project Structure

.
├── backend
│ └── bookstore
│ ├── cmd
│ ├── go.mod
│ ├── go.sum
│ ├── internal
│ └── pkg
├── ethio_book_store
└── mobile
├── analysis_options.yaml
├── android
│ ├── app
│ ├── build.gradle.kts
│ ├── gradle
│ ├── gradle.properties
│ ├── gradlew
│ ├── local.properties
│ └── settings.gradle.kts
├── ios
│ ├── Flutter
│ ├── Runner
│ ├── RunnerTests
│ ├── Runner.xcodeproj
│ └── Runner.xcworkspace
├── lib
│ ├── app
│ ├── core
│ ├── features
│ ├── injections.dart
│ └── main.dart
├── linux
│ ├── CMakeLists.txt
│ ├── flutter
│ └── runner
├── macos
│ ├── Flutter
│ ├── Runner
│ ├── RunnerTests
│ ├── Runner.xcodeproj
│ └── Runner.xcworkspace
├── pubspec.yaml
├── README.md
├── test
│ └── widget_test.dart
├── web
│ ├── favicon.png
│ ├── icons
│ ├── index.html
│ └── manifest.json
└── windows
├── CMakeLists.txt
├── flutter
└── runner




## 🚀 Getting Started

### 1️⃣ Clone the repository

```bash
git clone https://github.com/Bereke1t2/btluBook-Store.git
cd btluBook-Store
2️⃣ Run the Backend (Go + Gin)
bash
Copy code
cd backend/bookstore
go mod tidy
go run main.go
The backend will start on:

arduino
Copy code
http://localhost:8080
3️⃣ Run the Flutter App
bash

cd ../../mobile
flutter pub get
flutter run
Make sure you have a connected emulator or device.

🔑 Environment Variables
Create a .env file in the backend folder and add:

env
Copy code
GMNI_API_KEY=your_gmni_api_key_here
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
DB_URL=postgres://username:password@host:port/dbname
JWT_SECRET=your_jwt_secret
🤝 Contributing
Contributions are welcome!

Fork the repository

Create a new branch (git checkout -b feature-name)

Commit your changes (git commit -m "Add feature")

Push to your branch (git push origin feature-name)

Open a Pull Request

📌 Future Improvements
User profiles and authentication

Book categories & search

Favorites & bookmarks

Offline reading support

Admin dashboard

Personalized book recommendations

📄 License
This project is licensed under the MIT License.

👨‍💻 Author
Bereket
Built with ❤️ using Flutter, Go (Gin), Supabase, PostgreSQL, and GMNI AI.

If you like this project, feel free to ⭐ the repository!
