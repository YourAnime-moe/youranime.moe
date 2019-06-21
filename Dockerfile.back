FROM ruby:2.6.3
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN apt-get install -y postgresql postgresql-contrib
RUN mkdir /tanoshimu
WORKDIR /tanoshimu
COPY Gemfile /tanoshimu/Gemfile
COPY Gemfile.lock /tanoshimu/Gemfile.lock
RUN bundle install
COPY . /tanoshimu

COPY anime.sh /usr/bin/
RUN chmod +x /usr/bin/anime.sh
ENTRYPOINT ["anime.sh"]
EXPOSE 3000

USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf
EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c", "config_file=/etc/postgresql/9.6/main/postgresql.conf"]
CMD ["service", "postgresql", "start"]

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
