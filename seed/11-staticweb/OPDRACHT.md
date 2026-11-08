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
