FROM golang:1.24-alpine

WORKDIR /app
COPY . .
RUN go build -o pad main.go

ENTRYPOINT ["/app/pad"]
