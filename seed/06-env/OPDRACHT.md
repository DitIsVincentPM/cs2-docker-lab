# 06 · Environment variables
1. Start detached een `mariadb:11`-container `db-env` met:
   - root-wachtwoord `geheim` (`MARIADB_ROOT_PASSWORD`)
   - een database `school` (`MARIADB_DATABASE`)
2. Bekijk de env-variabelen met `docker inspect` of `docker exec db-env env`.
3. Log in: `docker exec -it db-env mariadb -uroot -pgeheim` en voer `show databases;` uit.

> Na het starten heeft MariaDB ~10-15 s nodig. Kijk met `docker logs -f db-env` tot "ready for connections".
