FROM golang:1.26-alpine AS build

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/go-api ./cmd/api

FROM alpine:3.22

RUN addgroup -S app && adduser -S app -G app

WORKDIR /app
COPY --from=build /out/go-api /usr/local/bin/go-api

USER app
EXPOSE 8080

CMD ["go-api"]
