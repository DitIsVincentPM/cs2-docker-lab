# 04 · Commit
*Lab 4 — een image maken uit een gewijzigde container*

1. Start interactief een `ubuntu`-container met de naam `bouw`.
2. Installeer daarin `curl` en maak `/hallo.txt` met de tekst `CS2`.
3. Verlaat de container en maak met **commit** de image `mijnubuntu:curl`.
4. Test: `docker run --rm mijnubuntu:curl curl --version`

> ⚠️ Examenvraag: waarom gebruiken we in de praktijk liever een Dockerfile dan `commit`?
