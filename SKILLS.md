# LLM Skills Reference — C / Debugging / Reverse Engineering

This file gives an AI assistant context for helping with C programming, debugging, and binary analysis tasks in a cybersecurity/pentesting learning context.

## Project layout

```
src/       — C source files (one program per file)
build/     — compiled binaries (Debug by default, symbols included)
```

Build: `cmake -B build && cmake --build build --parallel`

---

## Common tasks

### Explain a crash or segfault

Ask: _"This crashes with a segfault — what's wrong?"_ then paste the source and/or gdb output.

Useful gdb output to include:
```
bt          # backtrace
info registers
x/32xb $sp  # stack bytes
```

### Explain assembly output

Ask: _"Explain this assembly"_ then paste `disassemble` output from gdb/lldb, or:
```sh
objdump -d -M intel ./build/test1
```

### Find strings in a binary

```sh
strings ./build/test1
strings -n 8 ./build/test1   # min length 8
```

### Inspect symbols

```sh
nm ./build/test1              # all symbols
nm -D ./build/test1           # dynamic symbols only
readelf -s ./build/test1      # ELF symbol table (Linux)
```

### Trace system calls

```sh
strace ./build/test1          # Linux — every syscall
dtruss ./build/test1          # macOS (needs sudo)
```

### Trace library calls

```sh
ltrace ./build/test1          # Linux — libc calls
```

### Inspect ELF structure (Linux)

```sh
readelf -h ./build/test1      # ELF header
readelf -S ./build/test1      # section headers
readelf -l ./build/test1      # program headers / segments
file ./build/test1            # quick summary
```

### Check memory layout at runtime (Linux)

```sh
cat /proc/$(pgrep test1)/maps
```

Inside gdb:
```
info proc mappings
```

### Shared library dependencies

```sh
ldd ./build/test1             # Linux
otool -L ./build/test1        # macOS
```

### Patch/inspect bytes

```sh
xxd ./build/test1 | head -40          # hex dump
xxd ./build/test1 > patch.hex         # dump to file
# edit patch.hex, then:
xxd -r patch.hex ./build/test1_patched
```

---

## Memory concepts to know

| Term | Meaning |
|---|---|
| Stack | Local variables, function call frames. Grows down. |
| Heap | `malloc`/`free` memory. Grows up. |
| BSS | Uninitialized globals |
| `.data` | Initialized globals |
| `.text` | Executable code |
| `$rsp` / `$esp` | Stack pointer register (x86-64 / x86) |
| `$rbp` / `$ebp` | Base pointer — frame reference |
| `$rip` / `$eip` | Instruction pointer — current execution address |

---

## Classic C vulnerability patterns (educational)

These are the bugs that appear in CTF challenges and real CVEs. Understand them to write safer code and recognize them in the wild.

### Buffer overflow

```c
char buf[16];
gets(buf);          // never use gets() — no bounds check
strcpy(buf, input); // dangerous if input > 15 bytes
```

Safe alternatives: `fgets(buf, sizeof(buf), stdin)`, `strncpy`, `snprintf`.

### Format string bug

```c
printf(user_input);         // dangerous — user controls format
printf("%s", user_input);   // safe
```

An attacker can use `%x %x %x` to read stack values, or `%n` to write.

### Integer overflow

```c
size_t len = user_value;
char *buf = malloc(len + 1);  // if len = SIZE_MAX, len+1 wraps to 0
```

### Use-after-free

```c
free(ptr);
printf("%s", ptr);  // undefined behavior — ptr is dangling
ptr = NULL;         // always null after free
```

### Off-by-one

```c
char buf[8];
for (int i = 0; i <= 8; i++)  // writes buf[8] — one past end
    buf[i] = 'A';
```

---

## GDB one-liners

```sh
# Run with args
gdb --args ./build/prog arg1 arg2

# Run and hit breakpoint automatically
gdb -ex 'b main' -ex 'run' ./build/prog

# Pipe input
echo "AAAAAAAAAA" | gdb -ex 'run' ./build/prog

# Core dump analysis
gdb ./build/prog core

# Generate core on crash (Linux, run before the program)
ulimit -c unlimited
```

## GDB pretty-print structs

```
set print pretty on
p *my_struct_ptr
```

---

## Useful tools (install separately)

| Tool | Purpose | Install |
|---|---|---|
| `gdb` | Debugger | `apt install gdb` / `pacman -S gdb` |
| `valgrind` | Memory error detector | `apt install valgrind` |
| `pwndbg` | GDB plugin for exploit dev | [github.com/pwndbg/pwndbg](https://github.com/pwndbg/pwndbg) |
| `pwntools` | CTF exploit framework (Python) | `pip install pwntools` |
| `ghidra` | NSA decompiler, free | [ghidra-sre.org](https://ghidra-sre.org) |
| `radare2` | CLI reverse engineering suite | `apt install radare2` |
| `binwalk` | Firmware/binary extraction | `apt install binwalk` |
| `checksec` | Show binary protections | `apt install checksec` |

### checksec output explained

```sh
checksec --file=./build/test1
```

| Protection | What it does |
|---|---|
| RELRO | Makes GOT read-only after startup |
| Stack Canary | Detects stack smashing |
| NX | Non-executable stack (no shellcode on stack) |
| PIE | Position-independent binary (ASLR-friendly) |
| ASLR | Kernel randomizes load addresses (check: `cat /proc/sys/kernel/randomize_va_space`) |
