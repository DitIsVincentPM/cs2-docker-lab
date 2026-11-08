#!/bin/sh
# Seed exercises the first time (never overwrite the student's work)
[ -d /work/oefeningen ] || cp -r /opt/cs2/seed /work/oefeningen
export CS2_HASH="$(caddy hash-password --plaintext "$CS2_PASS")"
python3 /opt/cs2/app.py &
ttyd -i 127.0.0.1 -p 7681 -b /term -W \
  -t fontSize=14 -t 'theme={"background":"#0d1117"}' -t disableLeaveAlert=true \
  bash &
caddy run --config /opt/cs2/Caddyfile --adapter caddyfile &
exec dockerd-entrypoint.sh dockerd --host=unix:///var/run/docker.sock
