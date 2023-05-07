#! /usr/bin/python3

import os
import sys
import threading

from handlers.default import HudMenu

def run_command(module, function):
  args = 'python3 -c "from %s import %s as run; run()"'
  args = args % (module, function)
  proc = threading.Thread(target=os.system, args=[args])
  proc.start()

def run_hud_menu(menu):
  run_command('appmenu', 'main')

def main():
  menu = HudMenu()
  menu.run()
if __name__ == "__main__":
  main()
