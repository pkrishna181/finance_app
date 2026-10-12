#!/usr/bin/env python3
"""Render the synthetic CAS text fixtures (test/golden/cas/*.txt) as PDFs.

The CAMS one is encrypted with a PAN-style password (ABCDE1234F), like real
CAS PDFs. Requires: pip install reportlab pypdf

Run from repo root or app/: python3 app/tool/generate_cas_pdfs.py
"""

from __future__ import annotations

import io
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

FONT_SIZE = 6.5
LINE_H = 11
SPECS = [
    ("cams_detailed.txt", "cams_detailed.pdf", "ABCDE1234F"),
    ("nsdl.txt", "nsdl.pdf", None),
]


def golden_dir() -> Path:
    here = Path(__file__).resolve().parent
    for p in (here / "../../test/golden/cas", Path("test/golden/cas")):
        if p.resolve().is_dir():
            return p.resolve()
    raise SystemExit("test/golden/cas not found")


def render(lines: list[str]) -> bytes:
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=A4)
    _, h = A4
    y = h - 40
    for line in lines:
        if y < 40:
            c.showPage()
            y = h - 40
        c.setFont("Helvetica", FONT_SIZE)
        c.drawString(30, y, line)
        y -= LINE_H
    c.save()
    return buf.getvalue()


def main() -> None:
    d = golden_dir()
    for src, out, password in SPECS:
        data = render((d / src).read_text().splitlines())
        if password:
            w = PdfWriter()
            for page in PdfReader(io.BytesIO(data)).pages:
                w.add_page(page)
            w.encrypt(password)
            b = io.BytesIO()
            w.write(b)
            data = b.getvalue()
        (d / out).write_bytes(data)
        print(f"Wrote {out}" + (f" (password: {password})" if password else ""))


if __name__ == "__main__":
    main()
