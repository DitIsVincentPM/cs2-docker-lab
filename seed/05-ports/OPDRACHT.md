# 05 · Publishing ports
1. Start detached een nginx-container `web-port` waarbij **hostpoort 18080** naar **containerpoort 80** gaat.
2. Test met `curl localhost:18080` en in je browser via **http://localhost:18080**.
3. Bekijk de mapping met `docker port web-port`.

> 💡 Volgorde: `-p HOST:CONTAINER`. `EXPOSE` in een Dockerfile publiceert **niets**; het is alleen documentatie. `-P` publiceert alle EXPOSEd poorten op willekeurige hostpoorten.
