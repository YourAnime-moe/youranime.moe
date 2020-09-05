FROM ruby:2.6.3
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn nodejs postgresql-client 
RUN apt-get install -y software-properties-common
RUN gem install bundler:1.17.3
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY package.json /app/package.json
ENV BUNDLE_PATH /gems
RUN bundle install --jobs 4 --retry 5
RUN yarn install --check-files
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
