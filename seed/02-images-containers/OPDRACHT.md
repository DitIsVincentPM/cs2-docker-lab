# 02 · Images en containers
*Lab 2 — levenscyclus van een container*

1. Start **detached** een nginx-container met de naam `web1`.
2. Bekijk de draaiende containers en de logs van `web1`.
3. Stop `web1`, kijk naar `docker ps` en `docker ps -a`, en start hem terug.
4. Maak met `docker exec` het bestand `/tmp/bewijs.txt` **in** de container.
5. Open ook een interactieve shell in `web1` (`exit` om eruit te gaan).
