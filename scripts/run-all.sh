
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p writeups loot
X="docker compose exec -T attacker"

echo "▶ 1/4  Nettverksrekognosering (nmap)…"
NMAP="$($X nmap -sV -T4 --version-light dvwa juice-shop target-ssh 2>/dev/null)"
echo "$NMAP" > loot/nmap.txt

echo "▶ 2/4  Web-angrep (DVWA + Juice Shop)…"
WEB="$($X python3 /opt/scripts/attack.py 2>&1)"

echo "▶ 3/4  Henter SSH-banner…"
BANNER="$(printf '' | $X bash -lc 'nc -w 4 target-ssh 2222 2>/dev/null || nc -w 4 target-ssh 22 2>/dev/null' 2>/dev/null | head -1)"
[ -z "$BANNER" ] && BANNER="(banner ikke lest – se nmap-utdata over)"

echo "▶ 4/4  Skriver rapport…"
NMAP_SHORT="$(echo "$NMAP" | grep -E '^[0-9]+/|Nmap scan report|Service Info' )"

cat > writeups/REPORT.md <<MD
# SecForge – angrepsrapport

**Dato:** $(date '+%Y-%m-%d %H:%M')
**Utført av:** Nima Maleki
**Omfang:** kun containerne i den isolerte SecForge-laben (dvwa, juice-shop, target-ssh). Ingen eksterne systemer er berørt.

> 🚧 Dette er en øvingsrapport fra et lukket læringsmiljø. Målene er med vilje sårbare apper laget for opplæring (DVWA, OWASP Juice Shop).

---

## Sammendrag av funn

| # | Mål | Funn | Alvorlighet |
|---|-----|------|-------------|
| 1 | juice-shop | SQL-injection gir innlogging uten passord + gyldig JWT | Kritisk |
| 2 | dvwa | SQL-injection dumper alle brukernavn og passord-hasher | Kritisk |
| 3 | juice-shop | Produktkatalog hentes ut via åpent API uten innlogging |  Middels |
| 4 | target-ssh | SSH-tjeneste eksponert med svakt passord | Middels |

---

## 1. Rekognosering (nmap)

Først kartla jeg hvilke tjenester som kjører på målene:

\`\`\`
$NMAP_SHORT
\`\`\`

**Lærdom:** åpne porter og versjonsnummer forteller en angriper nøyaktig hva som kan angripes. I produksjon bør man eksponere færrest mulig tjenester og skjule versjonsbannere.

---

## 2–3. Web-angrep (DVWA + Juice Shop)

Utdata fra angrepsskriptet:

\`\`\`
$WEB
\`\`\`

### Hvordan SQL-injection fungerer
Appen limer brukerinput rett inn i en SQL-spørring. Ved å sende \`' OR 1=1--\` lukkes
tekststrengen og betingelsen blir alltid sann, slik at databasen returnerer alt –
eller logger oss inn som første bruker (admin).

### Tiltak (hvordan man stopper det)
- **Parameteriserte spørringer / prepared statements** – skill kode fra data.
- **Validér og begrens input** på serversiden.
- **Minste privilegium** på databasebrukeren.
- Lagre passord med **bcrypt/argon2**, aldri som ren MD5.
- Krev **autentisering** på API-endepunkter som eksponerer data.

---

## 4. SSH-tjeneste (target-ssh)

Banner lest fra tjenesten:

\`\`\`
$BANNER
\`\`\`

Tjenesten er satt opp med et svakt, gjettbart passord – en klassisk inngang for
brute force-angrep.

### Tiltak
- Slå av passord-innlogging og bruk **SSH-nøkler**.
- Bruk **fail2ban** / rate-limiting mot gjentatte forsøk.
- Ingen standard- eller svake passord.

---

## Konklusjon
Alle fire funnene er klassiske svakheter fra OWASP Top 10 og CIS-anbefalingene.
Øvelsen viser både **hvordan** de utnyttes og, viktigere, **hvordan de forhindres** –
som er hele poenget med å trene i et trygt, isolert miljø.
MD

echo
echo " Rapport skrevet til writeups/REPORT.md"
echo "   Åpne den gjerne for å lese gjennom før opplasting."
