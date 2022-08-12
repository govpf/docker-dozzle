# Build assets
FROM govpf/node:16 as node
#FROM test_node18 as node

# RUN git clone --depth 1 --branch v3.13.1 https://github.com/amir20/dozzle.git 
RUN git clone --depth 1 --branch v3.13.1 https://github.com/amir20/dozzle.git 

RUN cd dozzle

RUN npm install -g pnpm

RUN mkdir /build && cd build

# Install dependencies from lock file
RUN cp /dozzle/pnpm-lock.yaml .
RUN pnpm fetch --prod

# Copy files
RUN cp /dozzle/package.json /build
RUN cp /dozzle/*.* /build
RUN cp /dozzle/vite.config.ts /build
RUN cp /dozzle/index.html /build

# Copy assets to build
RUN cp -r /dozzle/assets /build/assets

# Install dependencies
RUN cd /build && pnpm install -r --offline --prod --ignore-scripts && pnpm build

FROM golang:1.19.0-alpine AS builder

RUN apk add --no-cache ca-certificates && mkdir /dozzle

WORKDIR /dozzle

# Copy go mod files
COPY --from=node /dozzle/go.* ./
RUN go mod download

# Copy assets built with node
COPY --from=node /build/dist /dozzle/dist

# Copy all other files
COPY --from=node /dozzle/analytics ./analytics
COPY --from=node /dozzle/healthcheck ./healthcheck
COPY --from=node /dozzle/docker ./docker
COPY --from=node /dozzle/web ./web
COPY --from=node /dozzle/main.go ./

# Args
ARG TAG=v3.13.1
ARG TARGETOS TARGETARCH

# Build binary
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -ldflags "-s -w -X main.version=$TAG"  -o dozzle


FROM scratch

ENV PATH /bin

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /dozzle/dozzle /dozzle

EXPOSE 8080

ENTRYPOINT ["/dozzle"]
