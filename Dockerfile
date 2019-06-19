FROM ruby:2.6.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY anime.sh /usr/bin/
RUN chmod +x /usr/bin/anime.sh
ENTRYPOINT ["anime.sh"]
EXPOSE 3000

# Start the main process.
RUN ./dbsetup.sh
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
