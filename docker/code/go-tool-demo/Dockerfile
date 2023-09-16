FROM golang:1.18 AS builder

COPY helloworld.go /code/helloworld.go
RUN go build -o /code/helloworld /code/helloworld.go

FROM scratch

COPY --from=builder /code/helloworld /
ENTRYPOINT [ "/helloworld" ]
