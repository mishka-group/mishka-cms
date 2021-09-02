# Extend from the official Elixir image
FROM elixir:1.12.2-alpine

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
    DOMAIN_NAME

ENV MIX_ENV=prod \
    SECRET_KEY_BASE=$SECRET_KEY_BASE \
    SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
    SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
    LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
    TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
    SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
    SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
    SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
    DOMAIN_NAME=$DOMAIN_NAME

# Copy all application files
COPY . /app

RUN apk add --no-cache --virtual .build-deps git inotify-tools make python2 erlang-dev  alpine-sdk

# Install and compile production dependecies
RUN if [[ "$MIX_ENV" == "prod" ]]; then \
        cd /app && \
        mix local.hex --force && \
        mix local.rebar --force && \
        mix deps.get --only prod; \
    else \
        cd /app && \
        mix deps.get; \
    fi

RUN cd /app &&  mix deps.compile &&  mix assets.deploy


# Clean Up
RUN apk del .build-deps

# Run entrypoint.sh script
RUN chmod +x entrypoint.sh
CMD ["/app/entrypoint.sh"]