FROM ruby:2.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development test

ADD run.rb /usr/src/app/run.rb
ADD *.handlebars /usr/src/app/

ENTRYPOINT ["/usr/src/app/run.rb"]
