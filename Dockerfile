FROM crystallang/crystal:1.0.0-alpine-build as build

WORKDIR /build

COPY shard.yml /build/
COPY shard.lock /build/
RUN mkdir src
COPY ./src /build/src

RUN mkdir data

RUN shards
RUN crystal build src/pad.cr --release --static -o pad

# prod
FROM alpine:3

WORKDIR /app
COPY --from=build /build/pad /app/pad

EXPOSE 3000
CMD ["/app/pad"]