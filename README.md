# PolyQuiz — Interactive Real-Time Quiz Platform
> **Ranked #1 out of 20+ teams** in a university software engineering capstone project.

PolyQuiz is a full-stack, real-time multiplayer quiz platform built by a team of 6 developers. It supports **Android (Flutter)**, **Desktop/Web (Angular + Electron)**, and a shared **Node.js/Express** back-end — enabling users to create, share, and play quizzes with friends or the public.

![Architecture](https://img.shields.io/badge/Architecture-Monorepo-blue)
![Node.js](https://img.shields.io/badge/Node.js-Express-green)
![Angular](https://img.shields.io/badge/Angular-16-red)
![Flutter](https://img.shields.io/badge/Flutter-Dart-blue)
![Socket.IO](https://img.shields.io/badge/Socket.IO-Real--Time-yellow)
![MongoDB](https://img.shields.io/badge/MongoDB-Database-brightgreen)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-orange)

---

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Screenshots](#screenshots)
- [Team & Contributions](#team--contributions)

---

## Overview

PolyQuiz lets players join rooms in real-time, answer timed questions (multiple-choice, free-text, or numeric), and compete solo or in teams — all while hosts manage the game flow, evaluate answers, and view live statistics. The platform also includes social features (friends, chat channels, profiles), an in-app store, AI-powered answer grading, and full internationalization (English/French).

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        Clients                               │
│                                                              │
│   ┌──────────────────┐          ┌──────────────────┐         │
│   │  Flutter Mobile  │          │  Angular Desktop │         │
│   │  (Android)       │          │  (Web / Electron)│         │
│   └────────┬─────────┘          └────────┬─────────┘         │
│            │   Socket.IO + HTTP          │                   │
└────────────┼─────────────────────────────┼───────────────────┘
             │                             │
             ▼                             ▼
┌──────────────────────────────────────────────────────────────┐
│                   Node.js / Express Server                   │
│                                                              │
│   ┌────────────┐  ┌────────────────┐  ┌────────────────┐     │
│   │   REST API │  │  Socket.IO Hub │  │  Timer Service │     │
│   │  (Quizzes, │  │  (40+ events)  │  │  (Per-room     │     │
│   │   History) │  │                │  │   countdowns)  │     │
│   └──────┬─────┘  └───────┬────────┘  └────────────────┘     │
│          │                │                                  │
│          ▼                ▼                                  │
│   ┌────────────┐  ┌────────────────┐                         │
│   │  MongoDB   │  │  Firebase      │                         │
│   │  (Quizzes) │  │  (Users, Auth, │                         │
│   │            │  │   Chat, Stats) │                         │
│   └────────────┘  └────────────────┘                         │
└──────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Mobile Client** | Flutter (Dart), Firebase SDK, Socket.IO Client, Provider/GetX, fl_chart |
| **Desktop/Web Client** | Angular 16, TypeScript, Angular Material, Electron, Socket.IO Client, Chart.js, Tailwind CSS |
| **Back-End** | Node.js, Express.js, TypeScript, Socket.IO, TypeDI (Dependency Injection) |
| **Databases** | MongoDB (quiz data), Firebase Firestore (users, chat, game history) |
| **Authentication** | Firebase Auth (email/password), JWT, bcrypt |
| **Cloud Services** | Firebase Auth, Firestore, Cloud Storage, Cloud Messaging (push notifications) |
| **AI** | OpenAI API (automated free-text answer evaluation) |
| **Testing** | Mocha, Chai, Sinon, Supertest (server) · Karma, Jasmine (Angular) |
| **DevOps** | ESLint, Prettier, NYC code coverage, Nodemon |

---

## Key Features

### Game Modes & Question Types
- **Classic Mode** — individual competition with real-time scoring
- **Team Mode** — team creation, join, and aggregate scoring
- **Observer Mode** — spectators watch gameplay live, switch between players
- **3 Question Types:** Multiple Choice (QCM), Free-Text (QRL), Numeric with tolerance (QRE)

### Real-Time Multiplayer (Socket.IO)
- Room creation with unique codes and host controls
- Live answer tracking with animated statistics
- Server-side countdown timers with pause/resume and panic mode
- Instant score updates, bonus multipliers (1.2x), and final rankings
- 40+ socket events for seamless game orchestration

### Quiz Management
- Create, edit, and publish quizzes with image support
- Quiz validation, visibility controls (public/private), and owner tracking
- Test mode — simulate a full game before publishing

### Social & Communication
- In-game chat with per-room channels and moderation tools
- Friend system (add, accept/decline requests, friends-only games)
- User profiles with avatar upload/cropping, stats, and achievements

### User Progression
- Virtual currency, prestige levels, and achievements
- In-app store for cosmetics and features
- Detailed game history and personal statistics

### Internationalization
- Full English and French support (Angular: ngx-translate, Flutter: custom LanguageService)

### AI-Powered Grading
- OpenAI integration for automated free-text (QRL) answer evaluation

---

## Project Structure

```
projet/
├── client_leger/      # Flutter mobile app (Android)
├── client_lourd/      # Angular desktop/web app (+ Electron)
├── common/            # Shared TypeScript interfaces, enums, constants
├── server/            # Node.js/Express back-end with Socket.IO
└── README.md          # ← You are here
```

Each sub-folder contains its own README with detailed setup instructions and architecture breakdown.

---

## Getting Started

### Prerequisites
- **Node.js** ≥ 16 and **npm**
- **MongoDB** running locally or a cloud connection string
- **Firebase** project with Auth, Firestore, and Storage enabled
- **Flutter SDK** ≥ 2.18 (for the mobile client)
- **Angular CLI** ≥ 16 (for the desktop/web client)

### Quick Start

```bash
# 1. Clone the repository
git clone <repo-url> && cd projet

# 2. Start the server
cd server
npm install
npm start        # runs on http://localhost:3000

# 3. Start the Angular desktop client
cd ../client_lourd
npm install
npm start        # runs on http://localhost:4200

# 4. Start the Flutter mobile client
cd ../client_leger/polyquiz
flutter pub get
flutter run
```

> **Note:** Configure your own Firebase credentials and MongoDB connection string in the appropriate `.env` and config files before running. See each sub-folder's README for details.
