#!/bin/bash
# Genereert seed/ (opdrachten + starterbestanden) en opt/sol/ (modeloplossingen)
set -e
cd "$(dirname "$0")"
rm -rf seed opt/sol; mkdir -p seed opt/sol
ex() { mkdir -p "seed/$1"; cat > "seed/$1/OPDRACHT.md"; }
sol() { cat > "opt/sol/$1.md"; }

ex 01-hello-world <<'EOF'
# 01 · Hello World
*Lab 1 — je eerste container*

1. Start een container van de image `hello-world`.
2. Lees de output: welke **4 stappen** beschrijft Docker?
3. Bekijk alle containers, ook de gestopte. Waarom staat hij op *Exited*?

> 💡 Kennis: `docker run` = `pull` (indien nodig) + `create` + `start`.
EOF
sol 01 <<'EOF'
```bash
docker run hello-world
docker ps -a        # status: Exited (0) — het proces is klaar, dus de container stopt
```
De 4 stappen: client contacteert daemon → daemon pullt image van Docker Hub → daemon maakt container en voert het programma uit → daemon streamt output naar de client.
EOF

ex 02-images-containers <<'EOF'
# 02 · Images en containers
*Lab 2 — levenscyclus van een container*

1. Start **detached** een nginx-container met de naam `web1`.
2. Bekijk de draaiende containers en de logs van `web1`.
3. Stop `web1`, kijk naar `docker ps` en `docker ps -a`, en start hem terug.
4. Maak met `docker exec` het bestand `/tmp/bewijs.txt` **in** de container.
5. Open ook een interactieve shell in `web1` (`exit` om eruit te gaan).
EOF
sol 02 <<'EOF'
```bash
docker run -d --name web1 nginx
docker ps
docker logs web1          # -f om te volgen
docker stop web1 && docker ps -a
docker start web1
docker exec web1 touch /tmp/bewijs.txt
docker exec -it web1 bash
```
`-d` = detached (achtergrond), `-i` = stdin open, `-t` = pseudo-TTY.
EOF

ex 03-tags <<'EOF'
# 03 · Tags
*Lab 3 — een image heeft één ID maar kan veel tags hebben*

1. Pull `alpine:3.20` én `alpine:3.21`.
2. Geef `alpine:3.21` twee extra tags: `myalpine:v1` en `myalpine:latest`.
3. Vergelijk de **IMAGE ID**'s met `docker images`. Wat merk je?
4. Bonus: verwijder `myalpine:v1` met `docker rmi`. Is de image echt weg?
EOF
sol 03 <<'EOF'
```bash
docker pull alpine:3.20
docker pull alpine:3.21
docker tag alpine:3.21 myalpine:v1
docker tag alpine:3.21 myalpine:latest
docker images          # myalpine:* en alpine:3.21 hebben dezelfde IMAGE ID
```
`docker rmi myalpine:v1` → *Untagged*: alleen de tag verdwijnt, de image blijft zolang er nog een tag naar wijst. Zonder tag gebruikt Docker `:latest`.
EOF

ex 04-commit <<'EOF'
# 04 · Commit
*Lab 4 — een image maken uit een gewijzigde container*

1. Start interactief een `ubuntu`-container met de naam `bouw`.
2. Installeer daarin `curl` en maak `/hallo.txt` met de tekst `CS2`.
3. Verlaat de container en maak met **commit** de image `mijnubuntu:curl`.
4. Test: `docker run --rm mijnubuntu:curl curl --version`

> ⚠️ Examenvraag: waarom gebruiken we in de praktijk liever een Dockerfile dan `commit`?
EOF
sol 04 <<'EOF'
```bash
docker run -it --name bouw ubuntu bash
  apt update && apt install -y curl
  echo CS2 > /hallo.txt
  exit
docker commit bouw mijnubuntu:curl
docker run --rm mijnubuntu:curl curl --version
```
Dockerfile > commit: **reproduceerbaar**, gedocumenteerd, versiebeheer (git), betere layer cache, geen "zwarte doos".
EOF

ex 05-ports <<'EOF'
# 05 · Publishing ports
1. Start detached een nginx-container `web-port` waarbij **hostpoort 18080** naar **containerpoort 80** gaat.
2. Test met `curl localhost:18080` en in je browser via **http://localhost:18080**.
3. Bekijk de mapping met `docker port web-port`.

