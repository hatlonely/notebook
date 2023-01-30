ARG LAMBDA_TASK_ROOT="/var/task"

FROM python:3.9
ARG LAMBDA_TASK_ROOT
RUN pip3 install --upgrade pip
RUN pip3 install awslambdaric --target ${LAMBDA_TASK_ROOT}

ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
RUN chmod +x /usr/bin/aws-lambda-rie

WORKDIR /var/task
COPY requirements.txt .
RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY app.py ${LAMBDA_TASK_ROOT}
COPY lambda-entrypoint.sh /lambda-entrypoint.sh
CMD [ "app.handler" ]
ENTRYPOINT [ "/lambda-entrypoint.sh" ]
