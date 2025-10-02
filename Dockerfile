# syntax=docker/dockerfile:1

# Skip the below Docker check
# The AUTH_PORT is not a secret
# check=skip=SecretsUsedInArgOrEnv

ARG USER=firebase-emulator

FROM node:22-alpine3.21 AS build

## Update apk index
RUN apk update && \
    ## Compatibility for glibc
    apk --no-cache add gcompat \
    ## Compatibility for libstdc++
    libstdc++ \
    ## OpenJDK
    openjdk21-jre-headless \
    ## The following are just for debugging the container
    bash curl

# renovate: datasource=npm depName=firebase-tools
ARG FIREBASE_TOOLS_VERSION=14.18.0

RUN npm install -g firebase-tools@${FIREBASE_TOOLS_VERSION}

# Suppress npm update announcements
RUN npm config set update-notifier false

ARG USER
ENV USER=${USER}

## Create user
RUN addgroup -g 1010 ${USER} \
    && adduser --uid 1010 --ingroup ${USER} --disabled-password ${USER}

USER ${USER}

WORKDIR /home/${USER}

RUN firebase setup:emulators:firestore && \
    firebase setup:emulators:ui

FROM build

ARG USER

USER ${USER}

WORKDIR /home/${USER}

COPY --from=build /home/${USER} /home/${USER}

COPY --chown=${USER}:${USER} src/* ./

LABEL "org.opencontainers.image.description"="Firebase firestore emulator for CI"

ARG FIRESTORE_PORT=8080
ENV FIRESTORE_PORT=${FIRESTORE_PORT}

ARG AUTH_PORT=9099
ENV AUTH_PORT=${AUTH_PORT}

ARG UI_PORT=4000
ENV UI_PORT=${UI_PORT}

ARG UI_WEBSOCKET_PORT=9150
ENV UI_WEBSOCKET_PORT=${UI_WEBSOCKET_PORT}

ARG UI_LOGGING_PORT=4500
ENV UI_LOGGING_PORT=${UI_LOGGING_PORT}

ENV HUB_PORT=4040

EXPOSE ${FIRESTORE_PORT}
EXPOSE ${AUTH_PORT}
EXPOSE ${UI_PORT}
EXPOSE ${UI_WEBSOCKET_PORT}
EXPOSE ${UI_LOGGING_PORT}
EXPOSE ${HUB_PORT}

HEALTHCHECK --interval=20s --timeout=15s \
	CMD ./healthcheck.sh

ENTRYPOINT ["firebase"]

CMD ["emulators:start"]
