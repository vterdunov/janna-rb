FROM ruby:2.3-alpine

ENV APP_HOME /usr/src

ARG PACKAGES=' \
    ruby-dev \
    build-base \
    curl \
    libxml2-dev \
    libxslt-dev \
    libffi-dev'

RUN apk add --no-cache --update $PACKAGES && \
    rm -rf /var/cache/apk/*

WORKDIR $APP_HOME
COPY Gemfile $APP_HOME
COPY Gemfile.lock $APP_HOME
RUN bundle install --jobs=4 --retry=4

COPY . $APP_HOME

ENTRYPOINT ["bundle", "exec"]
CMD ["shotgun", "--server", "puma", "--host", "0.0.0.0", "--port", "4567"]
