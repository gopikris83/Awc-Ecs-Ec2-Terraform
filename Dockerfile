FROM python:3.8-alpine

LABEL maintainer="Gopi Krishna <gopikrishna.83@gmail.com>"
LABEL name ="aws-ecs-app"

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip3 install -r requirements.txt

COPY . /app

EXPOSE 5000

CMD ["python3", "app.py"]