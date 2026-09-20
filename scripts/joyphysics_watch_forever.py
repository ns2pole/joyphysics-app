#!/usr/bin/env python3
"""Pixel が ADB で見える間、flutter run を維持し lib/ 変更で hot restart する。"""
from __future__ import annotations

import hashlib
import os
import signal
import subprocess
import time
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT / "lib"
DEVICE_PREFIX = "adb-59181JEKB09093"
JAVA_HOME = "/usr/local/var/homebrew/tmp/.cellar/openjdk@17/17.0.20.1"
LOG = Path("/tmp/joyphysics_watch_forever.log")

DEBOUNCE = 1.0
POLL = 0.5
ATTACH_GRACE = 5.0
DEVICE_POLL = 3.0


def log(msg: str) -> None:
    line = f"[{time.strftime('%H:%M:%S')}] {msg}"
    print(line, flush=True)
    try:
        with LOG.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    if Path(JAVA_HOME).exists():
        env["JAVA_HOME"] = JAVA_HOME
        env["PATH"] = f"{JAVA_HOME}/bin:{env.get('PATH', '')}"
    return subprocess.run(
        cmd,
        text=True,
        capture_output=True,
        env=env,
        cwd=str(PROJECT),
        **kwargs,
    )


def device_serial() -> str | None:
    try:
        out = subprocess.check_output(["adb", "devices"], text=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    for line in out.splitlines()[1:]:
        line = line.strip()
        if not line or "offline" in line or "unauthorized" in line:
            continue
        parts = line.split()
        if len(parts) >= 2 and parts[1] == "device" and DEVICE_PREFIX in parts[0]:
            return parts[0]
    return None


def find_flutter_pid() -> int | None:
    try:
        out = subprocess.check_output(["ps", "-ax", "-o", "pid=,command="], text=True)
    except subprocess.CalledProcessError:
        return None
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        if "flutter_tools.snapshot run -d adb-59181JEKB09093" not in line:
            continue
        if "joyphysics_watch_forever" in line or "python" in line.lower():
            continue
        if "/bin/zsh" in line or "/bin/bash" in line or "pgrep" in line:
            continue
        pid_s, _, _cmd = line.partition(" ")
        try:
            return int(pid_s)
        except ValueError:
            continue
    return None


def alive(pid: int | None) -> bool:
    if pid is None:
        return False
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def fingerprint() -> str:
    h = hashlib.md5()
    for p in sorted(ROOT.rglob("*.dart")):
        try:
            st = p.stat()
            h.update(str(p.relative_to(ROOT)).encode())
            h.update(str(st.st_mtime_ns).encode())
            h.update(str(st.st_size).encode())
        except FileNotFoundError:
            pass
    return h.hexdigest()


def start_flutter(serial: str) -> None:
    log(f"start flutter run -d {serial}")
    env = os.environ.copy()
    if Path(JAVA_HOME).exists():
        env["JAVA_HOME"] = JAVA_HOME
        env["PATH"] = f"{JAVA_HOME}/bin:{env.get('PATH', '')}"
    log_path = Path("/tmp/joyphysics_flutter_run.log")
    with log_path.open("a", encoding="utf-8") as f:
        f.write(f"\n===== {time.strftime('%Y-%m-%d %H:%M:%S')} flutter run =====\n")
        subprocess.Popen(
            ["flutter", "run", "-d", serial],
            cwd=str(PROJECT),
            env=env,
            stdout=f,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )


def main() -> None:
    log(f"forever watch on {ROOT} (never stop while phone present)")
    last = fingerprint()
    pending: float | None = None
    pid = find_flutter_pid()
    attached_at = time.time() if pid else 0.0
    if pid:
        log(f"attach pid={pid}")
    last_device_check = 0.0
    serial: str | None = None

    while True:
        now = time.time()
        if now - last_device_check >= DEVICE_POLL:
            last_device_check = now
            serial = device_serial()
            if serial is None:
                log("phone not visible — waiting (watcher stays alive)")
                pid = None
                pending = None
                time.sleep(DEVICE_POLL)
                continue

            if not alive(pid):
                pid = find_flutter_pid()
                if pid:
                    last = fingerprint()
                    pending = None
                    attached_at = time.time()
                    log(f"reattach pid={pid}")
                else:
                    start_flutter(serial)
                    # give flutter a moment to appear
                    for _ in range(40):
                        time.sleep(0.5)
                        pid = find_flutter_pid()
                        if pid:
                            last = fingerprint()
                            pending = None
                            attached_at = time.time()
                            log(f"attach pid={pid}")
                            break
                    else:
                        log("flutter start pending — will retry")
                        time.sleep(2.0)
                        continue

        if serial is None:
            time.sleep(POLL)
            continue

        if not alive(pid):
            time.sleep(POLL)
            continue

        cur = fingerprint()
        if cur != last:
            pending = now
            last = cur
        if pending is not None and now - pending >= DEBOUNCE:
            if now - attached_at < ATTACH_GRACE:
                time.sleep(POLL)
                continue
            pending = None
            try:
                os.kill(pid, signal.SIGUSR2)
                log(f"hot restart -> {pid}")
            except OSError as e:
                log(f"signal fail: {e}")
                pid = None
        time.sleep(POLL)


if __name__ == "__main__":
    main()
