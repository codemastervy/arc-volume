#!/usr/bin/env python3
"""Fake Home Assistant webhook endpoint. Appends each POST body to a JSONL file.
Usage: fake_ha.py PORT OUTFILE   (binds 127.0.0.1 only)"""
import http.server, json, sys

class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(n).decode()
        try:
            rec = {"path": self.path, "body": json.loads(raw)}
        except ValueError:
            rec = {"path": self.path, "bad": raw}
        with open(sys.argv[2], "a") as f:
            f.write(json.dumps(rec) + "\n")
        self.send_response(200); self.end_headers()
    def log_message(self, *a): pass

http.server.HTTPServer(("127.0.0.1", int(sys.argv[1])), H).serve_forever()
