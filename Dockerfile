FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 go build -o tracker main.go parcel.go

FROM alpine:latest

WORKDIR /app

# Устанавливаем sqlite3
RUN apk add --no-cache sqlite

COPY --from=builder /app/tracker /app/tracker

# Команда, которая сначала создает БД, потом запускает приложение
CMD sh -c "sqlite3 /app/tracker.db 'CREATE TABLE IF NOT EXISTS parcel (number INTEGER PRIMARY KEY AUTOINCREMENT, client INTEGER NOT NULL, status TEXT NOT NULL, address TEXT NOT NULL, created_at TEXT NOT NULL);' && /app/tracker"