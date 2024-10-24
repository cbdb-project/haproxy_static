# syntax=docker.io/docker/dockerfile-upstream:1.2.0
FROM quay.io/oopus/haproxy_static:alpine AS haproxy_uploader
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG haproxy_latest_tag_name=2.4.0
COPY got_github_release.sh /tmp/got_github_release.sh
WORKDIR "/git/haproxy_static"
# import secret:
RUN --mount=type=secret,id=GIT_AUTH_TOKEN,dst=/tmp/secret_token export GITHUB_TOKEN="$(cat /tmp/secret_token)" \
    && bash /tmp/got_github_release.sh \
    && git clone -j "$(nproc)" "https://IceCodeNew:${GITHUB_TOKEN}@github.com/cbdb-project/haproxy_static.git" "/git/haproxy_static" \
    && git config --global user.email "32576256+IceCodeNew@users.noreply.github.com" \
    && git config --global user.name "IceCodeNew" \
    && git fetch origin --prune --prune-tags \
    && git remote -v; \
    echo '' \
    && echo '$$$$$$$$ github-release $$$$$$$$' \
    && echo '' \
    && set -x; \
    grep -Fq "v${haproxy_latest_tag_name}" <(git tag) \
    && github-release delete \
    --user cbdb-project \
    --repo haproxy_static \
    --tag "v${haproxy_latest_tag_name}" \
    && git push origin -d "v${haproxy_latest_tag_name}" \
    && git tag -d "v${haproxy_latest_tag_name}"; \
    git tag -a "v${haproxy_latest_tag_name}" -m "v${haproxy_latest_tag_name}" "$(git rev-parse --short origin/release)" \
    && git push origin "v${haproxy_latest_tag_name}" \
    && < <(echo 'The released deb packages had been tested on Ubuntu 18.04 & Debian 9.' && echo 'It is recommended to initiate a Systemd drop-in file for the haproxy that supports the sdnotify features of systemd, just issue command:' && echo '`mkdir -p "/etc/systemd/system/haproxy.service.d" && echo -e "[Service]\nRestartSec=6" > "/etc/systemd/system/haproxy.service.d/haproxy.conf"`' && echo 'For the haproxy that **DOES NOT** support the sdnotify features of systemd, issue command:' && echo '`mkdir -p "/etc/systemd/system/haproxy.service.d" && echo -e "[Service]\nExecStart=\nExecStart=/usr/local/sbin/haproxy -W -f $CONFIG -p $PIDFILE $EXTRAOPTS\nType=\nType=forking\nRestartSec=6" > "/etc/systemd/system/haproxy.service.d/haproxy.conf"`') \
    github-release release \
    --user cbdb-project \
    --repo haproxy_static \
    --tag "v${haproxy_latest_tag_name}" \
    --description - \
    && sleep 3s \
    && github-release upload \
    --user cbdb-project \
    --repo haproxy_static \
    --tag "v${haproxy_latest_tag_name}" \
    --name "haproxy" \
    --file "/haproxy"
