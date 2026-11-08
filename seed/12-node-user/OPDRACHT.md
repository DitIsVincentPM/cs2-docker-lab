# 12 · Dockerfile — Node.js app + USER
`app.js` staat klaar en luistert op poort 3000. Schrijf een `Dockerfile`:
1. `FROM node:22-alpine`
2. `WORKDIR /app`
3. kopieer `package.json` **eerst**, dan `RUN npm install`, dan pas de rest (waarom? → layer cache!)
4. `EXPOSE 3000`
5. draai **niet als root**: de image heeft al een user `node`
6. start met `CMD ["node", "app.js"]`

Build `nodeapp:1.0` en run als `node` op poort **18084**. De app toont als welke user hij draait.
