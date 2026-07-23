#!/usr/bin/env python3
"""Static file server cho OpAppHtmlDemo — hỗ trợ clean URL .do (try_files),
bind IPv4 0.0.0.0 để máy khác trong LAN vào được.

Dùng:  python3 deploy/serve.py [PORT] [ROOT_DIR]
Mặc định PORT=8090, ROOT_DIR=thư mục hiện tại.
"""
import mimetypes
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlparse

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
ROOT = os.path.abspath(sys.argv[2]) if len(sys.argv) > 2 else os.getcwd()

# .do là trang HTML (clean URL) -> trả về đúng content-type text/html.
mimetypes.add_type("text/html", ".do")


def resolve(url_path):
    """Map URL -> file thật, có try_files: thử <path>, rồi <path>.html."""
    rel = unquote(urlparse(url_path).path).lstrip("/")
    target = os.path.normpath(os.path.join(ROOT, rel))
    # chặn path traversal ra ngoài ROOT
    if target != ROOT and not target.startswith(ROOT + os.sep):
        return None
    if os.path.isdir(target):
        index = os.path.join(target, "index.html")
        return index if os.path.isfile(index) else None
    if os.path.isfile(target):
        return target
    if os.path.isfile(target + ".html"):   # /keiba/SpRaceInfo.do -> .do.html
        return target + ".html"
    return None


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self._serve(write_body=True)

    def do_HEAD(self):
        self._serve(write_body=False)

    def _serve(self, write_body):
        path = resolve(self.path)
        if not path:
            self.send_error(404)
            return
        try:
            with open(path, "rb") as f:
                data = f.read()
        except OSError:
            self.send_error(404)
            return
        ctype = mimetypes.guess_type(path)[0] or "application/octet-stream"
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        if path.endswith((".html", ".do")):
            self.send_header("Cache-Control", "no-store")
        self.end_headers()
        if write_body:
            self.wfile.write(data)

    def log_message(self, *args):
        pass  # tắt log ồn ào


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Serving {ROOT} on http://0.0.0.0:{PORT}", flush=True)
    server.serve_forever()
