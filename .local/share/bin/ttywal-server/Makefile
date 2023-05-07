CC=gcc
CFLAGS=

PREFIX=/usr/local
SERVICE_DIR=/etc/systemd/system

all: ttywal-server

ttywal-server: main.c
	$(CC) $(CFLAGS) main.c -o ttywal-server

clean:
	rm -f ttywal-server

install:
	make
	sed -i "s|/home/e|$(HOME)|g" ttywal-server.service
	sudo touch $(HOME)/.cache/ttywal
	sudo chmod a+rw $(HOME)/.cache/ttywal
	sudo install -m 755 ttywal-server $(PREFIX)/bin
	sudo install -m 644 ttywal-server.service $(SERVICE_DIR)
	sudo systemctl enable ttywal-server.service
	sudo systemctl daemon-reload

uninstall:
	sudo systemctl disable ttywal-server.service
	sudo rm -f $(PREFIX)/bin/ttywal-server
	sudo rm -f $(SERVICE_DIR)/ttywal-server.service
	sudo systemctl daemon-reload
