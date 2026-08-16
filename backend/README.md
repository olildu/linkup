<p align="center">
  <img src="https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/images/app_logo/app_logo_transparent.png" 
       alt="LinkUp Logo" 
       width="180">
</p>

# 🚀 LinkUp: The Backend Engine

A high-performance, asynchronous REST and WebSocket API built with **FastAPI**. This backend powers the LinkUp ecosystem with real-time matching, secure authentication, and scalable messaging infrastructure.

<p align="center">
  <a href="https://x.com/olildu">
    <img src="https://img.shields.io/twitter/follow/olildu.svg?style=social&label=Follow" alt="Twitter">
  </a>
  &nbsp;&nbsp;
  <a href="https://www.linkedin.com/in/ebinsanthosh/">
    <img src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>

## 🌟 Project Highlights & Technical Differentiators

This project demonstrates expertise in asynchronous Python development, complex database orchestration, and real-time event-driven architecture.

| Feature | Technical Implementation | Engineering Value Demonstrated |
| :--- | :--- | :--- |
| **Asynchronous Core** | **FastAPI** + **AsyncPG** connection pooling | High-concurrency handling, non-blocking I/O, optimized throughput |
| **Real-Time Events** | **WebSockets** with polymorphic event validation via **TypeAdapter** | Robust real-time messaging, typing indicators, and read receipts |
| **Low-Latency Caching** | **Redis** integration for state management | Reduced database load, fast access to transient session data |
| **Task Orchestration** | **APScheduler** for cron-based background jobs | Reliable execution of periodic events (e.g., "Meet at 8" lobby) |

## 🧱 Architecture Overview: Asynchronous Micro-services

The backend is organized feature-first: `app/features/<name>/` holds each product feature's endpoints, utilities, and models together (mirroring the frontend's `frontend/lib/features/<name>/` convention), while `app/core/` holds infrastructure shared by 3+ features — controllers (DB, Redis, S3, etc.), constants, token decoding, and generic exception handling.

### **API Entry & Middleware (`app/main.py`)**
- Orchestrates the app lifecycle, managing the database pool and background schedulers.
- Implements versioned routing (`/api/v1`) for seamless future updates.
- Serves static assets for legal and safety documentation.

### **Websocket Layer (`app/features/chat`, `app/features/connections`, `app/features/lobby`)**
- **Chat Socket** — Manages persistent bi-directional connections for messaging, supporting text content, media metadata, and delivery states.
- **Lobby Socket** — Powers the synchronous matchmaking lobby with automated waiting periods.

### **Feature Layer (`app/features/`)**
- **Security** — Implements JWT-based authentication and secure password hashing (`app/features/auth/`).
- **Data Validation** — Leverages Pydantic for strict schema enforcement across all REST and WebSocket payloads.

## ⚙️ Core Modules & Components

| Module | Purpose | Key Files |
| :--- | :--- | :--- |
| **Auth Service** | Multi-stage registration and secure login | `auth_endpoints.py`, `auth_utilities.py` |
| **Match Engine** | Location-based filtering and swipe logic | `swipe_endpoint.py`, `matches_utilities.py` |
| **Likes-You Queue** | Ordered "who liked you" reveal queue, like-back/pass, live badge | `likes_endpoint.py`, `likes_utilities.py` |
| **Chat Service** | Persistence and delivery of real-time interactions | `chat_websocket_endpoints.py`, `chat_utilities.py` |
| **Controller Layer** | Interface for PostgreSQL, Redis, and Cloud Storage | `db_controller.py`, `redis_controller.py` |

## 🛠️ Development Setup

Requires **Docker** and **Docker Compose**. (Requires **Python 3.12+** if running outside Docker.)

### **1. Configuration**
```bash
  cp .env.example .env
  # fill in real secrets (JWT, ImageKit, Backblaze B2, Brevo, etc.)
```
`DATABASE_HOST`/`REDIS_URL` are overridden by `docker-compose.yml` to point at
the sibling `postgres`/`redis` containers regardless of what's in `.env`.

### **2. Running the Server**
```bash
  cd backend
  docker compose up --build
```
This starts `postgres`, `redis`, and `backend` (hot-reload enabled via
`docker-compose.override.yml`, auto-merged by `docker compose up`). The API
is served at `http://localhost:8002`.

On every backend container start, `migrate.py` runs automatically before
`uvicorn` to bring the database schema up to date — see
[Database Migrations](#-database-migrations) below.

For a production deployment (prebuilt image, restart policies, Watchtower
auto-updates), see `docker-compose.prod.yml`.

## 🗄️ Database Migrations

`schema.sql` is only executed by Postgres on first container init against an
**empty** volume — editing it has no effect on a database that already
exists. `migrations/` + `migrate.py` are what actually keep an existing
database (local dev or prod) in sync with it.

- Whenever you change `schema.sql`, also add a new idempotent file to
  `migrations/000N_short_description.sql` (see `migrations/README.md` for
  the convention).
- `migrate.py` tracks applied filenames in a `schema_migrations` table and
  only runs what's new. It's wired into the `command:` of every compose
  file, so it runs automatically on backend startup.
- To run it manually against an already-running container:
  ```bash
  docker compose exec backend python migrate.py
  ```

## 📱 Ecosystem Logic

LinkUp Backend is designed to maintain **high availability** and **data integrity** through the following mechanisms:

- **Connection Resilience:**  
  WebSocket connections handle disconnects gracefully, ensuring no messages are lost during network transitions or temporary network failures.

- **Automated Maintenance:**  
  APScheduler manages the daily lifecycle of matching events, ensuring consistent engagement and timely updates for the user base.

- **Data Protection:**  
  All user interactions are strictly validated using Pydantic models before reaching the persistence layer, preventing malformed or unsafe data from being stored.
