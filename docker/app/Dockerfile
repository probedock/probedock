FROM alphahydrae/probe-dock-dev:angular

EXPOSE 3000

RUN mkdir -p /build
WORKDIR /build

COPY Gemfile /build/
COPY Gemfile.lock /build/
RUN bundle install

WORKDIR /app
