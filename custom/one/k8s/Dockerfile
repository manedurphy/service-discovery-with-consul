FROM golang:1.17-alpine3.15 as builder

WORKDIR /app

COPY ./ ./
RUN go mod tidy -go 1.16 && \
	go mod tidy -go 1.17 && \
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./one custom/one/k8s/main.go

FROM alpine:3.15.0

WORKDIR /app

RUN apk --no-cache add ca-certificates

COPY --from=builder /app/one /app/one

ENTRYPOINT [ "/app/one" ]