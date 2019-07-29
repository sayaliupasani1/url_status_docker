FROM python:3.6-alpine

RUN apk update

RUN pip3 install --upgrade pip

#RUN pip3 install flask

#RUN pip3 install requests

RUN mkdir url_status_project && cd url_status_project

WORKDIR /url_status_project

COPY app .

RUN pip3 install -r /url_status_project/requirements.txt

EXPOSE 5000

CMD ["python", "status_app.py"]