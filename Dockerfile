FROM debian:bookworm AS mkdcdisc-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    build-essential pkg-config \
    meson ninja-build \
    libisofs-dev \
 && rm -rf /var/lib/apt/lists/*

# Puedes fijar una versión concreta (recomendado) pasando --build-arg MKDCDISC_REF=<commit|tag>
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

RUN apt-get update && apt-get install -y --no-install-recommends \
    libisofs6 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=mkdcdisc-builder /src/mkdcdisc/builddir/mkdcdisc /usr/local/bin/mkdcdisc