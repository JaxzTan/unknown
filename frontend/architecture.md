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
└── pubspec.yaml         # deps: http
```

## Backend URL

Set at build time with `--dart-define=API_URL=...` and read via `String.fromEnvironment('API_URL')`.

| Target                    | `API_URL`                   |
|---------------------------|-----------------------------|
| iOS sim / macOS / web     | `http://localhost:3000` (default) |
| Android emulator          | `http://10.0.2.2:3000`      |
| Physical device           | `http://<your-LAN-IP>:3000` |

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
