PROG = scrollback
CFLAGS = -Wall -Wextra -g
SH = /bin/zsh

build: $(PROG).c
	gcc $(CFLAGS) -o $(PROG) $(PROG).c

clean:
	rm -f $(PROG)

install: $(PROG)
	cp $(PROG) vtdirect $(DESTDIR)/usr/bin
	cp $(PROG).1 $(DESTDIR)/usr/share/man/man1
	cp compose.$(PROG) $(DESTDIR)/usr/share/kbd/keymaps/include/

uninstall: clean
	rm -f $(DESTDIR)/usr/bin/$(PROG)
	rm -f $(DESTDIR)/usr/bin/vtdirect
	rm -f $(DESTDIR)/usr/share/man/man1/$(PROG).1
	rm -f $(DESTDIR)/usr/share/kbd/keymaps/include/compose.$(PROG)

run: clean build
	./$(PROG) $(SH)

debug: clean build
	gdb ./$(PROG) $(SH)
