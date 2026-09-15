#!/usr/bin/env python3
"""Play Anamanaguchi - Miku when no application windows are open.

Listens on the compositor's ext_foreign_toplevel_list_v1 global (exposed by
COSMIC) and starts/stops the track as windows open and close.
"""

import os
import shutil
import subprocess
import sys
import time
from threading import Lock, RLock, Thread

from pywayland.client import Display
from pywayland.protocol.ext_foreign_toplevel_list_v1.ext_foreign_toplevel_list_v1 import (
    ExtForeignToplevelListV1,
)

SONG = "/home/luca/Music/Miku/miku.m4a"
GRACE = 30  # seconds an app may be open before playback stops
EXCLUDED_APP_IDS = {"MikuVisualizer"}  # visualizer window never counts as "an app"

KITTY = "/run/current-system/sw/bin/kitty"
VISUALIZER_ARGS = [
    "--class=MikuVisualizer",
    "--title=♪ Miku Visualizer ♪",
    "-o", "hide_window_decorations=yes",
    "-o", "background_opacity=0.0",
    "-o", "foreground=#39C5BB",
    "cava",
]

windows = {}
lock = RLock()
proc = None
viz = None
stop_at = None


def log(msg):
    sys.stderr.write(f"[miku-idle] {time.strftime('%H:%M:%S')} {msg}\n")
    sys.stderr.flush()


def player():
    for p in (
        "/home/luca/.nix-profile/bin/mpv",
        "/run/current-system/sw/bin/mpv",
    ):
        if os.path.exists(p):
            return p
    return shutil.which("mpv") or "mpv"


def visualizer_start():
    global viz
    with lock:
        if viz is not None and viz.poll() is None:
            return
        try:
            viz = subprocess.Popen(
                [KITTY] + VISUALIZER_ARGS,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            log("visualizer up")
        except OSError as e:
            viz = None
            log(f"failed to start visualizer: {e}")


def visualizer_stop():
    global viz
    with lock:
        if viz is not None:
            if viz.poll() is None:
                viz.terminate()
                try:
                    viz.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    viz.kill()
            viz = None
            log("visualizer down")


def set_playing(running):
    global proc
    with lock:
        if running and (proc is None or proc.poll() is not None):
            try:
                proc = subprocess.Popen(
                    [player(), "--no-video", "--loop=inf", "--really-quiet", "--volume=90", SONG],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                log("desktop empty -> Miku is playing")
                visualizer_start()
            except OSError as e:
                log(f"failed to start player: {e}")
        elif not running and proc is not None and proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                proc.kill()
            proc = None
            log("apps open -> Miku stopped")
            visualizer_stop()


def on_app_id(handle, app_id):
    with lock:
        if handle in windows:
            windows[handle]["app_id"] = app_id


def on_closed(handle):
    with lock:
        windows.pop(handle, None)


def on_toplevel(lst, handle):
    with lock:
        windows[handle] = {"app_id": None}
    handle.dispatcher["app_id"] = on_app_id
    handle.dispatcher["closed"] = on_closed
    handle.dispatcher["done"] = lambda h: None


def main():
    global stop_at
    display = Display()
    try:
        display.connect()
    except (ValueError, OSError) as e:
        log(f"cannot connect to wayland display: {e}")
        sys.exit(2)

    registry = display.get_registry()
    holders = {"list": None}

    def on_global(reg, name, interface, version):
        if interface == "ext_foreign_toplevel_list_v1":
            tpl = reg.bind(name, ExtForeignToplevelListV1, version)
            tpl.dispatcher["toplevel"] = on_toplevel
            tpl.dispatcher["finished"] = lambda p: log("compositor finished toplevel list")
            holders["list"] = tpl

    registry.dispatcher["global"] = on_global
    display.roundtrip()

    if holders["list"] is None:
        log("ext_foreign_toplevel_list_v1 not available on this compositor")
        sys.exit(2)

    display.roundtrip()
    time.sleep(0.3)
    display.roundtrip()

    def timer():
        global stop_at
        while True:
            with lock:
                n = sum(
                    1
                    for w in windows.values()
                    if w.get("app_id") not in EXCLUDED_APP_IDS
                )
            now = time.monotonic()
            if n == 0:
                stop_at = None
                set_playing(True)
            else:
                if stop_at is None:
                    stop_at = now + GRACE
                elif now >= stop_at:
                    set_playing(False)
            time.sleep(1)

    Thread(target=timer, daemon=True).start()
    log("desktop watcher running")

    while True:
        if not display.dispatch(block=True):
            break

    log("wayland connection closed")


if __name__ == "__main__":
    main()