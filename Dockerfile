FROM ruby:2.7.1

LABEL maintainer="Organizational Chart API Eduardo"

RUN apt-get update && apt-get install -y build-essential libpq-dev postgresql-client

WORKDIR /app

ADD . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]