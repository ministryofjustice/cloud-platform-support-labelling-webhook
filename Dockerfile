FROM ruby:2.5.1-alpine3.7

WORKDIR /usr/src/app

ADD . /usr/src/app

# add packages not in alpine ruby base image (https://github.com/exAspArk/docker-alpine-ruby/blob/master/Dockerfile)
RUN \
  # update packages
  apk update && apk upgrade && \

  # gem 'puma', 'byebug'
  apk --no-cache add make gcc libc-dev && \

  # clear after installation
  rm -rf /var/cache/apk/*

# use mounted volume for gems
ENV BUNDLE_PATH /bundle

RUN bundle install

ENV PATH /usr/src/app:$PATH

ENTRYPOINT ["sh", "-c", "bundle exec ruby webhook.rb"]
