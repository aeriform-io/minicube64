
CC = gcc

# general flags

CFLAGS = -DASM_LIB 
CFLAGS += -DNES_APU 
CFLAGS += -I cpu
CFLAGS += -I sokol
CFLAGS += -I assembler
CFLAGS += -I apu
CFLAGS += -I utils
CFLAGS += -I machine 
CFLAGS += -I machine 
CFLAGS += -I minifb/include 
CFLAGS += -I minifb/src
# files to link

OBJ = main.o 
OBJ += cpu/fake6502.o 
OBJ += assembler/asm6f.o 
OBJ += machine/machine.o 
OBJ += apu/wsg.o 
OBJ += apu/nes_apu.o 
OBJ += utils/MiniFB_prim.o 
OBJ += minifb/src/MiniFB_common.o
OBJ += minifb/src/MiniFB_internal.o
OBJ += minifb/src/MiniFB_timer.o

# link flags 

LDFLAGS = -Os

# OS SPECIFIC 

ifeq ($(OS),Windows_NT)
	EXT = .exe
	OBJ += minifb/src/windows/WinMiniFB.o 
	LDFLAGS += -l gdi32 -l ole32
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		CFLAGS += -DUSE_METAL_API
		OBJ += minifb/src/macosx/OSXView.m.o
		OBJ += minifb/src/macosx/OSXViewDelegate.m.o 
		OBJ += minifb/src/macosx/OSXWindow.m.o
		OBJ += minifb/src/macosx/MacMiniFB.m.o
		CFLAGS += -I minifb/macosx
		LDFLAGS += -framework Cocoa -framework QuartzCore -framework Metal -framework MetalKit -framework AudioToolbox
	else ifeq ($(UNAME_S),Linux)
		MINIFB += minifb/src/x11/*.c
		LDFLAGS = -lX11
	endif
endif

# work

%.m.o:	%.m
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

minicube$(EXT): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)


.PHONY: clean

clean:	
	rm $(OBJ)
