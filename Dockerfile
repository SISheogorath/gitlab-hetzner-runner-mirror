FROM docker.io/gitlab/gitlab-runner:v12.9.0

LABEL maintainer="Sheogorath <sheogorath@shivering-isles.com>"
ARG HETZNER_VERSION=1.2.2
ARG HETZNER_HASH=cd477aabb0d31937a2568c3f0d362f578790e0cbddd0c2b144145a1c597b5c60


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
