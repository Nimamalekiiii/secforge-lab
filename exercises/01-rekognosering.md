# Øvelse 1 – Nettverksrekognosering

Mål: kartlegge hvilke tjenester som finnes i laben, uten å vite noe på forhånd.

## Steg
1. Start laben: `docker compose up -d`
2. Hopp inn i angriper-boksen: `docker compose exec attacker bash`
3. Kjør en automatisk skanning: `/opt/scripts/recon.sh`
   - Eller manuelt: `nmap -sV dvwa juice-shop target-ssh`

## Reflekter
- Hvilke porter og tjenester fant du på hvert mål?
- Hvilke versjoner kjører de, og hvorfor er versjonsnummer interessant for en angriper?
- Hvordan ville du oppdaget denne skanningen hvis du var forsvarer?
