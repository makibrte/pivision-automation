FROM ubuntu:latest	
FROM python:3.9-bullseye
ADD crontab /etc/cron.d/testing	
RUN chmod 0644 /etc/cron.d/testing

RUN touch /var/log/cron.log
RUN apt update

RUN apt install cron -y

CMD cron && tail -f /var/log/cron.log



