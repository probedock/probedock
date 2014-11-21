FROM alphahydrae/ruby-node-pg:0.1.0
MAINTAINER Simon Oulevay <docker@alphahydrae.com>

RUN mkdir -p /build
WORKDIR /build

COPY Gemfile /build/
COPY Gemfile.lock /build/
RUN bundle install

WORKDIR /app
