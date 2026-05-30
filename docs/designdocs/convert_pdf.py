import os
import re
import sys

def install_and_import():
    # Make sure we have the required libraries
    try:
        import fpdf
        import markdown
    except ImportError:
        print("Required packages not found. Installing fpdf2 and markdown...")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "fpdf2", "markdown"])
        import fpdf
        import markdown
    return fpdf, markdown

fpdf, markdown = install_and_import()
from fpdf import FPDF

class HTMLPDF(FPDF):
    def header(self):
        pass
    def footer(self):
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.cell(0, 10, f"Page {self.page_no()}/{{nb}}", align="C")

def clean_unicode(text):
    replacements = {
        '•': '-',
        '███████████': '===========',
        '██████████': '==========',
        '█████████': '=========',
        '████████': '========',
        '██████': '======',
        '█████': '=====',
        '████': '====',
        '███': '===',
        '██': '==',
        '█': '=',
        '─': '-',
        '┌': '+',
        '┬': '+',
        '┐': '+',
        '├': '+',
        '┼': '+',
        '┤': '+',
        '└': '+',
        '┴': '+',
        '┘': '+',
        '│': '|',
        '◀': '<',
        '▶': '>',
        '▲': '^',
        '▼': 'v',
        '…': '...',
        '\u2026': '...',
        '\u200b': '',   # zero-width space
        '\u201c': '"', # left double quote
        '\u201d': '"', # right double quote
        '\u2018': "'", # left single quote
        '\u2019': "'", # right single quote
        '\u2013': '-', # en dash
        '\u2014': '-', # em dash
        '\u2022': '-', # bullet
    }
    for k, v in replacements.items():
        text = text.replace(k, v)
    # Convert anything else non-cp1252 to ? to prevent crash
    text = text.encode('cp1252', errors='replace').decode('cp1252')
    return text

def strip_tags_in_cells(html_content):
    def clean_cell(match):
        cell_content = match.group(2)
        # Strip all HTML tags inside the cell content (e.g., <code>, </code>)
        cleaned = re.sub(r'<[^>]+>', '', cell_content)
        return match.group(1) + cleaned + match.group(3)
    
    # Match <td>...</td> or <th>...</th>
    html_content = re.sub(r'(<td[^>]*>)(.*?)(</td>)', clean_cell, html_content, flags=re.DOTALL | re.IGNORECASE)
    html_content = re.sub(r'(<th[^>]*>)(.*?)(</th>)', clean_cell, html_content, flags=re.DOTALL | re.IGNORECASE)
    return html_content

def convert_md_to_pdf(md_path, pdf_path):
    print(f"Reading {md_path}...")
    with open(md_path, "r", encoding="utf-8") as f:
        md_text = f.read()

    # Preprocess text to clean incompatible unicode
    cleaned_md = clean_unicode(md_text)

    # Convert Markdown to HTML with tables extension
    print("Converting Markdown to HTML...")
    html = markdown.markdown(cleaned_md, extensions=['tables', 'fenced_code'])

    # Strip thead/tbody tags which confuse fpdf2's HTML parser
    html = html.replace('<thead>', '')
    html = html.replace('</thead>', '')
    html = html.replace('<tbody>', '')
    html = html.replace('</tbody>', '')

    # Strip HTML tags inside table cells to avoid fpdf2 NotImplementedError
    html = strip_tags_in_cells(html)

    # Wrap in basic styling to make it look clean
    html_doc = f"""
    <html>
    <head>
    <style>
      body {{ font-family: Helvetica, sans-serif; font-size: 10pt; line-height: 1.4; }}
      h1 {{ font-size: 18pt; font-weight: bold; margin-top: 15px; margin-bottom: 10px; }}
      h2 {{ font-size: 14pt; font-weight: bold; margin-top: 12px; margin-bottom: 8px; }}
      h3 {{ font-size: 12pt; font-weight: bold; margin-top: 10px; margin-bottom: 6px; }}
      table {{ border-collapse: collapse; width: 100%; margin-top: 10px; margin-bottom: 10px; }}
      th, td {{ border: 1px solid #999999; padding: 6px; text-align: left; font-size: 8pt; }}
      th {{ background-color: #f2f2f2; font-weight: bold; }}
      pre, code {{ font-family: Courier, monospace; font-size: 8pt; background-color: #f9f9f9; }}
    </style>
    </head>
    <body>
    {html}
    </body>
    </html>
    """

    print("Generating PDF...")
    pdf = HTMLPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.write_html(html_doc)
    
    # Save the output PDF
    pdf.output(pdf_path)
    print(f"Successfully generated {pdf_path}")

if __name__ == "__main__":
    src_md = "SleepyDrive_Design_Document.md"
    dest_pdf = "SleepyDrive_Design_Document.pdf"
    if not os.path.exists(src_md):
        print(f"Error: {src_md} not found! Run build_combined.sh first.")
        sys.exit(1)
    convert_md_to_pdf(src_md, dest_pdf)
