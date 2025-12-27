# ReportLab PDF Creation Guide

Comprehensive guide for creating professional PDFs using ReportLab.

## Core Concepts

### Canvas vs Platypus

**Canvas (Low-level):**
- Direct control over page layout
- Position elements with x, y coordinates
- Best for: Forms, certificates, precise layouts
- More code, more control

**Platypus (High-level):**
- Flowable elements that auto-layout
- Best for: Reports, documents, multi-page content
- Less code, automatic pagination

## Canvas Approach

### Basic Setup

```python
from reportlab.lib.pagesizes import letter, A4
from reportlab.pdfgen import canvas

# Create canvas
c = canvas.Canvas("output.pdf", pagesize=letter)
width, height = letter  # 612 x 792 points

# Coordinate system: (0,0) is bottom-left
```

### Drawing Text

```python
# Simple text
c.drawString(100, 700, "Hello World!")

# Right-aligned text
text = "Right aligned"
text_width = c.stringWidth(text, "Helvetica", 12)
c.drawString(width - text_width - 100, 700, text)

# Centered text
text = "Centered text"
text_width = c.stringWidth(text, "Helvetica", 12)
c.drawString((width - text_width) / 2, 700, text)
```

### Fonts and Styling

```python
# Set font
c.setFont("Helvetica", 12)
c.setFont("Helvetica-Bold", 14)
c.setFont("Times-Roman", 10)

# Text color
from reportlab.lib.colors import red, blue, black
c.setFillColor(red)
c.drawString(100, 640, "Red text")
c.setFillColor(black)
```

### Tables

```python
from reportlab.platypus import Table
from reportlab.lib import colors

data = [
    ['Header 1', 'Header 2', 'Header 3'],
    ['Row 1 Col 1', 'Row 1 Col 2', 'Row 1 Col 3'],
]

table = Table(data)
table.setStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('GRID', (0, 0), (-1, -1), 1, colors.black)
])

table.wrapOn(c, width, height)
table.drawOn(c, 100, 400)
```

## Platypus Approach

### Basic Document

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("output.pdf", pagesize=letter)
story = []

styles = getSampleStyleSheet()

title = Paragraph("Document Title", styles['Title'])
story.append(title)
story.append(Spacer(1, 12))

body = Paragraph("This is body text.", styles['Normal'])
story.append(body)

doc.build(story)
```

### Tables

```python
from reportlab.platypus import Table, TableStyle
from reportlab.lib import colors

data = [
    ['Name', 'Age', 'City'],
    ['Alice', '30', 'New York'],
    ['Bob', '25', 'Los Angeles'],
]

table = Table(data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472C4')),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
]))

story.append(table)
```

## Common Patterns

### Invoice Template

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch

c = canvas.Canvas("invoice.pdf", pagesize=letter)
width, height = letter

# Header
c.setFont("Helvetica-Bold", 20)
c.drawString(1*inch, height - 1*inch, "INVOICE")

# Items table
data = [
    ['Item', 'Quantity', 'Price', 'Total'],
    ['Product A', '2', '$50.00', '$100.00'],
    ['', '', 'Total:', '$100.00'],
]

from reportlab.platypus import Table, TableStyle
from reportlab.lib import colors

table = Table(data, colWidths=[3*inch, 1*inch, 1*inch, 1*inch])
table.setStyle(TableStyle([
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('LINEABOVE', (0, 0), (-1, 0), 1, colors.black),
]))

table.wrapOn(c, width, height)
table.drawOn(c, 1*inch, height - 5*inch)

c.save()
```

### Report with Header/Footer

```python
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.units import inch

def header_footer(canvas, doc):
    canvas.saveState()
    width, height = letter
    
    # Header
    canvas.setFont('Helvetica-Bold', 10)
    canvas.drawString(inch, height - 0.5*inch, "Company Report")
    
    # Footer
    canvas.drawRightString(width - inch, 0.5*inch, f"Page {doc.page}")
    
    canvas.restoreState()

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
story = []

doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
```
