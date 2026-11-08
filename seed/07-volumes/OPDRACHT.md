# 07 · Named volumes
Doel: aantonen dat data **overleeft** als een container verwijderd wordt.

1. Maak een named volume `webdata`.
2. Start nginx-container `tijdelijk` met `webdata` gemount op `/usr/share/nginx/html`.
3. Schrijf via `docker exec` een `index.html` met het woord `persistent` in die map.
4. **Verwijder** `tijdelijk` (`docker rm -f`).
5. Start een nieuwe nginx `web-vol` op poort **18086**, met hetzelfde volume. Staat je pagina er nog?
6. Bonus: `docker volume inspect webdata`. Waar staat de data op de host?
