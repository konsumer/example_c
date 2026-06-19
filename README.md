# Learning C

Work through tutorial examples here (for example [this](https://www.techcrashcourse.com/2014/10/c-program-examples.html).) Each `.c` file in `src/` builds into its own program automatically.

## Install Tools

### macOS

```sh
xcode-select --install
brew install cmake
```

### Linux — Debian/Ubuntu

```sh
sudo apt update
sudo apt install build-essential cmake
```

### Linux — Fedora/RHEL/CentOS

```sh
sudo dnf install gcc cmake make
```

### Linux — Arch

```sh
sudo pacman -S gcc cmake make
```

### Windows

Install [Visual Studio](https://visualstudio.microsoft.com/downloads/) (Community is free — check "Desktop development with C++"), then install [CMake](https://cmake.org/download/).

Or use [MSYS2](https://www.msys2.org/):
```sh
pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake
```

## Build

```sh
cmake -B build
cmake --build build --parallel
```

Binaries land in `build/`. Run one:

```sh
# macOS / Linux
./build/test1

# Windows
.\build\Debug\test1.exe
```

## Debug

Binaries are built with debug symbols by default. Use `gdb` (Linux) or `lldb` (macOS).

### Install debugger

**Debian/Ubuntu**
```sh
sudo apt install gdb
```

**Fedora/RHEL**
```sh
sudo dnf install gdb
```

**Arch**
```sh
sudo pacman -S gdb
```

**macOS** — `lldb` ships with Xcode tools (already installed above). `gdb` available via `brew install gdb` but lldb works fine.

### GDB basics

```sh
gdb ./build/test1
```

| Command | What it does |
|---|---|
| `run` | Start the program |
| `break main` | Breakpoint at `main` |
| `break file.c:12` | Breakpoint at line 12 |
| `next` / `n` | Step over (next line) |
| `step` / `s` | Step into function |
| `print x` | Print variable `x` |
| `x/16xb ptr` | Dump 16 bytes at `ptr` in hex |
| `info registers` | Show all CPU registers |
| `backtrace` / `bt` | Show call stack |
| `disassemble` | Show assembly for current function |
| `quit` | Exit |

### LLDB basics (macOS)

```sh
lldb ./build/test1
```

| Command | What it does |
|---|---|
| `run` | Start the program |
| `b main` | Breakpoint at `main` |
| `n` | Step over |
| `s` | Step into |
| `p x` | Print variable `x` |
| `memory read -fx -c16 ptr` | Dump 16 bytes at `ptr` in hex |
| `register read` | Show CPU registers |
| `bt` | Show call stack |
| `di` | Disassemble current function |
| `q` | Exit |

### Release build (no debug symbols, optimized)

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

### Memory errors — Valgrind (Linux)

```sh
sudo apt install valgrind   # Debian/Ubuntu
sudo dnf install valgrind   # Fedora
sudo pacman -S valgrind     # Arch

valgrind --leak-check=full ./build/test1
```

### Static analysis — AddressSanitizer (fast, no extra install)

```sh
cmake -B build -DCMAKE_C_FLAGS="-fsanitize=address,undefined"
cmake --build build --parallel
./build/test1   # crashes loudly on bad memory access with a full report
```

## Docker Environment

Pre-built environment with all tools: gcc, gdb, valgrind, strace, ltrace, radare2, checksec, pwntools, pwndbg, & frida. Works on any OS including Windows.

### Build image

```sh
docker build -t learn-c .
```

### Run (mounts current directory)

```sh
# Linux / macOS / Windows
docker run -it --rm -v .:/work learn-c
```

Source files and built binaries are live-synced — edit on host, build/run inside container.

### Build and run inside container

```sh
cmake -B build
cmake --build build --parallel
./build/test1
```

### Debug inside container

```sh
gdb ./build/test1
# pwndbg loads automatically — extra commands: heap, vmmap, cyclic, checksec
```

### Notes

- Container runs as root — `sudo` not needed
- `--rm` deletes container on exit, `/work` volume keeps your files safe
- Add `--privileged` if `strace` complains about permissions:
  ```sh
  docker run -it --rm --privileged -v .:/work learn-c
  ```

## Add a New Example

Drop a `.c` file in `src/` and rebuild — no other changes needed.

```sh
# example: create src/pointers.c, then:
cmake --build build --parallel
./build/pointers
```
