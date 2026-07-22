FROM bats/bats:1.14.0

USER root

RUN apk add --no-cache \
        bash \
        coreutils \
        curl \
        docker-cli-compose \
        gawk \
        sed \
        sudo \
    && adduser -D -s /bin/bash tester \
    && printf 'tester ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/tester \
    && chmod 0440 /etc/sudoers.d/tester

WORKDIR /repo

COPY --chown=tester:tester src/ /repo/src/
COPY --chown=tester:tester tests/ /repo/tests/

RUN chmod +x /repo/tests/bin/curl /repo/tests/bin/docker /repo/tests/bin/hostname /repo/tests/ci

USER tester

ENV HOME=/home/tester USER=tester

ENTRYPOINT ["/repo/tests/ci"]
