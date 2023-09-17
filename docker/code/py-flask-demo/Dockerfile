FROM python:3.12.0rc2-alpine3.18

COPY ./app /app
WORKDIR /app

RUN pip3 install -r requirements.txt

EXPOSE 8000
CMD [ "gunicorn", "-c", "config.py", "main:app" ]
