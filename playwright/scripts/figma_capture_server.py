#!/usr/bin/env python3
"""Serve build/web for Figma capture.

This server differs from `serve --single` in two ways:
1. It serves dotfile assets like `assets/.env`.
2. It falls back to `index.html` only for missing SPA routes.
"""

from __future__ import annotations

import argparse
import http.server
import os
import socketserver
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Serve a SPA build for Figma capture.')
    parser.add_argument(
        '--root',
        default='build/web',
        help='Directory to serve. Defaults to build/web.',
    )
    parser.add_argument(
        '--port',
        type=int,
        default=3001,
        help='Port to bind. Defaults to 3001.',
    )
    return parser.parse_args()


class SpaCaptureHandler(http.server.SimpleHTTPRequestHandler):
    root_dir: Path

    def translate_path(self, path: str) -> str:
        clean_path = path.split('?', 1)[0].split('#', 1)[0]
        requested = (self.root_dir / clean_path.lstrip('/')).resolve()

        if requested == self.root_dir or self.root_dir in requested.parents:
            return str(requested)

        return str(self.root_dir / 'index.html')

    def do_GET(self) -> None:
        clean_path = self.path.split('?', 1)[0].split('#', 1)[0]
        if clean_path in ('', '/'):
          self.path = '/index.html'
          return super().do_GET()

        requested = (self.root_dir / clean_path.lstrip('/')).resolve()
        if (
            requested.exists()
            and requested.is_file()
            and (requested == self.root_dir or self.root_dir in requested.parents)
        ):
            return super().do_GET()

        self.path = '/index.html'
        return super().do_GET()

    def log_message(self, fmt: str, *args: object) -> None:
        print(fmt % args)


def main() -> None:
    args = parse_args()
    root_dir = Path(args.root).resolve()

    if not root_dir.exists():
        raise SystemExit(f'Root does not exist: {root_dir}')

    handler = SpaCaptureHandler
    handler.root_dir = root_dir

    os.chdir(root_dir)

    with socketserver.TCPServer(('127.0.0.1', args.port), handler) as httpd:
        print(f'Serving {root_dir} on http://127.0.0.1:{args.port}')
        httpd.serve_forever()


if __name__ == '__main__':
    main()
