FROM alpine:3.15

## Compatibility for glibc
RUN apk --no-cache add gcompat

## Compatibility for libstdc++
RUN apk --no-cache add libstdc++

## OpenJDK
RUN apk --no-cache add openjdk11-jre-headless

## The following are just for debugging the container
RUN apk --no-cache add bash curl

ENV USER=firebase-emulator

## Create user
RUN addgroup -g 1010 ${USER} \
    && adduser --uid 1010 --ingroup ${USER} --disabled-password ${USER}

USER ${USER}

ARG FIREBASE_TOOLS_VERSION="v10.2.0"

RUN mkdir -p ${HOME}/firebase-tools

WORKDIR /home/${USER}/firebase-tools

RUN curl -L https://github.com/firebase/firebase-tools/releases/download/${FIREBASE_TOOLS_VERSION}/firebase-tools-linux -o firebase \
    && chmod +x firebase

ENV PATH=/home/${USER}/firebase-tools:${PATH}

WORKDIR /home/${USER}

ENTRYPOINT ["firebase"]

CMD ["--version"]
