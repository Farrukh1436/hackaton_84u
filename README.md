# hackaton_84u

Monorepo for an emergency assistance platform consisting of:
- A Flutter mobile app (Tez Yordam - 84U) under app/
- A Django REST API backend under backend_server/
- A React + Vite dispatch web panel under despatch_panel/

This README provides an overview, tech stack, entry points, environment variables, setup/run commands, scripts, tests, project structure, and license/TODOs.

## Overview
- Mobile app: Flutter application that initializes language and storage, and routes users to Splash or Main screens based on auth token.
- Backend: Django + Django REST Framework API with JWT auth (SimpleJWT), PostgreSQL, CORS enabled. URL base prefix: /api/v1/.
- Web panel: React (Vite) dashboard for dispatchers to view and manage emergencies. Uses a configurable API base URL (currently hardcoded) to talk to the backend.

See also readme_application.md for historical app notes and endpoint ideas. Some of those differ from the current backend; validate before relying on it.

## Tech stack and entry points
- Mobile (Flutter/Dart)
  - Language: Dart (SDK constraint in pubspec.yaml: ^3.8.0)
  - Framework: Flutter (Material3)
  - Key packages: shared_preferences, http, geolocator, permission_handler, intl, cached_network_image, flutter_svg, flutter_localizations, restart_app, flutter_launcher_icons
  - Entry point: app/lib/main.dart (main() -> runApp(EmergencyApp()))
  - API config: app/lib/services/api/url.dart

- Backend (Python/Django)
  - Language: Python
  - Frameworks: Django 5.x, Django REST Framework, SimpleJWT, django-cors-headers
  - Storage: PostgreSQL
  - Config: backend_server/config/settings.py (env via python-decouple)
  - Entry point: backend_server/manage.py (DJANGO_SETTINGS_MODULE=config.settings)
  - URL root: backend_server/config/urls.py mounts apps at /api/v1/ (accounts/, services/)

- Dispatch panel (React/Vite)
  - Language: JavaScript/React 19, built with Vite 6, TailwindCSS, lucide-react
  - Entry point: despatch_panel/src/main.jsx (mounts App)
  - App root: despatch_panel/src/App.jsx (currently sets API_BASE_URL inside code)
  - Package manager: npm (package.json scripts: dev, build, lint, preview)

## Requirements
- Common
  - Git

- Mobile (app/)
  - Flutter SDK with Dart 3.8 compatible (see app/pubspec.yaml)
  - Android Studio and/or Xcode for platform builds

- Backend (backend_server/)
  - Python (version compatible with Django 5.x)
  - PostgreSQL server
  - pip/venv

- Dispatch panel (despatch_panel/)
  - Node.js (version compatible with Vite 6 and React 19). Node 18+ is typically sufficient.
  - npm (or pnpm/yarn if you prefer; examples below use npm)

## Environment variables
- Backend (python-decouple in settings.py)
  - SECRET_KEY
  - DEBUG (e.g., True/False)
  - DATABASE_NAME
  - DATABASE_USER
  - DATABASE_PASSWORD
  - DATABASE_HOST
  - DATABASE_PORT
  - EMAIL_HOST_USER
  - EMAIL_HOST_PASSWORD

  Example .env (place in backend_server/.env or in your environment):
  SECRET_KEY=change-me
  DEBUG=True
  DATABASE_NAME=hackaton_db
  DATABASE_USER=postgres
  DATABASE_PASSWORD=postgres
  DATABASE_HOST=127.0.0.1
  DATABASE_PORT=5432
  EMAIL_HOST_USER=example@gmail.com
  EMAIL_HOST_PASSWORD=app-password

- Mobile (Flutter)
  - Currently hardcoded in app/lib/services/api/url.dart:
    - Urls.apiBaseUrl = https://client.84u.uz/api
    - Urls.apiEmergencyBaseUrl = https://emergency.84u.uz/api
    - Urls.yandexMapDecoderApiKey = <key>
  - TODO: Move these to flavors/build-time config or a secure runtime config solution.

- Dispatch panel (Vite/React)
  - Currently sets API_BASE_URL const in despatch_panel/src/App.jsx to http://localhost:8000/api
  - Backend’s actual prefix is /api/v1/, so the paths should be aligned.
  - TODO: Externalize to Vite env (e.g., VITE_API_BASE_URL) and update fetch calls.

