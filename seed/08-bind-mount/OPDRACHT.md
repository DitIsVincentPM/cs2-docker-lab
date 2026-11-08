# 08 · Bind mount (map delen met de host)
In deze map staat `site/index.html`. Je kunt die hiernaast in de editor aanpassen.

1. Start nginx `web-bind` op poort **18081** met `site/` als **bind mount** op `/usr/share/nginx/html`.
2. Open http://localhost:18081.
3. Wijzig `site/index.html` in de editor, sla op en ververs je browser. De wijziging is meteen zichtbaar!
4. Bonus: mount het read-only (`:ro`) en probeer in de container een bestand te maken.

> Volume vs bind mount: een **volume** wordt beheerd door Docker (`/var/lib/docker/volumes`), een **bind mount** is een willekeurig pad op de host.
