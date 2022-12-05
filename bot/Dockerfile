FROM ruby:3.1.2

# general setup
WORKDIR /bot

# ruby setup
RUN gem install bundler
COPY Gemfile /bot/Gemfile
COPY Gemfile.lock /bot/Gemfile.lock
ENV BUNDLE_PATH /gems
RUN bundle install

# final setup
COPY . /bot/

CMD ["bundle", "exec", "puma"]
