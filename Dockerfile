FROM ruby:3.1-alpine AS builder

RUN apk add --no-cache build-base

WORKDIR /app

COPY Gemfile Gemfile.lock bardo.gemspec ./
COPY lib/bardo/version.rb lib/bardo/version.rb

RUN bundle config set --local without 'development' && \
    bundle install --jobs 4

COPY . .

# ---

FROM ruby:3.1-alpine

RUN apk add --no-cache libstdc++

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app .

ENTRYPOINT ["ruby", "bin/bardo-cli"]
