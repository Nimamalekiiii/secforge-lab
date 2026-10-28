#!/usr/bin/env bash
# Fanger trafikk i laben til en .pcap-fil du kan åpne i Wireshark.
# Kjøres FRA attacker-containeren:
#   docker compose exec attacker /opt/scripts/capture.sh 30
set -e
SECONDS_TO_RUN="${1:-20}"
OUT="/opt/loot/capture-$(date +%Y%m%d-%H%M%S).pcap"
mkdir -p /opt/loot
echo "▶ Fanger trafikk i ${SECONDS_TO_RUN}s -> $OUT"
timeout "${SECONDS_TO_RUN}" tcpdump -i eth0 -w "$OUT" 2>/dev/null || true
echo "✅ Lagret $OUT. Åpne den i Wireshark på Mac-en (ligger i ./loot)."
