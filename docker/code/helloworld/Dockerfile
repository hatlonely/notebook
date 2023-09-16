FROM gcc AS builder

COPY helloworld.c /workspace/helloworld.c
RUN gcc -static -o /workspace/helloworld /workspace/helloworld.c

FROM scratch

COPY --from=builder /workspace/helloworld /
ENTRYPOINT [ "/helloworld" ]
