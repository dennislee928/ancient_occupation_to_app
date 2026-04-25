FROM ruby:3.3-alpine

RUN apk add --no-cache build-base postgresql-dev tzdata

WORKDIR /app

COPY Gemfile ./
RUN bundle config set without "development test" && bundle install

COPY . .

RUN addgroup -S app && adduser -S app -G app && chown -R app:app /app

USER app
EXPOSE 9292

CMD ["ruby", "app/server.rb"]
