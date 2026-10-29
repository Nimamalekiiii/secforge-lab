# SecForge 

>  **Under utvikling** – dette prosjektet er ikke ferdig ennå, og flere endringer kommer.

Et **isolert øvingslab for cybersikkerhet**, bygget med Docker. Laben starter med vilje
sårbare mål i et lukket Docker-nettverk, slik at jeg trygt kan øve på rekognosering,
web-angrep og trafikkanalyse – og forstå hvordan man **forsvarer** seg mot det samme.

Laget som en del av studiene mine i cybersikkerhet.

##  Etikk og bruk
Alt her er ment for læring i et lukket miljø. Målene kjører kun som containere inne i
laben, og portene er bundet til `127.0.0.1` så ingenting eksponeres utover din egen maskin.
**Bruk kun verktøyene mot containerne i denne laben – aldri mot systemer du ikke eier.**

##  Hva laben inneholder
| Boks | Rolle |
|---|---|
| **dvwa** | Damn Vulnerable Web App – SQLi, XSS, CSRF, file upload (http://localhost:8081) |
| **juice-shop** | OWASP Juice Shop – moderne OWASP Top 10 (http://localhost:8082) |
| **target-ssh** | Enkel SSH-tjeneste å kartlegge og skanne |
| **attacker** | Analyseboks med `nmap`, `curl`, `tcpdump`, `netcat` m.m. |

##  Kom i gang
Krever **Docker Desktop** installert og kjørende.

```bash
# 1. Start hele laben
docker compose up -d

# 2. Hopp inn i angriper-boksen
docker compose exec attacker bash

# 3. Kjør en rekognosering mot målene
/opt/scripts/recon.sh

# Når du er ferdig:
docker compose down
```

##  Øvelser
Gjennomgangene ligger i [`exercises/`](exercises/):
1. [Nettverksrekognosering](exercises/01-rekognosering.md)
2. [SQL-injection](exercises/02-web-sqli.md)
3. [Cross-Site Scripting](exercises/03-web-xss.md)
4. [Trafikk- og logganalyse](exercises/04-trafikkanalyse.md)


## 🤖 Kjør alt automatisk
Hele øvelsen kan kjøres i ett steg, som også skriver en rapport:
```bash
bash scripts/run-all.sh
```
Rapporten med alle funn og tiltak havner i [`writeups/REPORT.md`](writeups/REPORT.md).

## Struktur
```text
secforge-lab/
├── docker-compose.yml   # definerer hele laben
├── attacker/            # Dockerfile for angriper-/analyseboksen
├── scripts/             # recon.sh, capture.sh, attack.py, run-all.sh
├── exercises/           # øvingsoppgaver med refleksjon
├── writeups/            # angrepsrapport (REPORT.md)
└── loot/                # dine egne resultater (ignoreres av git)
```

## 🔗 Relaterte prosjekter

SecForge er **red team**-delen av en større arbeidsflyt. Angrepene her oppdages og visualiseres i disse prosjektene:

| | Prosjekt | Rolle |
|---|---|---|
| 🧪 | **SecForge** *(dette repoet)* | Laben der angrepene utføres (**red team**) |
| 🔎 | [**Security Log Analyzer**](https://github.com/Nimamalekiiii/security-log-analyzer) | Oppdager angrepene i loggene (**blue team**) |
| 📊 | [**Live SIEM Dashboard**](https://nimamalekiiii.github.io/security-log-analyzer/) | Visualiserer funnene som en SOC-oversikt |

## 🛠️ Verktøy
Docker · nmap · tcpdump · DVWA · OWASP Juice Shop · Wireshark
