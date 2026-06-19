FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # build
    gcc g++ make cmake \
    # debug
    gdb valgrind \
    # tracing & inspection
    strace ltrace \
    binutils file xxd \
    # security tools
    checksec \
    radare2 \
    # python + pwntools
    python3 python3-pip pipx \
    # quality of life
    less vim curl git \
    && rm -rf /var/lib/apt/lists/*

# pwntools
RUN pipx install pwntools && pipx ensurepath

# pwndbg (GDB plugin)
RUN git clone --depth=1 https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg && ./setup.sh --quiet

WORKDIR /work

CMD ["bash"]