> 💡 Volgorde: `-p HOST:CONTAINER`. `EXPOSE` in een Dockerfile publiceert **niets**; het is alleen documentatie. `-P` publiceert alle EXPOSEd poorten op willekeurige hostpoorten.
EOF
sol 05 <<'EOF'
```bash
docker run -d --name web-port -p 18080:80 nginx
curl localhost:18080
docker port web-port
```
EOF

ex 06-env <<'EOF'
# 06 · Environment variables
1. Start detached een `mariadb:11`-container `db-env` met:
   - root-wachtwoord `geheim` (`MARIADB_ROOT_PASSWORD`)
   - een database `school` (`MARIADB_DATABASE`)
2. Bekijk de env-variabelen met `docker inspect` of `docker exec db-env env`.
3. Log in: `docker exec -it db-env mariadb -uroot -pgeheim` en voer `show databases;` uit.

> Na het starten heeft MariaDB ~10-15 s nodig. Kijk met `docker logs -f db-env` tot "ready for connections".
EOF
sol 06 <<'EOF'
```bash
docker run -d --name db-env \
  -e MARIADB_ROOT_PASSWORD=geheim \
  -e MARIADB_DATABASE=school \
  mariadb:11
docker exec db-env env | grep MARIADB
docker exec -it db-env mariadb -uroot -pgeheim -e "show databases;"
```
Ook mogelijk: `--env-file .env`.
EOF

ex 07-volumes <<'EOF'
# 07 · Named volumes
Doel: aantonen dat data **overleeft** als een container verwijderd wordt.

1. Maak een named volume `webdata`.
2. Start nginx-container `tijdelijk` met `webdata` gemount op `/usr/share/nginx/html`.
3. Schrijf via `docker exec` een `index.html` met het woord `persistent` in die map.
4. **Verwijder** `tijdelijk` (`docker rm -f`).
5. Start een nieuwe nginx `web-vol` op poort **18086**, met hetzelfde volume. Staat je pagina er nog?
6. Bonus: `docker volume inspect webdata`. Waar staat de data op de host?
EOF
sol 07 <<'EOF'
```bash
docker volume create webdata
docker run -d --name tijdelijk -v webdata:/usr/share/nginx/html nginx
docker exec tijdelijk sh -c 'echo "<h1>persistent</h1>" > /usr/share/nginx/html/index.html'
docker rm -f tijdelijk
docker run -d --name web-vol -p 18086:80 -v webdata:/usr/share/nginx/html nginx
curl localhost:18086
docker volume inspect webdata   # Mountpoint: /var/lib/docker/volumes/webdata/_data
```
Lang alternatief: `--mount type=volume,source=webdata,target=/usr/share/nginx/html`
EOF

ex 08-bind-mount <<'EOF'
# 08 · Bind mount (map delen met de host)
In deze map staat `site/index.html`. Je kunt die hiernaast in de editor aanpassen.

1. Start nginx `web-bind` op poort **18081** met `site/` als **bind mount** op `/usr/share/nginx/html`.
2. Open http://localhost:18081.
3. Wijzig `site/index.html` in de editor, sla op en ververs je browser. De wijziging is meteen zichtbaar!
4. Bonus: mount het read-only (`:ro`) en probeer in de container een bestand te maken.

> Volume vs bind mount: een **volume** wordt beheerd door Docker (`/var/lib/docker/volumes`), een **bind mount** is een willekeurig pad op de host.
EOF
mkdir -p seed/08-bind-mount/site
cat > seed/08-bind-mount/site/index.html <<'EOF'
<h1>Bind mount werkt!</h1>
<p>Pas mij aan in de editor en ververs de pagina.</p>
EOF
sol 08 <<'EOF'
```bash
cd /work/oefeningen/08-bind-mount
docker run -d --name web-bind -p 18081:80 -v "$(pwd)/site":/usr/share/nginx/html nginx
# read-only:
docker run -d --name web-ro -p 18087:80 -v "$(pwd)/site":/usr/share/nginx/html:ro nginx
docker exec web-ro touch /usr/share/nginx/html/x   # → Read-only file system
```
Een bind mount vereist een **absoluut pad** (vandaar `$(pwd)`). Met `--mount type=bind,source=...,target=...` krijg je een fout als de bron niet bestaat; `-v` maakt dan stilletjes een lege map aan.
EOF

