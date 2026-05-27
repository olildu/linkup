<p align="center">
  <img src="https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/images/app_logo/app_logo_transparent.png" 
       alt="linkup Logo" 
       width="180">
</p>


# 🚀 linkup: The Frontend

A modern, real-time social networking application built with **Flutter** for a seamless, cross-platform mobile experience.


<p align="center">
  <a href="https://x.com/olildu">
    <img src="https://img.shields.io/twitter/follow/your_twitter_handle.svg?style=social&label=Follow" alt="Twitter">
  </a>
  &nbsp;&nbsp;
  <a href="https://www.linkedin.com/in/ebinsanthosh/">
    <img src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>


## 🌟 Project Highlights & Technical Differentiators

This project showcases clean architecture, real-time state management, high-performance UI, and an offline-first experience.

| Feature | Technical Implementation | Engineering Value Demonstrated |
| :--- | :--- | :--- |
| **Real-Time Messaging** | **Flutter BLoC** + **WebSockets** (`ChatsBloc`, `ChatSocketService`) | Asynchronous event handling, scalable architecture, clear separation of concerns |
| **Offline-First Caching** | **Isar Database** for persistent local storage (`message_table.dart`, `chats_table.dart`) | Smooth UX during network loss, fault-tolerant local-first data design |
| **Optimized Image Loading** | **BlurHash** placeholders + backend-powered compression | Fast scrolling performance, reduced bandwidth usage |
| **Modular Responsive UI** | Built using **ScreenUtil**, reusable UI components | Consistent UI across devices, maintainable frontend architecture |


## 🧱 Architecture Overview: BLoC Pattern

The project strictly follows the **BLoC Architecture**, ensuring scalability, testability, and maintainability.

### **App Entry (`main.dart`)**
- Initializes global blocs using `MultiBlocProvider`
- Sets up app-wide theme, routing, and initial user metadata loading  
- Core blocs loaded here:  
  - `PostLoginBloc`  
  - `ProfileBloc`  
  - `ConnectionsBloc`

### **BLoC Layer (Logic)**
- **ProfileBloc** — Fetches and updates user metadata.  
- **ChatsBloc** — Handles chat history, pagination, and real-time WebSocket message streams.  
- **ConnectionsBloc** — Maintains live list of matches, updates via socket events.

### **Data Layer (Services / Models)**
- **CustomHttpClient** — Wraps API calls to the FastAPI backend.
- **Isar Models** — Handle local DB caching for messages and chat sessions.

## ⚙️ Core Modules & Components

| Module | Purpose | Key Files |
| :--- | :--- | :--- |
| **Auth Flow** | Signup + OTP verification | `signup_page.dart`, `otp_bloc.dart` |
| **Matchmaking** | Swipable candidate cards and preference-based filtering | `around_you_page.dart`, `matches_bloc.dart` |
| **Chat System** | Real-time messaging, media uploads, delivery states | `chat_page.dart`, `chats_bloc.dart`, `message_renderer.dart` |
| **Form Widgets** | Custom date pickers, city auto-complete, multi-select widgets | `date_picker.dart`, `city_lookup.dart` |



## 🛠️ Development Setup

Requires **Flutter 3.x**.

### **Prerequisites**
- Flutter SDK installed  
- Working emulator or connected device  
- FastAPI backend running locally or remotely  

### **Installation**

```bash
git clone https://github.com/olildu/linkup-frontend.git
cd linkup-frontend
flutter pub get 
flutter run 
```

## 📱 Live Beta Testing

The application is currently in active testing. You can try the live build without setting up the backend locally.

**1. Download the Build:**
Get the latest stable version here: [**Download linkup Beta (v1.0.0-beta)**](https://github.com/olildu/linkup-frontend/releases/download/v1.0.0-beta/app-release.apk)

**2. Test Credentials:**
Use the following pre-configured account to explore the real-time matching and chat features:

> 📧 **Email:** `tester@linkup.olildu.dpdns.org`  
> 🔑 **Password:** `TESTERcreds#40`
