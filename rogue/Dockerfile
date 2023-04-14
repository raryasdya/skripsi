FROM golang:1.18-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o bin/rogue main.go

FROM alpine:latest
COPY --from=builder /app/bin/rogue .
CMD [ "./rogue" ]