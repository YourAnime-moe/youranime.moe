FROM ruby:3.1.2

RUN apt-get update -y
RUN apt-get install -y nano

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install --retry 5 --jobs 4

COPY . /app

CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
