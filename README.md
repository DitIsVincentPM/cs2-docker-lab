# CS2 Docker-lab

Studieomgeving voor het Docker/containers-deel van Computersystemen 2. Alles zit op één webpagina:

- theorie (7 hoofdstukken), flashcards, quiz en een examensimulatie met timer
- 16 labs met een opdracht, een editor, een terminal in de browser en een **✔ Check**-knop

De labs draaien in een eigen **Docker-in-Docker sandbox**, dus je echte containers en images blijven ongemoeid.

## Starten

Je hebt Docker Desktop (Windows/Mac) of Docker Engine (Linux) nodig.

```bash
git clone <deze-repo> cs2-docker-lab
cd cs2-docker-lab
docker compose up -d --build
```

Open daarna **http://localhost:18100** en log in met:

- gebruiker: `student`
- wachtwoord: `docker`

Wil je een eigen login? Kopieer `.env.example` naar `.env` en vul je gegevens in.

De eerste build duurt een minuutje. Labs die een webpagina maken, bereik je op `http://localhost:18080` tot `18099`.

## Handig

| Wat | Commando |
|---|---|
| Stoppen | `docker compose down` |
| Alles in de sandbox wissen | typ `reset -y` in de terminal op de pagina |
| Oefeningen opnieuw beginnen | `docker compose down && rm -rf work` en daarna terug `up -d` |
| Alles weg, ook de images | `docker compose down --rmi all && rm -rf data work` |

Je voortgang (quiz, flashcards) wordt in je browser bewaard. Je oefenbestanden staan in `./work`.
