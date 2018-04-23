FROM golang:alpine AS build-env

ARG pkg=webhook-resource

COPY . $GOPATH/src/$pkg

RUN set -ex \
      && apk add --no-cache --virtual .build-deps \
              git \
              ca-certificates \
      && go get -v $pkg/... \
      && apk del .build-deps

RUN go install $pkg/...

FROM alpine

RUN mkdir -p /opt/resource
COPY --from=build-env /go/bin/check /opt/resource/
COPY --from=build-env /go/bin/in /opt/resource/
COPY --from=build-env /go/bin/out /opt/resource/

CMD echo "This container is not used directly."; exit 1