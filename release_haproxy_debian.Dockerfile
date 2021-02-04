# syntax=docker.io/docker/dockerfile-upstream:1.2.0
FROM quay.io/icecodenew/haproxy_static:debian AS haproxy_uploader
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG haproxy_branch=2.2
ARG haproxy_latest_tag_name=2.2.4
ARG jemalloc_latest_tag_name='5.2.1'
COPY got_github_release.sh /tmp/got_github_release.sh
WORKDIR "/git/haproxy_static"
# import secret:
RUN --mount=type=secret,id=GIT_AUTH_TOKEN,dst=/tmp/secret_token export GITHUB_TOKEN="$(cat /tmp/secret_token)" \
    && bash /tmp/got_github_release.sh \
    # && github-release delete \
    # --user IceCodeNew \
    # --repo haproxy_static \
    # --tag "v${haproxy_latest_tag_name}"; \
    # git clone -j "$(nproc)" "https://IceCodeNew:${GITHUB_TOKEN}@github.com/IceCodeNew/haproxy_static.git" "/git/haproxy_static"; \
    # git fetch origin --prune --prune-tags; \
    # git push origin -d "v${haproxy_latest_tag_name}"; \
    # github-release release \
    # --user IceCodeNew \
    # --repo haproxy_static \
    # --tag "v${haproxy_latest_tag_name}" \
    # --name "v${haproxy_latest_tag_name}" \
    # --target release; \
    && github-release upload \
    --user IceCodeNew \
    --repo haproxy_static \
    --tag "v${haproxy_latest_tag_name}" \
    --name "haproxy_${haproxy_latest_tag_name}-1_amd64.deb" \
    --file "/build_root/haproxy-${haproxy_branch}/haproxy_${haproxy_latest_tag_name}-1_amd64.deb"; \
    github-release upload \
    --user IceCodeNew \
    --repo haproxy_static \
    --tag "v${haproxy_latest_tag_name}" \
    --name "jemalloc_${jemalloc_latest_tag_name}-dev-1_amd64.deb" \
    --file "/build_root/haproxy-${haproxy_branch}/jemalloc_${jemalloc_latest_tag_name}-dev-1_amd64.deb"
