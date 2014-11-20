FROM rox-center-ruby

RUN mkdir -p /build
WORKDIR /build

COPY Gemfile /build/
COPY Gemfile.lock /build/
RUN bundle install
