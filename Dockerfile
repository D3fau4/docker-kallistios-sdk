########################################################################
# Dockerfile to build mkdcdisc (Dreamcast disc image creation tool)
########################################################################
FROM debian:bookworm AS mkdcdisc-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    build-essential pkg-config \
    meson ninja-build \
    libisofs-dev \
 && rm -rf /var/lib/apt/lists/*

ARG MKDCDISC_REF=main

RUN git clone https://gitlab.com/simulant/mkdcdisc.git /src/mkdcdisc \
 && cd /src/mkdcdisc \
 && git checkout "${MKDCDISC_REF}" \
 && meson setup builddir \
 && meson compile -C builddir

########################################################################
# Dockerfile to build KallistiOS Toolchain + Additional Dreamcast Tools
########################################################################
FROM ghcr.io/d3fau4/kallistios-sdk:minimal

# Build and install SDL2 for Dreamcast
WORKDIR /usr/local/src
RUN git clone --recursive https://github.com/GPF/SDL.git -b dreamcastSDL2 && \
    cd SDL/build-scripts && \
    bash -c 'source /opt/toolchains/dc/kos/environ.sh; ./dreamcast.sh' && \
    rm -rf /usr/local/src/SDL

COPY --from=mkdcdisc-builder /src/mkdcdisc/builddir/mkdcdisc /usr/local/bin/mkdcdisc

WORKDIR /src