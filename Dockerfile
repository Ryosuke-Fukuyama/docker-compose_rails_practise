FROM node:16.13 as node
FROM ruby:3.0.1

COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
    && ln -fs /usr/local/lib/node /usr/local/bin/nodejs \
    && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarnpkg

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client
    # \
    # nodejs \
    # yarn

RUN mkdir /myapp
WORKDIR /myapp

# RUN bundle config set force_ruby_platform true

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
RUN gem install rubyzip -v "2.3.0"
RUN gem install webdrivers -v "5.3.0"

COPY package.json /myapp/package.json
COPY yarn.lock  /myapp/yarn.lock
RUN yarn install

COPY . /myapp
