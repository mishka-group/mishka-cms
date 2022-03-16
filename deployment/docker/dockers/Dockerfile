# Extend from the official Elixir image
FROM elixir:1.13.3-alpine

RUN apk update && apk add postgresql-client && rm -rf /var/cache/apk/*

WORKDIR /app
# Set environment to production

ARG SECRET_KEY_BASE \
    SECRET_KEY_BASE_HTML \
    SECRET_KEY_BASE_API \
    LIVE_VIEW_SALT \
    TOKEN_JWT_KEY \
    SECRET_CURRENT_TOKEN_SALT \
    SECRET_REFRESH_TOKEN_SALT \
    SECRET_ACCESS_TOKEN_SALT \
    CMS_DOMAIN_NAME \
    API_DOMAIN_NAME \
    CMS_PORT \
    API_PORT \
    PROTOCOL \
    EMAIL_SYSTEM \
    EMAIL_DOMAIN \
    EMAIL_PORT \
    EMAIL_SERVER \
    EMAIL_HOSTNAME \
    EMAIL_USERNAME \
    EMAIL_PASSWORD \
    WEB_SERVER

ENV MIX_ENV=prod \
    SECRET_KEY_BASE=$SECRET_KEY_BASE \
    SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
    SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
    LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
    TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
    SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
    SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
    SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
    CMS_DOMAIN_NAME=$CMS_DOMAIN_NAME \
    API_DOMAIN_NAME=$API_DOMAIN_NAME \
    CMS_PORT=$CMS_PORT \
    API_PORT=$API_PORT \
    PROTOCOL=$PROTOCOL \
    EMAIL_SYSTEM=$EMAIL_SYSTEM \
    EMAIL_DOMAIN=$EMAIL_DOMAIN \
    EMAIL_PORT=$EMAIL_PORT \
    EMAIL_SERVER=$EMAIL_SERVER \
    EMAIL_HOSTNAME=$EMAIL_HOSTNAME \
    EMAIL_USERNAME=$EMAIL_USERNAME \
    EMAIL_PASSWORD=$EMAIL_PASSWORD \
    WEB_SERVER=$WEB_SERVER

# Copy all application files
COPY . /app

RUN apk add --no-cache --virtual .build-deps inotify-tools make python2 erlang-dev alpine-sdk && apk add git

# Install and compile production dependecies
RUN  cd /app && \
        mix local.hex --force && \
        mix local.rebar --force && \
        mix deps.get --only prod && \
        MIX_ENV=prod mix do deps.compile, assets.deploy, phx.digest


# Clean Up
RUN apk del .build-deps && rm -rf deployment

# Run entrypoint.sh script
COPY deployment/docker/dockers/entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
