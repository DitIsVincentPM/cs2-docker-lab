"""Tiny API for the CS2 study page: exercises, file editing, checks, solutions."""
import json, os, re, subprocess
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

ROOT = "/work/oefeningen"
OPT = "/opt/cs2"
ANSI = re.compile(r"\x1b\[[0-9;]*m")
EDITABLE = re.compile(r"(Dockerfile|\.ya?ml|\.html|\.js|\.json|\.py|\.go|\.txt|\.conf|\.dockerignore|\.mod)$")


def safe(rel):
    p = os.path.realpath(os.path.join(ROOT, rel))
    if not p.startswith(ROOT + "/"):
        raise ValueError("pad buiten oefeningen")
    return p


def exercises():
    out = []
    for d in sorted(os.listdir(ROOT)):
        full = os.path.join(ROOT, d)
        md = os.path.join(full, "OPDRACHT.md")
        if not os.path.isfile(md):
            continue
        files = []
        for base, dirs, names in os.walk(full):
            dirs[:] = [x for x in dirs if not x.startswith(".") and x != "node_modules"]
            for n in names:
                if n != "OPDRACHT.md" and EDITABLE.search(n):
                    files.append(os.path.relpath(os.path.join(base, n), ROOT))
        out.append({"id": d[:2], "dir": d, "md": open(md, encoding="utf-8").read(), "files": sorted(files)})
    return out


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def send(self, code, body, ctype="application/json"):
        data = body if isinstance(body, bytes) else (json.dumps(body) if ctype == "application/json" else body).encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype + "; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        u = urlparse(self.path)
        q = parse_qs(u.query)
        try:
            if u.path in ("/", "/index.html"):
                return self.send(200, open(f"{OPT}/web/index.html", "rb").read(), "text/html")
            if u.path == "/api/ex":
                return self.send(200, exercises())
            if u.path == "/api/file":
                p = safe(q["p"][0])
                return self.send(200, open(p, encoding="utf-8").read() if os.path.exists(p) else "", "text/plain")
            m = re.fullmatch(r"/api/sol/(\d\d)", u.path)
            if m:
                return self.send(200, open(f"{OPT}/sol/{m[1]}.md", encoding="utf-8").read(), "text/plain")
            self.send(404, {"error": "niet gevonden"})
        except Exception as e:
            self.send(400, {"error": str(e)})

    def do_PUT(self):
        u = urlparse(self.path)
        try:
            p = safe(parse_qs(u.query)["p"][0])
            if not EDITABLE.search(p):
                raise ValueError("bestandstype niet toegestaan")
            os.makedirs(os.path.dirname(p), exist_ok=True)
            n = int(self.headers.get("Content-Length", 0))
            open(p, "w", encoding="utf-8", newline="\n").write(self.rfile.read(n).decode())
            self.send(200, {"ok": True})
        except Exception as e:
            self.send(400, {"error": str(e)})

    def do_POST(self):
        u = urlparse(self.path)
        m = re.fullmatch(r"/api/check/(\d\d)", u.path)
        if m:
            r = subprocess.run(["bash", f"{OPT}/bin/check", m[1]], capture_output=True, text=True, timeout=120)
            return self.send(200, {"out": ANSI.sub("", r.stdout + r.stderr)})
        if u.path == "/api/reset":
            r = subprocess.run(["bash", f"{OPT}/bin/reset", "-y"], capture_output=True, text=True, timeout=300)
            return self.send(200, {"out": ANSI.sub("", r.stdout + r.stderr)})
        self.send(404, {"error": "niet gevonden"})


ThreadingHTTPServer(("127.0.0.1", 8000), H).serve_forever()
