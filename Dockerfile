FROM ruby:3.1.2-slim as setup
RUN apt-get update -qq && apt-get install -y libpq-dev build-essential
RUN apt-get install -y software-properties-common
RUN gem install bundler:2.2.19

FROM setup as build
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
ENV BUNDLE_PATH /gems
VOLUME [ "/gems" ]
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

FROM build as dev
RUN bundle config set --local without production
RUN bundle install --jobs 4 --retry 5
COPY . /app

ENTRYPOINT ["entrypoint.sh"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]

FROM build as live
ENV RAILS_ENV production
ENV RACK_ENV production
ENV RAILS_LOG_TO_STDOUT enabled
RUN bundle config set --local without test development
RUN bundle install --jobs 4 --retry 5
COPY . /app

ENTRYPOINT ["entrypoint.sh"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "80"]
