FROM --platform=$BUILDPLATFORM golang:1.23.4-alpine3.21 AS build
ARG TARGETPLATFORM
WORKDIR /go/src/github.com/robbertkl/docker-ipv6nat
COPY . .
RUN [ "$TARGETPLATFORM" = "linux/amd64"  ] && echo GOOS=linux GOARCH=amd64 > .env || true
RUN [ "$TARGETPLATFORM" = "linux/arm64"  ] && echo GOOS=linux GOARCH=arm64 > .env || true
RUN [ "$TARGETPLATFORM" = "linux/arm/v6" ] && echo GOOS=linux GOARCH=arm GOARM=6 > .env || true
RUN [ "$TARGETPLATFORM" = "linux/arm/v7" ] && echo GOOS=linux GOARCH=arm GOARM=7 > .env || true
ENV CGO_ENABLED=0
RUN go env -w GO111MODULE=auto
RUN env $(cat .env | xargs) go build -o /docker-ipv6nat.$(echo "$TARGETPLATFORM" | sed -E 's/(^linux|\/)//g') ./cmd/docker-ipv6nat

FROM alpine:3.21 AS release
RUN apk add --no-cache ip6tables
COPY --from=build /docker-ipv6nat.* /docker-ipv6nat
COPY docker-ipv6nat-compat /
ENTRYPOINT ["/docker-ipv6nat-compat"]
CMD ["--retry"]
