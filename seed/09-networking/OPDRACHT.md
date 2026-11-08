# 09 · Networking
1. Maak een user-defined bridge network `labnet`.
2. Start op `labnet`:
   - `api`: `nginx:alpine` (detached)
   - `app`: `alpine` die blijft draaien (`sleep infinity`)
3. Test vanuit `app`: `docker exec app wget -qO- http://api`. Dat werkt via **DNS op naam**!
4. Start `eenzaam` (`alpine`, `sleep infinity`) **zonder** `--network`, dus op de default bridge, en probeer hetzelfde. Waarom faalt dit?
5. Bekijk `docker network ls` en `docker network inspect labnet`.
