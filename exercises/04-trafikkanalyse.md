# Øvelse 4 – Trafikk- og logganalyse

Mål: fange og lese trafikk mellom boksene i laben.

## Steg
1. I angriper-boksen, start fangst: `/opt/scripts/capture.sh 30`
2. I et annet vindu, lag trafikk mot et mål, f.eks.:
   `docker compose exec attacker curl -s http://dvwa/ >/dev/null`
3. Åpne .pcap-filen fra `./loot` i **Wireshark** på Mac-en.

## Reflekter
- Hvilken informasjon sendes i klartekst over HTTP?
- Hvordan ville HTTPS endret det du ser?
- Kobling til `security-log-analyzer`-prosjektet ditt: hvilke mønstre i loggene avslører et angrep?
