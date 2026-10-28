#!/usr/bin/env bash
# Kjører en enkel rekognosering mot lab-målene. Kjøres FRA attacker-containeren:
#   docker compose exec attacker /opt/scripts/recon.sh
set -e
TARGETS="dvwa juice-shop target-ssh"
OUT="/opt/loot/recon-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "▶ Finner hvilke verter som er oppe..."
for t in $TARGETS; do
  ping -c1 -W1 "$t" >/dev/null 2>&1 && echo "  $t er oppe" || echo "  $t svarer ikke"
done

echo "▶ Portskanning (nmap)..."
for t in $TARGETS; do
  echo "  -- $t"
  nmap -sV -T4 "$t" -oN "$OUT/nmap-$t.txt" | grep -E "^[0-9]+/|Nmap scan" | sed 's/^/     /'
done

echo "✅ Ferdig. Resultater lagret i $OUT (synlig som ./loot på Mac-en)."
