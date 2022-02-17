FROM node:16-alpine3.15

## Compatibility for glibc
RUN apk --no-cache add gcompat

## Compatibility for libstdc++
RUN apk --no-cache add libstdc++

## OpenJDK
RUN apk --no-cache add openjdk11-jre-headless

## The following are just for debugging the container
RUN apk --no-cache add bash curl

ARG FIREBASE_TOOLS_VERSION="v10.2.0"

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

COPY firebase.json .

COPY .firebaserc .

LABEL org.opencontainers.image.description=Firebase firestore emulator for CI

ARG FIRESTORE_PORT=8080
ARG AUTH_PORT=9099

EXPOSE ${FIRESTORE PORT} ${AUTH_PORT}

HEALTHCHECK --interval=15s --timeout=5s \
	CMD curl -fs http://localhost:${AUTH_PORT} || curl -fs http://localhost:${FIRESTORE_PORT} || exit 1

ENTRYPOINT ["firebase"]

CMD ["emulators:start"]
