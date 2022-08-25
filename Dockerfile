FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN apt-get install -y software-properties-common
RUN gem install bundler:2.2.19
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
ENV BUNDLE_PATH /gems
RUN bundle install --jobs 4 --retry 5
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
