FROM python:3.12.0rc2-alpine3.18

COPY ./app /app
WORKDIR /app

RUN pip3 install -r requirements.txt

CMD [ "flask", "--app", "main.py", "run" ]
