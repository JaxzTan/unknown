# Frontend architecture

Flutter app (package `app`, org `com.unknown`) targeting iOS, Android, web, and desktop.
It talks to the Next.js backend over HTTP/JSON.

## Data flow

```
Widget ──▶ http.get('$apiUrl/api/<name>') ──▶ Next.js backend
   ▲                                              │
   └──────────── FutureBuilder renders JSON ◀─────┘
```

## Layout

```
frontend/
├── lib/
│   └── main.dart        # App, HealthPage, API_URL config
├── test/
│   └── widget_test.dart # smoke test
├── android/ ios/ macos/ linux/ windows/ web/   # platform runners
├── docker/
│   ├── dev.sh           # Docker dev: flutter run web-server + auto hot reload on lib/ change
│   └── nginx.conf       # Docker prod: serves build/web, SPA fallback
├── Dockerfile           # stages: dev (:8080), web (nginx) — see docs/docker.md
├── .dockerignore
└── pubspec.yaml         # deps: http
```

Generated, gitignored: `build/`, `.dart_tool/`, `*/Flutter/ephemeral/`, `ios/Flutter/Generated.xcconfig`, `android/local.properties`.
Kept in git (Flutter default): `*/flutter/generated_plugin_registrant.*`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `.metadata`.

## Backend URL

Set at build time with `--dart-define=API_URL=...` and read via `String.fromEnvironment('API_URL')`.

| Target                    | `API_URL`                   |
|---------------------------|-----------------------------|
| iOS sim / macOS / web     | `http://localhost:3000` (default) |
| Android emulator          | `http://10.0.2.2:3000`      |
| Physical device           | `http://<your-LAN-IP>:3000` |
| Docker (`make dev` / `make`) | `http://localhost:3000` (set in `compose.yaml`) |

The macOS entitlements include `com.apple.security.network.client` so the app can make outbound requests.

## Planned structure (as the app grows)

```
lib/
├── main.dart            # runApp + MaterialApp only
├── config.dart          # apiUrl and other env
├── api/                 # one client class per backend resource
├── models/              # fromJson/toJson data classes
└── screens/             # one file or folder per screen
```

Rule: screens never call `http` directly; they go through `api/`.

## Not yet decided

- State management (setState today; Riverpod/Bloc later?)
- Routing (Navigator today; go_router later?)
- Auth token storage