ex 09-networking <<'EOF'
# 09 · Networking
1. Maak een user-defined bridge network `labnet`.
2. Start op `labnet`:
   - `api`: `nginx:alpine` (detached)
   - `app`: `alpine` die blijft draaien (`sleep infinity`)
3. Test vanuit `app`: `docker exec app wget -qO- http://api`. Dat werkt via **DNS op naam**!
4. Start `eenzaam` (`alpine`, `sleep infinity`) **zonder** `--network`, dus op de default bridge, en probeer hetzelfde. Waarom faalt dit?
5. Bekijk `docker network ls` en `docker network inspect labnet`.
EOF
sol 09 <<'EOF'
```bash
docker network create labnet
docker run -d --name api --network labnet nginx:alpine
docker run -d --name app --network labnet alpine sleep infinity
docker exec app wget -qO- http://api
docker run -d --name eenzaam alpine sleep infinity
docker exec eenzaam wget -T 3 -qO- http://api    # bad address
```
Alleen **user-defined** networks hebben ingebouwde DNS (container-naam → IP). Op de default `bridge` moet je IP-adressen gebruiken. Drivers: `bridge` (standaard), `host` (geen isolatie, hostnetwerk), `none` (geen netwerk). Een draaiende container koppel je met `docker network connect labnet eenzaam`.
EOF

ex 10-wordpress <<'EOF'
# 10 · Docker Compose — WordPress
Schrijf `compose.yaml` (hiernaast in de editor) met 2 services:

- **db**: `mariadb:11`, env `MARIADB_ROOT_PASSWORD`, `MARIADB_DATABASE=wordpress`, `MARIADB_USER=wp`, `MARIADB_PASSWORD=wp`, en een **named volume** `db_data` op `/var/lib/mysql`
- **wordpress**: `wordpress:6`, poort **18082→80**, `depends_on: db`, env `WORDPRESS_DB_HOST=db`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`

Daarna in de terminal:
```bash
cd /work/oefeningen/10-wordpress
docker compose up -d
docker compose ps / logs / down / down -v
```
Open http://localhost:18082. Wat is het verschil tussen `down` en `down -v`?
EOF
cat > seed/10-wordpress/compose.yaml <<'EOF'
# Vul aan!
services:
  db:
    image:

  wordpress:
    image:

volumes:
EOF
sol 10 <<'EOF'
```yaml
services:
  db:
    image: mariadb:11
    environment:
      MARIADB_ROOT_PASSWORD: rootpw
      MARIADB_DATABASE: wordpress
      MARIADB_USER: wp
      MARIADB_PASSWORD: wp
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped

  wordpress:
    image: wordpress:6
    depends_on:
      - db
    ports:
      - "18082:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wp
      WORDPRESS_DB_PASSWORD: wp
      WORDPRESS_DB_NAME: wordpress
    restart: unless-stopped

volumes:
  db_data:
