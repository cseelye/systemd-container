FROM ubuntu:22.04

# Setup systemd in the container
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install --yes --no-install-recommends ssh systemd && \
    apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN echo exit 0 > /usr/sbin/policy-rc.d && \
    rm /etc/systemd/system/multi-user.target.wants/ssh.service /etc/systemd/system/sshd.service

STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/lib/systemd/systemd"]

# Install docker client
RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    . /etc/os-release && \
    mkdir -p /etc/apt/sources.list.d && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        docker-ce-cli \
    && \
    apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/dpkg*

# Install the files for the test service
RUN --mount=type=bind,source=.,target=/mnt \
    mkdir -p /etc/myservices /usr/local/bin /etc/systemd/system && \
    cp /mnt/test_service /etc/myservices/test_service && \
    cp /mnt/run-test_service /usr/local/bin/run-test_service && \
    cp /mnt/test_service.service /etc/systemd/system/test_service.service && \
    ln -s /etc/systemd/system/test_service.service /etc/systemd/system/multi-user.target.wants/test_service.service
