FROM rubylang/ruby:2.7.1-bionic
RUN ["/bin/bash", "-c", "set -o pipefail && \
      mkdir -p /app /bundle /node_modules && \
      chown -R ubuntu:ubuntu /app /bundle /node_modules && \
      apt-get update -qq && \
      apt-get install -y curl gnupg && \
      { curl -fsSL https://deb.nodesource.com/setup_14.x | bash -; } && \
      { curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; } && \
      echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list && \
      apt-get update -qq && \
      apt-get install -y nodejs postgresql-client build-essential libpq-dev yarn"]

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
USER ubuntu

WORKDIR /app
ENV PATH /app/bin:$PATH
EXPOSE 3000
CMD ["rails", "server", "--binding", "0.0.0.0", "--port", "3000"]
