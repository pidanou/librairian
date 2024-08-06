FROM golang:alpine3.20 as builder

WORKDIR /api

COPY . .

RUN go mod download
RUN go build -o api librairian.go

FROM alpine:latest

COPY --from=builder /api/api /api

EXPOSE 3001

ENTRYPOINT ["/api"]
