FROM python:3.6-alpine

RUN apk update

RUN pip3 install --upgrade pip

#RUN pip3 install flask

#RUN pip3 install requests

RUN mkdir url_status_project && cd url_status_project

WORKDIR /url_status_project

COPY ./requirements.txt /url_status_project/tmp/

RUN pip3 install -r ./tmp/requirements.txt

EXPOSE 5000