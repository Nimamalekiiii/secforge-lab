# Øvelse 3 – Cross-Site Scripting (Juice Shop)

Mål: se hvordan skript kan kjøres i en annen brukers nettleser.

## Steg
1. Åpne OWASP Juice Shop: http://localhost:8082
2. Prøv et søk med: `<iframe src="javascript:alert('xss')">`
3. Utforsk "Score Board" (finn den – det er en del av utfordringen) for flere oppgaver.

## Reflekter
- Forskjellen på *reflektert*, *lagret* og *DOM-basert* XSS?
- Hvordan beskytter output-encoding og en Content-Security-Policy mot dette?
