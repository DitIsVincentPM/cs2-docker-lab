# 14 · Multi-stage build
`main.go` staat klaar. Schrijf een Dockerfile met **2 stages**:
1. stage `build`: `FROM golang:1.23 AS build`, kopieer de code en compileer met
   `RUN CGO_ENABLED=0 go build -o /hello main.go`
2. eindstage: `FROM alpine`, kopieer **alleen** de binary uit de build-stage (`COPY --from=build ...`)

Build als `gohello:multi`. Vergelijk de grootte met `golang:1.23` via `docker images`.
De image moet < 30 MB zijn en mag de Go-compiler niet bevatten.
