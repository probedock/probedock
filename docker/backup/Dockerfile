FROM ruby:2.2

RUN gem install backup

RUN apt-get update -y
RUN apt-get install -y gnupg postgresql-client --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

# initialize gpg
RUN gpg --list-keys

VOLUME [ "/backup" ]

ENTRYPOINT [ "/usr/local/bundle/bin/backup" ]
CMD [ "perform", "--trigger", "probedock", "--config-file", "/backup/config.rb", "--root-path", "/var/lib/probedock/backup", "--data-path", "data", "--log-path", "log", "--tmp-path", "tmp" ]
