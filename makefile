.POSIX:
.SUFFIXES:

# Source code location of main program files.
SRC_MAIN  := main.c \
	cpu/fake6502.c \
	assembler/asm6f.c \
	machine/machine.c \
	apu/wsg.c \
	apu/nes_apu.c

# Source code location of minifb library.
SRC_MINIFB := \
	utils/MiniFB_prim.c \
    minifb/src/MiniFB_common.c \
    minifb/src/MiniFB_internal.c \
    minifb/src/MiniFB_timer.c

# Include directories.
INC_DIRS := \
	cpu \
	sokol \
	assembler \
	apu \
	utils \
	machine \
	utils \
	minifb/include \
	minifb/src

# Compiler and linker configuration.
CC             := gcc
CFLAGS         := -Wall -Wextra -pedantic
CFLAGS         += -DASM_LIB
CFLAGS         += -DNEW_APU
LDFLAGS        := -Os
RELEASE_CFLAGS := -DNDEBUG -O3
DEBUG_CFLAGS   := -DDEBUG -O1 -g

# Setup debug/release builds.
#     make clean && make <target> DEBUG=0
#     make clean && make <target> DEBUG=1
DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CFLAGS += $(DEBUG_CFLAGS)
else
    CFLAGS += $(RELEASE_CFLAGS)
endif

# OS specific options.
ifeq ($(OS),Windows_NT)
	EXT = .exe
	SRC_MINIFB += minifb/src/windows/WinMiniFB.c
	LDFLAGS += -l gdi32 -l ole32
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		CFLAGS += -DUSE_METAL_API
		SRC_MINIFB += $(wildcard minifb/src/macosx/*.m)
		INC_DIRS += minifb/macosx/
		LDFLAGS += -framework Cocoa \
				   -framework QuartzCore \
				   -framework Metal \
				   -framework MetalKit \
				   -framework AudioToolbox
	else ifeq ($(UNAME_S),Linux)
		SRC_MINIFB += $(wildcard minifb/src/x11/*.c)
		SRC_MINIFB += minifb/src/MiniFB_linux.c
		INC_DIRS += minifb/X11/
		LDFLAGS += -lX11 -pthread -lasound
	endif
endif

# Prepare objects and flags.
SRC := $(SRC_MAIN) $(SRC_MINIFB)
OBJ := $(SRC:.c=.o)
OBJ := $(OBJ:.m=.o)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))
CFLAGS += $(INC_FLAGS)

# Target rules.

.PHONY: clean

%.o: %.m
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

minicube$(EXT): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(OBJ)
