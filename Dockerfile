FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # build
    git gcc g++ make cmake \
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
    less curl \
    && rm -rf /var/lib/apt/lists/*

# pwntools & frida
RUN pipx install pwntools frida-tools && pipx ensurepath

# pwndbg (GDB plugin)
RUN git clone --depth=1 https://github.com/pwndbg/pwndbg.git /opt/pwndbg \
    && cd /opt/pwndbg && ./setup.sh

WORKDIR /work

CMD ["bash"]
