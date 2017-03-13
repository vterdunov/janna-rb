FROM ruby:2.3-alpine

ENV APP_HOME /usr/src

ARG PACKAGES=' \
    ruby-dev \
    build-base \
    curl \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    sqlite \
    sqlite-dev'

RUN apk add --no-cache --update $PACKAGES && \
    rm -rf /var/cache/apk/*

WORKDIR $APP_HOME
COPY Gemfile $APP_HOME
COPY Gemfile.lock $APP_HOME
RUN bundle install --jobs=4 --retry=4

COPY . $APP_HOME

CMD ["rackup", "-s", "puma", "--host", "0.0.0.0.", "-p", "4567", "config.ru"]