```
- Compose maakt automatisch een netwerk `10-wordpress_default`, dus `db` is bereikbaar op naam.
- `down` verwijdert containers en netwerk, `down -v` óók de named volumes (data weg!).
- `depends_on` regelt alleen de **startvolgorde**, niet of de db "ready" is (daarvoor: `condition: service_healthy` + healthcheck).
EOF

ex 11-staticweb <<'EOF'
# 11 · Dockerfile — static website
Schrijf een `Dockerfile` die:
1. vertrekt van `nginx:alpine`
2. de map `site/` kopieert naar `/usr/share/nginx/html/`
3. poort 80 documenteert met `EXPOSE`

Build als `staticweb:1.0` en run als container `static` op poort **18083**:
```bash
cd /work/oefeningen/11-staticweb
docker build -t staticweb:1.0 .
```
Bekijk daarna `docker history staticweb:1.0`. Welke instructies maken een nieuwe layer?
EOF
mkdir -p seed/11-staticweb/site
echo '<h1>Static via Dockerfile</h1>' > seed/11-staticweb/site/index.html
printf '# Schrijf hier je Dockerfile\n' > seed/11-staticweb/Dockerfile
sol 11 <<'EOF'
```dockerfile
FROM nginx:alpine
COPY site/ /usr/share/nginx/html/
EXPOSE 80
```
```bash
docker build -t staticweb:1.0 .
docker run -d --name static -p 18083:80 staticweb:1.0
docker history staticweb:1.0
```
De `.` is de **build context**: alles wat naar de daemon gestuurd wordt. Gebruik `.dockerignore` om bestanden uit te sluiten.
EOF

ex 12-node-user <<'EOF'
# 12 · Dockerfile — Node.js app + USER
`app.js` staat klaar en luistert op poort 3000. Schrijf een `Dockerfile`:
1. `FROM node:22-alpine`
2. `WORKDIR /app`
3. kopieer `package.json` **eerst**, dan `RUN npm install`, dan pas de rest (waarom? → layer cache!)
4. `EXPOSE 3000`
5. draai **niet als root**: de image heeft al een user `node`
6. start met `CMD ["node", "app.js"]`

Build `nodeapp:1.0` en run als `node` op poort **18084**. De app toont als welke user hij draait.
EOF
cat > seed/12-node-user/app.js <<'EOF'
const http = require('http'), os = require('os');
http.createServer((req, res) => {
  res.end(`Hallo van Node! user=${os.userInfo().username} host=${os.hostname()}\n`);
}).listen(3000, () => console.log('luistert op 3000'));
EOF
echo '{ "name": "nodeapp", "version": "1.0.0", "main": "app.js" }' > seed/12-node-user/package.json
printf '# Schrijf hier je Dockerfile\n' > seed/12-node-user/Dockerfile
sol 12 <<'EOF'
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
USER node
CMD ["node", "app.js"]
```
```bash
docker build -t nodeapp:1.0 .
docker run -d --name node -p 18084:3000 nodeapp:1.0
curl localhost:18084      # user=node
```
**Layer cache**: zolang `package.json` niet wijzigt, hergebruikt Docker de `npm install`-layer, ook als je code wijzigt. Als je eerst `COPY . .` doet, wordt bij elke codewijziging opnieuw geïnstalleerd.
Eigen user aanmaken: `RUN addgroup -S app && adduser -S app -G app` en dan `USER app`.
EOF

ex 13-entrypoint <<'EOF'
# 13 · ENTRYPOINT vs CMD
Maak een image `pinger`:
- `FROM alpine`
- `ENTRYPOINT ["ping", "-c", "3"]`
- `CMD ["localhost"]`

Test:
```bash
docker run --rm pinger              # pingt localhost
docker run --rm pinger 127.0.0.1    # argument VERVANGT CMD, ENTRYPOINT blijft
docker run --rm --entrypoint echo pinger hallo   # entrypoint overschrijven
```
Bonus: wat is het verschil tussen de **exec-vorm** `["ping","x"]` en de **shell-vorm** `ping x`?
EOF
printf '# Schrijf hier je Dockerfile\n' > seed/13-entrypoint/Dockerfile
sol 13 <<'EOF'
```dockerfile
FROM alpine
ENTRYPOINT ["ping", "-c", "3"]
CMD ["localhost"]
```
| | ENTRYPOINT | CMD |
|---|---|---|
| doel | het vaste programma | standaard-argumenten / default commando |
| `docker run img X` | blijft | wordt **vervangen** door X |
| overschrijven | `--entrypoint` | argumenten na de image-naam |

**Exec-vorm** (JSON-array): het proces wordt PID 1 en krijgt signalen (SIGTERM bij `docker stop`). **Shell-vorm**: draait via `/bin/sh -c`, dus `sh` is PID 1, variabelen worden geëxpandeerd, maar signalen komen niet aan bij je app.
EOF

ex 14-multistage <<'EOF'
# 14 · Multi-stage build
`main.go` staat klaar. Schrijf een Dockerfile met **2 stages**:
1. stage `build`: `FROM golang:1.23 AS build`, kopieer de code en compileer met
   `RUN CGO_ENABLED=0 go build -o /hello main.go`
2. eindstage: `FROM alpine`, kopieer **alleen** de binary uit de build-stage (`COPY --from=build ...`)

Build als `gohello:multi`. Vergelijk de grootte met `golang:1.23` via `docker images`.
De image moet < 30 MB zijn en mag de Go-compiler niet bevatten.
EOF
cat > seed/14-multistage/main.go <<'EOF'
package main

import "fmt"

