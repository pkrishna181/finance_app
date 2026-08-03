#!/usr/bin/env python3
"""Generate text-layer PDF statement fixtures from CSV goldens.

Requires: pip install reportlab pypdf

Run from repo root or app/: python3 app/tool/generate_statement_pdfs.py
"""

from __future__ import annotations

import csv
import io
import subprocess
import sys
from pathlib import Path

try:
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas
except ImportError:
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "--user", "reportlab", "pypdf"],
    )
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas

# Column x positions (points) — tuned for pdfium text extraction.
COL_X_ACCOUNT = [40, 110, 310, 400, 480, 560]
COL_X_CC = [40, 130, 460]
ROW_H = 14
FONT = "Helvetica"
FONT_SIZE = 9

SPECS = [
    ("hdfc_account.csv", "hdfc_account.pdf"),
    ("icici_account.csv", "icici_account.pdf"),
    ("sbi_account.csv", "sbi_account.pdf"),
    ("axis_account.csv", "axis_account.pdf"),
    ("hdfc_cc.csv", "hdfc_cc.pdf"),
    ("axis_cc.csv", "axis_cc.pdf"),
    ("hdfc_continuation.csv", "hdfc_continuation.pdf"),
    ("axis_blank_amounts.csv", "axis_blank_amounts.pdf"),
]


def find_golden_dir() -> Path:
    here = Path(__file__).resolve().parent
    for rel in (
        here / "../../test/golden/statement",
        here / "../test/golden/statement",
        Path("test/golden/statement"),
        Path("../test/golden/statement"),
    ):
        p = rel.resolve()
        if p.is_dir():
            return p
    raise SystemExit("test/golden/statement not found")


def read_csv(path: Path) -> list[list[str]]:
    rows: list[list[str]] = []
    with path.open(newline="", encoding="utf-8") as f:
        for row in csv.reader(f):
            if any(cell.strip() for cell in row):
                rows.append(row)
    return rows


def col_x_for(csv_name: str) -> list[int]:
    if csv_name.endswith("_cc.csv"):
        return COL_X_CC
    return COL_X_ACCOUNT


def draw_table_pdf(
    rows: list[list[str]],
    out: Path,
    *,
    page_header: str | None = None,
    col_x: list[int] | None = None,
) -> None:
    width, height = A4
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=A4)
    y = height - 60
    xs = col_x or COL_X_ACCOUNT

    if page_header:
        c.setFont(FONT, 10)
        c.drawString(40, height - 30, page_header)

    c.setFont(FONT, FONT_SIZE)
    for row in rows:
        if y < 40:
            c.showPage()
            y = height - 60
            c.setFont(FONT, FONT_SIZE)
        for i, cell in enumerate(row[: len(xs)]):
            if cell:
                c.drawString(xs[i], y, cell)
        y -= ROW_H

    c.save()
    out.write_bytes(buf.getvalue())


def draw_multipage_pdf(rows: list[list[str]], out: Path) -> None:
    width, height = A4
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=A4)
    header_idx = next(
        i
        for i, row in enumerate(rows)
        if "date" in " ".join(row).lower() and "narration" in " ".join(row).lower()
    )
    preamble = rows[:header_idx]
    header = rows[header_idx]
    data = rows[header_idx + 1 :]
    per_page = 4
    page_num = 1
    for start in range(0, max(len(data), 1), per_page):
        y = height - 40
        c.setFont(FONT, 10)
        c.drawString(40, height - 25, f"HDFC Bank Ltd — Statement (Page {page_num})")
        page_num += 1
        c.setFont(FONT, FONT_SIZE)
        for line in preamble:
            for i, cell in enumerate(line[: len(COL_X_ACCOUNT)]):
                if cell:
                    c.drawString(COL_X_ACCOUNT[i], y, cell)
            y -= ROW_H
        for i, cell in enumerate(header[: len(COL_X_ACCOUNT)]):
            if cell:
                c.drawString(COL_X_ACCOUNT[i], y, cell)
        y -= ROW_H
        for row in data[start : start + per_page]:
            for i, cell in enumerate(row[: len(COL_X_ACCOUNT)]):
                if cell:
                    c.drawString(COL_X_ACCOUNT[i], y, cell)
            y -= ROW_H
        if start + per_page < len(data):
            c.showPage()
    c.save()
    out.write_bytes(buf.getvalue())


def draw_sectioned_cc(out: Path) -> None:
    rows = [
        ["Axis Bank Credit Card"],
        ["DOMESTIC TRANSACTIONS"],
        ["Date", "Transaction Details", "Amount"],
        ["28-07-2026", "ZOMATO MEDIA PVT LTD", "899.00"],
        ["29-07-2026", "UBER INDIA", "350.00"],
        [""],
        ["INTERNATIONAL TRANSACTIONS"],
        ["Date", "Transaction Details", "Amount"],
        ["30-07-2026", "NETFLIX.COM USD 15.99", "1335.00"],
    ]
    draw_table_pdf(rows, out, col_x=COL_X_CC)


def draw_scanned(out: Path) -> None:
    from reportlab.pdfgen import canvas

    width, height = A4
    buf = io.BytesIO()
    c = canvas.Canvas(buf, pagesize=A4)
    # Gray rectangle only — no text (image-only scanned surrogate).
    c.setFillGray(0.9)
    c.rect(100, height - 300, 400, 200, fill=1, stroke=0)
    c.save()
    out.write_bytes(buf.getvalue())


def encrypt_pdf(plain: Path, out: Path, password: str) -> bool:
    try:
        from pypdf import PdfReader, PdfWriter
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", "pypdf"])
        from pypdf import PdfReader, PdfWriter

    reader = PdfReader(str(plain))
    writer = PdfWriter()
    for page in reader.pages:
        writer.add_page(page)
    writer.encrypt(password)
    with out.open("wb") as f:
        writer.write(f)
    return True


def main() -> None:
    golden = find_golden_dir()
    print(f"Golden dir: {golden}")

    for csv_name, pdf_name in SPECS:
        csv_path = golden / csv_name
        if not csv_path.exists():
            print(f"SKIP {csv_name}")
            continue
        rows = read_csv(csv_path)
        out = golden / pdf_name
        draw_table_pdf(rows, out, col_x=col_x_for(csv_name))
        print(f"Wrote {out} ({out.stat().st_size} bytes)")

    hdfc_rows = read_csv(golden / "hdfc_account.csv")
    draw_multipage_pdf(hdfc_rows, golden / "hdfc_account_multipage.pdf")
    print("Wrote hdfc_account_multipage.pdf")

    draw_sectioned_cc(golden / "axis_cc_sectioned.pdf")
    print("Wrote axis_cc_sectioned.pdf")

    draw_scanned(golden / "scanned_image_only.pdf")
    print("Wrote scanned_image_only.pdf")

    plain = golden / "hdfc_account.pdf"
    enc = golden / "hdfc_account_password.pdf"
    if encrypt_pdf(plain, enc, "hdfc1234"):
        print("Wrote hdfc_account_password.pdf (password: hdfc1234)")


if __name__ == "__main__":
    main()
