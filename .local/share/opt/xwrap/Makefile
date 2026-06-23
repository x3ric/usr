CC = gcc
CFLAGS= -g -Wall
INCLUDE = -L /usr/lib/x86_64-linux-gnu
LIBS = -lX11 -lXext -lXrender

all:
	${CC} xwrap.c ${CFLAGS} ${INCLUDE} ${LIBS} -o xwrap

install:
	install xwrap '/usr/local/bin'

uninstall:
	rm -rf '/usr/local/bin/xwrap'

clean:
	rm -rf xwrap