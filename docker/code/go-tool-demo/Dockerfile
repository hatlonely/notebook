FROM golang:1.18 AS builder

COPY helloworld.go /workspace/helloworld.go
RUN go build -o /workspace/helloworld /workspace/helloworld.go

FROM scratch

COPY --from=builder /workspace/helloworld /
ENTRYPOINT [ "/helloworld" ]
