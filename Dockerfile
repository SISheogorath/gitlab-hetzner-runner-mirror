FROM docker.io/library/golang:1.25.0 as driver-builder

# renovate: datasource=git-tags depName=https://git.shivering-isles.com/github-mirror/JonasProgrammer/docker-machine-driver-hetzner.git
ARG HETZNER_VERSION=5.0.2

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN mkdir -p /go/src/app

WORKDIR /go/src/app

RUN git clone --depth 3 --branch "$HETZNER_VERSION" https://git.shivering-isles.com/github-mirror/JonasProgrammer/docker-machine-driver-hetzner.git ./

RUN go build -o docker-machine-driver-hetzner

FROM docker.io/gitlab/gitlab-runner:v18.2.2

# renovate: datasource=git-tags depName=https://gitlab.com/gitlab-org/ci-cd/docker-machine.git
ARG DOCKER_MACHINE_VERSION=v0.16.2-gitlab.40

LABEL maintainer="Sheogorath <sheogorath@shivering-isles.com>"

RUN true \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y sudo \
    && apt-get clean && apt-get purge && rm -r /var/lib/apt/lists/* \
    && true

COPY --from=driver-builder /go/src/app/docker-machine-driver-hetzner /usr/local/bin/

RUN curl "https://gitlab-docker-machine-downloads.s3.amazonaws.com/${DOCKER_MACHINE_VERSION}/docker-machine-Linux-x86_64" -o /usr/local/bin/docker-machine \
    && chmod +x /usr/local/bin/docker-machine
