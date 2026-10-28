# Øvelse 2 – SQL-injection (DVWA)

Mål: forstå hvordan uvalidert input kan lekke data fra en database.

## Steg
1. Åpne DVWA i nettleseren: http://localhost:8081  (logg inn: `admin` / `password`)
2. Første gang: trykk **Create / Reset Database**.
3. Sett **DVWA Security** til *Low* under fanen Security.
4. Gå til **SQL Injection** og prøv klassikeren i ID-feltet:
   - `1' OR '1'='1`
   - `1' UNION SELECT user, password FROM users -- -`

## Reflekter
- Hvorfor fungerer `' OR '1'='1`?
- Sett sikkerheten til *Medium* og *High*. Hva endrer seg?
- Hvordan ville **parameteriserte spørringer** (prepared statements) stoppet dette?
