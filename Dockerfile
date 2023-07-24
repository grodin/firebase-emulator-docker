FROM node:16-alpine3.15

## Compatibility for glibc
RUN apk --no-cache add gcompat

## Compatibility for libstdc++
RUN apk --no-cache add libstdc++

## OpenJDK
RUN apk --no-cache add openjdk11-jre-headless

## The following are just for debugging the container
RUN apk --no-cache add bash curl

ARG FIREBASE_TOOLS_VERSION="v12.4.5"

RUN npm install -g firebase-tools@${FIREBASE_TOOLS_VERSION}

# Suppress npm update announcements
RUN npm config set update-notifier false

ENV USER=firebase-emulator

## Create user
RUN addgroup -g 1010 ${USER} \
    && adduser --uid 1010 --ingroup ${USER} --disabled-password ${USER}

USER ${USER}

WORKDIR /home/${USER}

RUN firebase setup:emulators:firestore
RUN firebase setup:emulators:ui

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
