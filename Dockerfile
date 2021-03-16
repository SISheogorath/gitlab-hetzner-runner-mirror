FROM docker.io/gitlab/gitlab-runner:v13.9.0

LABEL maintainer="Sheogorath <sheogorath@shivering-isles.com>"
# renovate: datasource=github-tags depName=JonasProgrammer/docker-machine-driver-hetzner
ARG HETZNER_VERSION=3.3.0
ARG HETZNER_HASH=103b9643da895b97fa51c91f843d9be4eced345264ff7e6e91f4e7778e0f56c2


RUN true \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y sudo \
    && apt-get clean && apt-get purge && rm -r /var/lib/apt/lists/* \
    && true

RUN true \
    && wget "https://github.com/JonasProgrammer/docker-machine-driver-hetzner/releases/download/${HETZNER_VERSION}/docker-machine-driver-hetzner_${HETZNER_VERSION}_linux_amd64.tar.gz" \
    && echo "${HETZNER_HASH} docker-machine-driver-hetzner_${HETZNER_VERSION}_linux_amd64.tar.gz" > check_file \
    && sha256sum -c check_file \
    && tar -xvf "docker-machine-driver-hetzner_${HETZNER_VERSION}_linux_amd64.tar.gz" \
    && rm "docker-machine-driver-hetzner_${HETZNER_VERSION}_linux_amd64.tar.gz" check_file \
    && chmod +x docker-machine-driver-hetzner \
    && mv docker-machine-driver-hetzner /usr/local/bin/ \
    && true
