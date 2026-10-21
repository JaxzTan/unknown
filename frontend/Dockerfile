# syntax=docker/dockerfile:1
FROM ghcr.io/cirruslabs/flutter:3.38.7 AS base
WORKDIR /app
RUN flutter config --no-analytics --enable-web >/dev/null
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# ---- dev: web-server with hot reload on file change (see docker/dev.sh) ----
FROM base AS dev
COPY . .
EXPOSE 8080
CMD ["sh", "docker/dev.sh"]

# ---- build: release web bundle ----
FROM base AS build
ARG API_URL=http://localhost:3000
COPY . .
RUN flutter build web --release --dart-define=API_URL=${API_URL}

# ---- web: static files served by nginx ----
FROM nginx:1.27-alpine AS web
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
