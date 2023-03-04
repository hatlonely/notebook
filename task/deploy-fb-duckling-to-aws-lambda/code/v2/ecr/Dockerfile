FROM rasa/duckling:0.2.0.2-r1

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.6.2 /lambda-adapter /opt/extensions/lambda-adapter

ENV PORT=8000
EXPOSE 8000

CMD ["/usr/local/bin/duckling-example-exe", "-p", "8000", "--no-access-log", "--no-error-log"]
