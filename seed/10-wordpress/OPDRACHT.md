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
