FROM docker.io/gitlab/gitlab-runner:v13.2.2

LABEL maintainer="Sheogorath <sheogorath@shivering-isles.com>"
ARG HETZNER_VERSION=2.1.0
ARG HETZNER_HASH=927b3ecaa939e0aac5913a7bc31e7aeab3a31575ad0d2c42645b52b66810b3fd


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
