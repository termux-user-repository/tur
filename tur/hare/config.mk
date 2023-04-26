## Install configuration

# PREFIX = $(TERMUX_PREFIX)
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
SRCDIR = $(PREFIX)/src

# Where to install the stdlib tree
STDLIB = $(SRCDIR)/hare/stdlib

# Default HAREPATH
HAREPATH = $(SRCDIR)/hare/stdlib:$(SRCDIR)/hare/third-party

## Build configuration

# Platform to build for
PLATFORM = linux
# ARCH = x86_64

# Where to store build artifacts
HARECACHE = .cache
BINOUT = .bin

# External tools and flags
HAREC = harec
HAREFLAGS?=
QBE = qbe
QBEFLAGS?=
AS = as
LD = ld
AR = ar
SCDOC = scdoc
HOST_HARE = $(BINOUT)/hare
HAREBUILDFLAGS?=

# Cross-compiler toolchains
AARCH64_AS=aarch64-linux-android-as
AARCH64_AR=aarch64-linux-android-ar
AARCH64_CC=aarch64-linux-android-cc
AARCH64_LD=aarch64-linux-android-ld

RISCV64_AS=riscv64-linux-android-as
RISCV64_AR=riscv64-linux-android-ar
RISCV64_CC=riscv64-linux-android-cc
RISCV64_LD=riscv64-linux-android-ld

X86_64_AS=x86-64-linux-android-as
X86_64_AR=x86-64-linux-android-ar
X86_64_CC=x86-64-linux-android-cc
X86_64_LD=x86-64-linux-android-ld
