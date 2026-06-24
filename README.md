# Task Manager — Flutter

A Task Manager mobile app built for the **Electro Pi – Flutter Mobile Developer** technical assessment. It demonstrates clean architecture, consistent state management with **Riverpod**, REST API integration, secure JWT storage, offline caching, and graceful loading/error handling.

---

## ✨ Features

### Required
- **Authentication** — Login (email + password) and Registration (name, email, password) with form validation. A JWT is minted on success and stored securely; the app **auto-navigates to Home if a valid session exists**.
- **Projects / Home** — List of projects from the API, each showing title, description and status, with **pull-to-refresh** and an **empty-state** widget.
- **Project Details** — All tasks for the selected project. Each task shows title, status (Pending / In Progress / Done) and priority. **Mark tasks done** and **add new tasks** via a bottom sheet.
- **Profile / Settings** — Shows the signed-in user's name and email, plus a **Logout** button that clears the token and returns to Login.

### Technical
- Strict separation of **UI / business logic / data** layers (Clean Architecture).
- **Riverpod** used consistently across the whole app (`AsyncNotifier`, `Notifier`, families).
- Loading, error and empty states handled uniformly via `AsyncValue` + shared widgets.
- Responsive layouts (forms cap their width on large screens; lists adapt).
- Navigation with **GoRouter**, including an auth-aware redirect guard.
- Reusable widget components (`AppButton`, `AppTextField`, `LoadingView`, `ErrorView`, `EmptyState`, `StatusChip`).

### Bonus (all implemented)
- 🌙 **Dark mode** with a toggle in Profile, persisted across restarts.
- 📦 **Offline caching** with Hive — projects and tasks load from cache when offline.
- 🎬 **Animations** — Hero transition on project titles + custom fade/slide page transitions.
- 🧪 **Tests** — unit tests (validators, model mapping, repository logic with mocktail) and widget tests.

---

## 🏗️ Architecture

Clean Architecture, organized **by feature**. Each feature has three layers:

```
lib/
├── core/                      # cross-cutting concerns
│   ├── constants/             # API + storage keys
│   ├── error/                 # Failure + Exception types
│   ├── network/               # Dio client, auth interceptor, connectivity
│   ├── storage/               # secure storage (JWT) + Hive boxes
│   ├── router/                # GoRouter + auth guard + route constants
│   ├── theme/                 # light/dark themes + theme provider
│   ├── usecase/               # base UseCase contract
│   ├── utils/                 # validators
│   └── widgets/               # reusable UI components
└── features/
    ├── auth/                  # login, register, mock JWT session
    ├── projects/              # projects list (Home)
    ├── tasks/                 # tasks per project (Details)
    └── profile/               # profile / settings
        ├── data/              #   models · datasources · repository impl
        ├── domain/            #   entities · repository contracts · use cases
        └── presentation/      #   providers (Riverpod) · screens · widgets
```

**Data flow:** `Screen → Riverpod Notifier → UseCase → Repository (contract) → RepositoryImpl → DataSource (remote/local)`.
Repositories return `Either<Failure, T>` (via **fpdart**) so errors are explicit and never leak as raw exceptions to the UI.

**State management:** Riverpod providers wire dependencies (DI) and expose state. Async screens render through `AsyncValue.when(...)` mapped to the shared `LoadingView` / `ErrorView` / `EmptyState` widgets, keeping loading and error handling consistent everywhere.

---

## 🔌 API & Mock Auth (important implementation notes)

The app uses **[dummyjson.com](https://dummyjson.com)** as the REST backend. Since it has no native "project/task" resources (and its per-user todos are sparse), the following mappings were made — all **isolated in the data layer**, so a real backend could be dropped in by changing only the data sources:

| App concept | API source | Notes |
|---|---|---|
| **Projects** | `GET /posts?limit=30` | Response is wrapped (`{ "posts": [...] }`). `body` → description. No status field, so status is derived deterministically from the id (`id % 3` → Active / On Hold / Completed). |
| **Tasks** | `GET /todos?limit=10&skip={f(projectId)}` | The API has no project→task link, and `/todos/user/{id}` is mostly empty, so each project is mapped to a **stable, non-empty slice** of `/todos` (skip derived from the project id). dummyjson's text field `todo` → title; `completed` → Done/Pending; priority derived from id (`id % 3` → Low/Medium/High). |
| **Mark done** | `PATCH /todos/{id}` | dummyjson echoes the change (does not persist). |
| **Add task** | `POST /todos/add` | dummyjson echoes a created todo (does not persist). |

- **Mock authentication:** dummyjson only authenticates its own predefined **usernames** (not arbitrary emails) and can't register new users, which is incompatible with the required *email + registration* flow — so auth is handled **locally**. Registration stores the user (with a salted SHA-256 password hash) in Hive. Login verifies the credentials and **mints a JWT** (`header.payload.signature`, base64url, carrying the user id and a 7-day expiry). The token is persisted with **`flutter_secure_storage`** (Keychain/Keystore) and attached as a `Bearer` header by a Dio interceptor. On launch the token's expiry is checked to restore the session.
- **Resilient networking:** a Dio **retry interceptor** retries transient connection failures (timeouts / connection resets) up to 3× with backoff before surfacing an error.
- **Cache as source of truth for writes:** since the API does not persist writes, once tasks are loaded the local Hive cache becomes authoritative. Mutations (toggle/add) are applied to the cache (with best-effort remote sync) so they survive navigation and work offline.

---

## 🚀 How to Run

**Prerequisites:** Flutter (stable, 3.41+) and an Android/iOS emulator or device.

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Run the tests
flutter test

# 4. Static analysis (should report no issues)
flutter analyze

# 5. Build a release APK
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

> No code generation step is required — models use hand-written `fromJson`/`toJson`, so a fresh clone runs immediately after `flutter pub get`.

### 🔑 Login credentials

Authentication is **mock/local** (jsonplaceholder has no auth endpoint), so there is **no pre-seeded account**.

> **On first launch, tap _Register_ to create an account** (any name, a valid email, and a password of 6+ characters — e.g. `jane@example.com` / `secret1`). You'll be signed in automatically. After that you can **log in** with those same credentials.

Credentials are stored locally on the device (hashed) and persist until you log out or uninstall, so logging straight into the **Login** screen will fail until an account has been registered on that device.

**Quick walkthrough:** Register → Home → open a project → toggle/add tasks → open Profile to switch theme or log out. Re-launching the app keeps you logged in until you log out.

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management & dependency injection |
| `dio` | HTTP client (interceptors, timeouts) |
| `go_router` | Declarative navigation + auth redirect guard |
| `flutter_secure_storage` | Secure JWT storage (Keychain/Keystore) |
| `hive` / `hive_flutter` | Local cache & settings (offline support) |
| `fpdart` | `Either<Failure, T>` functional error handling |
| `connectivity_plus` | Online/offline detection |
| `equatable` | Value equality for entities/models |
| `crypto` | Password hashing for mock auth |
| `mocktail` *(dev)* | Mocking in unit tests |
| `flutter_lints` *(dev)* | Recommended lint rules |

---

## 📸 Screenshots

> _Add screenshots / a screen recording here (Login, Home, Project Details, Profile in light & dark)._

| Login | Home | Details | Profile |
|---|---|---|---|
| _tbd_ | _tbd_ | _tbd_ | _tbd_ |

---

## 🧪 Tests

```bash
flutter test
```

Covers: input validators, `TaskModel` API/JSON mapping & derivation, `ProjectRepository` network-first / cache-fallback logic (mocktail), and widgets (`EmptyState`, `ProjectCard`, login validation).
