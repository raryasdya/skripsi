FROM golang:1.18-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/membership main.go

FROM alpine:latest
COPY --from=builder /app/bin/membership .
CMD [ "./membership" ]