# Behold, the world's most interesting Makefile.
NASM := nasm

PROG := pong.com
SRCS := build.asm src/bss.asm src/defines.asm src/draw.asm \
	src/gameloop.asm src/keyboard.asm src/main.asm

$(PROG): $(SRCS)
	$(NASM) build.asm -o $(PROG)

.PHONY: clean

clean:
	$(RM) $(PROG)
