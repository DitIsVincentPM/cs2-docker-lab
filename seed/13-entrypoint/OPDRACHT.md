# 13 · ENTRYPOINT vs CMD
Maak een image `pinger`:
- `FROM alpine`
- `ENTRYPOINT ["ping", "-c", "3"]`
- `CMD ["localhost"]`

Test:
```bash
docker run --rm pinger              # pingt localhost
docker run --rm pinger 127.0.0.1    # argument VERVANGT CMD, ENTRYPOINT blijft
docker run --rm --entrypoint echo pinger hallo   # entrypoint overschrijven
```
Bonus: wat is het verschil tussen de **exec-vorm** `["ping","x"]` en de **shell-vorm** `ping x`?
