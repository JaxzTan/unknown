# unknown

Monorepo: Flutter app (`frontend/`) + Next.js API (`backend/`).

## Run

```bash
# 1. Backend (http://localhost:3000)
cd backend && npm install && npm run dev

# 2. Frontend (new terminal)
cd frontend && flutter run
```

Check the backend: `curl http://localhost:3000/api/health`

## API URL per platform

The Flutter app reads `API_URL` (default `http://localhost:3000`):

| Target            | Command                                                  |
|-------------------|----------------------------------------------------------|
| iOS sim / macOS / web | `flutter run`                                        |
| Android emulator  | `flutter run --dart-define=API_URL=http://10.0.2.2:3000` |
| Physical device   | `flutter run --dart-define=API_URL=http://<your-LAN-IP>:3000` |

## Layout

- `backend/src/app/api/*/route.ts` — API routes (add new endpoints here)
- `frontend/lib/main.dart` — app entry, calls `/api/health`
