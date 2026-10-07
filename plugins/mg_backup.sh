#!/bin/bash
. /etc/mgvpn/backup.conf
D=/root/backups
F=$D/usuarios_$(hostname)_$(date +%F_%H%M).tar.gz
mkdir -p "$D"; T=$(mktemp -d)
awk -F: '$3>=1000 && $1!="nobody"' /etc/passwd > $T/passwd
awk -F: 'NR==FNR{u[$1]=1;next} $1 in u' $T/passwd /etc/shadow > $T/shadow
for p in $EXTRA; do [ -e "$p" ] && cp -a --parents "$p" "$T"; done
tar -czf "$F" -C "$T" . && rm -rf "$T" && chmod 600 "$F"
ls -1t $D/usuarios_*.tar.gz | tail -n +8 | xargs -r rm -f
[ -n "$TG_TOKEN" ] && curl -s -F chat_id="$TG_CHAT" -F document=@"$F" \
  -F caption="Backup $(hostname) $(date +%F)" \
  "https://api.telegram.org/bot$TG_TOKEN/sendDocument" >/dev/null
