# docker run -it --rm --net=host -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro -v ~/virt/docker/volumes/signal-desktop:/signal rexypoo/signal-desktop
FROM ubuntu AS build
ADD https://updates.signal.org/desktop/apt/keys.asc /signal/keys.asc
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    libx11-xcb1 \
 && apt-key add /signal/keys.asc \
 && echo \
    "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" \
  > /etc/apt/sources.list.d/signal-xenial.list \
 && apt-get update && apt-get install -y \
    signal-desktop \
 && apt-get purge -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/*

FROM build AS drop-privileges
ENV USER=signal
ENV UID=58658
ENV GID=$UID
WORKDIR "/$USER"
ENV TEMPLATE="$(pwd)"/.config/Signal

RUN mkdir -p "$TEMPLATE" \
 && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "$UID" \
    "$USER" \
 && chown $USER:$USER .

VOLUME "/$USER"

ADD https://raw.githubusercontent.com/Rexypoo/docker-entrypoint-helper/master/entrypoint-helper.sh /usr/local/bin/entrypoint-helper.sh
RUN chmod u+x /usr/local/bin/entrypoint-helper.sh
ENTRYPOINT ["entrypoint-helper.sh","signal-desktop"]

FROM drop-privileges AS dev
ENTRYPOINT ["/bin/bash"]

FROM drop-privileges AS release

LABEL org.opencontainers.image.url="https://hub.docker.com/r/rexypoo/signal-desktop" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/rexypoo/signal-desktop" \
      org.opencontainers.image.source="https://github.com/Rexypoo/docker-signal-desktop" \
      org.opencontainers.image.version="0.1a" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="ubuntu" \
      org.opencontainers.image.description="Signal-desktop on Docker" \
      org.opencontainers.image.title="rexypoo/signal-desktop" \
      org.label-schema.docker.cmd='mkdir -p "$HOME"/.signal-desktop && \
      docker run -d --rm \
      --name signal-desktop \
      --net=host \
      -e DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
      -v "$HOME"/.signal-desktop:/signal \
      rexypoo/signal-desktop' \
      org.label-schema.docker.cmd.devel="docker run -it --rm --entrypoint bash rexypoo/signal-desktop" \
      org.label-schema.docker.cmd.debug="docker exec -it signal-desktop bash"
