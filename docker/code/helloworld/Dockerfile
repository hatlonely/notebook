FROM gcc AS builder

COPY helloworld.c /code/helloworld.c
RUN gcc -static -o /code/helloworld /code/helloworld.c

FROM scratch

COPY --from=builder /code/helloworld /
ENTRYPOINT [ "/helloworld" ]
