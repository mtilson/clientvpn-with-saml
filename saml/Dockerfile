FROM umputun/baseimage:buildgo-latest as build-saml

ENV TIME_ZONE=Etc/UTC
RUN \
    echo "${TIME_ZONE}" > /etc/timezone && \
    cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

WORKDIR /build
ADD . /build

RUN go fmt ./...
RUN go test -mod=vendor ./...
RUN golangci-lint run --out-format=tab --tests=false ./...

RUN \
    revison=$(/script/git-rev.sh) && \
    echo "revision=${revison}" && \
    go build -mod=vendor -o app -ldflags "-X main.revision=$revison -s -w" .


FROM alpine:latest

COPY --from=build-saml /build/app /srv/saml-wrapper
EXPOSE 35001
WORKDIR /srv

CMD ["/srv/saml-wrapper"]
