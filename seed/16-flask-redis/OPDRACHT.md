# 16 · Compose + build — Flask & Redis
`app.py` en `requirements.txt` staan klaar: een teller die bij elke bezoek +1 doet in Redis.

1. Schrijf een `Dockerfile` (`python:3.12-slim`, `WORKDIR /app`, requirements eerst installeren, `CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]`)
2. Schrijf `compose.yaml` met:
   - `web`: **build** vanuit deze map, poort **18085→5000**, `depends_on: redis`
   - `redis`: image `redis:alpine`
3. `docker compose up -d --build` en ververs http://localhost:18085 een paar keer.

Vraag: waarom moet Flask luisteren op `0.0.0.0` en niet op `127.0.0.1`?
