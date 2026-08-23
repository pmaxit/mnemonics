FROM dart:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o bin/notification_server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/bin/notification_server /app/notification_server
EXPOSE 8080
ENV PORT=8080
ENV DATA_DIR=/data
CMD ["/app/notification_server"]