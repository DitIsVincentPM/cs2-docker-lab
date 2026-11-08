# 15 · Publishing — lokale registry
(Vereist: `staticweb:1.0` uit oefening 11)

1. Start een lokale registry: image `registry:2`, naam `registry`, poort `5000:5000`.
2. Tag `staticweb:1.0` als `localhost:5000/staticweb:1.0`.
3. **Push** hem naar je registry.
4. Bekijk de catalogus: `curl localhost:5000/v2/_catalog`
5. Verwijder beide lokale tags (`docker rmi`) en **pull** de image terug uit je registry.

> Naamgeving: `[registry-host[:poort]/][namespace/]repository[:tag]`. Zonder host is het Docker Hub, bv. `jouwnaam/staticweb:1.0` → `docker.io/jouwnaam/staticweb:1.0`.
