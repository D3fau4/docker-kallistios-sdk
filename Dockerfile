########################################################################
# Dockerfile to build minimal KallistiOS Toolchain
########################################################################
FROM debian:stable-slim

# Install prerequisites
RUN apt update && \
	apt install -y build-essential git curl texinfo python3 subversion \
	libjpeg-dev libpng++-dev libgmp-dev libmpfr-dev \
	genisoimage p7zip-full cmake gawk patch bzip2 tar make \
	cmake pkg-config gettext wget bison flex sed meson ninja-build \
	diffutils python3 rake squashfs-tools libmpc-dev libelf-dev \
	libisofs-dev liblzo2-dev git libbz2-dev && \
	apt clean

RUN mkdir -p /opt/toolchains/dc && \
	chmod -R 755 /opt/toolchains/dc && \
	chown -R $(id -u):$(id -g) /opt/toolchains/dc

# Fetch sources
RUN git clone --depth=1 https://github.com/KallistiOS/KallistiOS /opt/toolchains/dc/kos && \
	git clone --recursive https://github.com/KallistiOS/kos-ports  /opt/toolchains/dc/kos-ports

# Setup KOS Environment
RUN cp /opt/toolchains/dc/kos/doc/environ.sh.sample /opt/toolchains/dc/kos/environ.sh && \
	echo 'source /opt/toolchains/dc/kos/environ.sh' >> /root/.bashrc

# Build Toolchain
WORKDIR /opt/toolchains/dc/kos/utils/dc-chain
RUN cp Makefile.dreamcast.cfg Makefile.cfg && \
	make -j && \
	make clean distclean
WORKDIR /opt/toolchains/dc/kos/utils/kmgenc 
RUN bash -c 'source /opt/toolchains/dc/kos/environ.sh; make'

# Build KOS
WORKDIR /opt/toolchains/dc/kos
RUN bash -c 'source /opt/toolchains/dc/kos/environ.sh; make'

# Build KOS-/Ports
WORKDIR /opt/toolchains/dc/kos
RUN bash -c 'source /opt/toolchains/dc/kos/environ.sh; bash /opt/toolchains/dc/kos-ports/utils/build-all.sh'

# Volume to compile project sourcecode
VOLUME /src
WORKDIR /src
COPY ./run.sh /run.sh
ENTRYPOINT [ "/run.sh" ]
CMD [ "make" ]