## Setup and run

### 1) Backend (Django API)
Commands are run from backend_server/.

- Create and activate virtualenv, install deps:
  python -m venv .venv
  source .venv/bin/activate  # Windows: .venv\Scripts\activate
  pip install -r requirements.txt

- Create .env and set variables (see Environment variables above).

- Run migrations and start server:
  python manage.py migrate
  python manage.py createsuperuser  # optional
  python manage.py runserver 0.0.0.0:8000

- Example endpoints (once running):
  - Health check: GET http://localhost:8000/api/v1/services/hello/
  - Auth: POST http://localhost:8000/api/v1/accounts/login/
  - Register: POST http://localhost:8000/api/v1/accounts/register/
  - OTP request: POST http://localhost:8000/api/v1/services/auth/request-otp/
  - OTP verify: POST http://localhost:8000/api/v1/services/auth/verify-otp/

### 2) Mobile app (Flutter)
Commands are run from app/.

- Install dependencies:
  flutter pub get

- Configure API endpoints:
  - Update app/lib/services/api/url.dart to point to your backend (e.g., http://localhost:8000/api/v1/ equivalents).
  - Note: The app automatically pings baseUrl + /services/hello/ to detect online mode.

- Run on device/emulator:
  flutter run

- Build (examples):
  flutter build apk        # Android
  flutter build ios        # iOS (on macOS with Xcode configured)
  flutter build web        # optional if web support enabled

### 3) Dispatch panel (React + Vite)
Commands are run from despatch_panel/.

- Install dependencies:
  npm install

- Configure API endpoint:
  - TODO: Replace hardcoded API_BASE_URL in src/App.jsx with import.meta.env.VITE_API_BASE_URL
  - Create .env and set, e.g.:
    VITE_API_BASE_URL=http://localhost:8000/api/v1

- Start dev server:
  npm run dev

- Build and preview:
  npm run build
  npm run preview

## Scripts
- despatch_panel/package.json scripts:
  - dev: vite
  - build: vite build
  - lint: eslint .
  - preview: vite preview

- backend_server/manage.py common commands:
  - runserver, migrate, makemigrations, createsuperuser, test

- Flutter common commands:
  - flutter pub get, flutter run, flutter test, flutter build <platform>

- scripts/ directory:
  - Contains scripts/temo (empty placeholder at time of writing)
  - TODO: Document or remove if not needed.

## Tests
- Mobile (Flutter):
  - Example test exists at app/test/widget_test.dart
  - Run: flutter test

- Backend (Django):
  - Test placeholders exist in accounts/tests.py and services/tests.py
  - Run: python manage.py test

- Dispatch panel:
  - No tests found. TODO: Add tests (e.g., Vitest/RTL) and document commands here.

## Project structure (selected)
- app/ — Flutter mobile application
  - lib/main.dart — app entry
  - lib/services/api/ — API client (api_service.dart) and Urls (url.dart)
  - assets/fonts/ — Nunito font family
  - test/ — Flutter tests
  - android/, ios/, macos/, linux/, windows/, web/ — platform folders

- backend_server/ — Django project
  - manage.py — entry script
  - config/settings.py, urls.py — settings and URL router (/api/v1/...)
  - accounts/ — custom user and auth endpoints (login, register)
  - services/ — service endpoints (hello, OTP request/verify)
  - requirements.txt — backend dependencies

- despatch_panel/ — React + Vite dispatch dashboard
  - src/main.jsx — web entry
  - src/App.jsx — main application
  - package.json — web scripts and dependencies

- docs/ — documentation (if any)
- readme_application.md — historical notes and endpoint ideas for the app
- scripts/ — helper scripts (currently contains an empty placeholder file)

## Notes and discrepancies
- The dispatch panel currently points to http://localhost:8000/api but the backend mounts at /api/v1/. TODO: Align base paths and centralize configuration via env.
- The Flutter app has hardcoded URLs and an API key in url.dart. TODO: Externalize securely (flavors, build-time defines, or secure storage) and avoid committing secrets.

## License
No LICENSE file was found in the repository root. TODO: Choose and add a LICENSE (e.g., MIT/Apache-2.0) and update this section.