func main() {
	fmt.Println("Hallo vanuit multi-stage! 🐳")
}
EOF
printf '# Schrijf hier je Dockerfile\n' > seed/14-multistage/Dockerfile
sol 14 <<'EOF'
```dockerfile
# Stage 1: bouwen (SDK, groot)
FROM golang:1.23 AS build
WORKDIR /src
COPY main.go .
RUN CGO_ENABLED=0 go build -o /hello main.go

# Stage 2: runtime (klein)
FROM alpine
COPY --from=build /hello /usr/local/bin/hello
CMD ["hello"]
```
```bash
docker build -t gohello:multi .
docker images | grep -E "gohello|golang"    # ~8 MB vs ~800 MB
```
Voordelen: **kleinere image**, minder aanvalsoppervlak (geen compiler/SDK), sneller pullen. Bij .NET: `mcr.microsoft.com/dotnet/sdk` om te bouwen (`dotnet publish`) en `mcr.microsoft.com/dotnet/aspnet` als runtime. Een specifieke stage bouwen kan met `docker build --target build .`
EOF

ex 15-registry <<'EOF'
# 15 · Publishing — lokale registry
(Vereist: `staticweb:1.0` uit oefening 11)

1. Start een lokale registry: image `registry:2`, naam `registry`, poort `5000:5000`.
2. Tag `staticweb:1.0` als `localhost:5000/staticweb:1.0`.
3. **Push** hem naar je registry.
4. Bekijk de catalogus: `curl localhost:5000/v2/_catalog`
5. Verwijder beide lokale tags (`docker rmi`) en **pull** de image terug uit je registry.

> Naamgeving: `[registry-host[:poort]/][namespace/]repository[:tag]`. Zonder host is het Docker Hub, bv. `jouwnaam/staticweb:1.0` → `docker.io/jouwnaam/staticweb:1.0`.
EOF
sol 15 <<'EOF'
```bash
docker run -d --name registry -p 5000:5000 registry:2
docker tag staticweb:1.0 localhost:5000/staticweb:1.0
docker push localhost:5000/staticweb:1.0
curl localhost:5000/v2/_catalog
curl localhost:5000/v2/staticweb/tags/list
docker rmi staticweb:1.0 localhost:5000/staticweb:1.0
docker pull localhost:5000/staticweb:1.0
```
Docker Hub: `docker login` → `docker tag staticweb:1.0 <user>/staticweb:1.0` → `docker push <user>/staticweb:1.0`.
Google Artifact Registry: `gcloud auth configure-docker europe-west1-docker.pkg.dev` → tag `europe-west1-docker.pkg.dev/<project>/<repo>/staticweb:1.0` → push.
EOF

ex 16-flask-redis <<'EOF'
# 16 · Compose + build — Flask & Redis
`app.py` en `requirements.txt` staan klaar: een teller die bij elke bezoek +1 doet in Redis.

1. Schrijf een `Dockerfile` (`python:3.12-slim`, `WORKDIR /app`, requirements eerst installeren, `CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]`)
2. Schrijf `compose.yaml` met:
   - `web`: **build** vanuit deze map, poort **18085→5000**, `depends_on: redis`
   - `redis`: image `redis:alpine`
3. `docker compose up -d --build` en ververs http://localhost:18085 een paar keer.

Vraag: waarom moet Flask luisteren op `0.0.0.0` en niet op `127.0.0.1`?
EOF
cat > seed/16-flask-redis/app.py <<'EOF'
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host="redis", port=6379)


@app.route("/")
def hello():
    count = redis.incr("hits")
    return f"Hallo! Deze pagina is {count} keer bekeken.\n"
EOF
printf 'flask\nredis\n' > seed/16-flask-redis/requirements.txt
printf '# Schrijf hier je Dockerfile\n' > seed/16-flask-redis/Dockerfile
printf '# Schrijf hier je compose.yaml\nservices:\n' > seed/16-flask-redis/compose.yaml
sol 16 <<'EOF'
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
```
```yaml
services:
  web:
    build: .
    ports:
      - "18085:5000"
    depends_on:
      - redis
  redis:
    image: redis:alpine
```
`127.0.0.1` in een container is de loopback van **de container zelf**: verkeer dat via de gepubliceerde poort binnenkomt, komt op de netwerkinterface van de container aan en bereikt de app dus niet. `0.0.0.0` = luister op alle interfaces.
De hostnaam `redis` werkt dankzij de DNS van het compose-netwerk (servicenaam = hostnaam).
EOF
echo "seed klaar: $(ls seed | wc -l) oefeningen"
