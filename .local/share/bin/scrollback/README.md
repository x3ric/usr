Scrollback
==========

A scrollback buffer for the linux console

How to run it
-------------

Calling ``scrollback /bin/bash`` in a linux console makes the shell run with a
scrollback buffer.

It can be called from ``.bashrc`` as well:

```
! $SCROLLBACK false && scrollback /bin/bash
```

Once checked that it works this way, it can be run to replace the current
shell:

```
! $SCROLLBACK false && [ $(tty) != /dev/tty6 ] && \
scrollback -c /bin/bash && exec scrollback /bin/bash
```

Keys
----

The keys for scrolling are F11 and F12. The old combinations shift-pageup and
shift-pagedown can be used instead by calling ``scrollback -k`` at least once
as root. Alternatively, it is done by the included keymap file
``compose.scrollback``.

Running startx and similar
--------------------------

If a program refuses to run whining about ``VT_GETMODE``, ``KDSETMODE`` or
something like that, try running it through ``vtdirect``. For example, instead
of ``startx`` call ``vtdirect startx``.

