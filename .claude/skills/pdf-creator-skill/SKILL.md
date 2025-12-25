---
name: pdf-creator
description: Create professional PDF documents from scratch using Python ReportLab. Use when generating PDFs for reports, invoices, certificates, forms, documentation, data exports, or any document creation task. Covers both Canvas (precise layouts) and Platypus (flowing documents) approaches with tables, images, styling, multi-page documents, and templates.
---

# PDF Creator Skill

Generate professional PDF documents programmatically using ReportLab.

## Overview

This skill helps create PDFs from scratch using Python's ReportLab library. Choose between Canvas (precise control) or Platypus (automatic layout) based on your needs.

## When to Use This Skill

Trigger when users request:
- "create PDF", "generate PDF", "make a PDF"
- "PDF report", "PDF invoice", "PDF certificate"
- "export to PDF", "save as PDF"
- Any document generation task requiring PDF output

## Quick Start

### Simple PDF (Canvas)

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("output.pdf", pagesize=letter)
width, height = letter

c.setFont("Helvetica-Bold", 16)
c.drawString(100, height - 100, "Hello PDF!")

c.setFont("Helvetica", 12)
c.drawString(100, height - 130, "This is a simple PDF document.")

c.save()
```

### Simple Document (Platypus)

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("output.pdf", pagesize=letter)
story = []
styles = getSampleStyleSheet()

story.append(Paragraph("Document Title", styles['Title']))
story.append(Paragraph("This is body text.", styles['Normal']))

doc.build(story)
```

## Canvas vs Platypus

### Use Canvas When:
- Precise positioning required (forms, certificates)
- Fixed layout design
- Simple one-page documents
- Need exact x, y coordinates

### Use Platypus When:
- Multi-page documents with flowing content
- Reports, articles, documentation
- Automatic pagination needed
- Tables and lists

## Common Tasks

### Create Invoice

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from reportlab.platypus import Table, TableStyle
from reportlab.lib import colors

c = canvas.Canvas("invoice.pdf", pagesize=letter)
width, height = letter

# Header
c.setFont("Helvetica-Bold", 20)
c.drawString(1*inch, height - 1*inch, "INVOICE")

c.setFont("Helvetica", 10)
c.drawString(1*inch, height - 1.3*inch, "Invoice #: INV-001")
c.drawString(1*inch, height - 1.5*inch, "Date: 2024-11-24")

# Company info (right side)
c.drawRightString(width - 1*inch, height - 1*inch, "Your Company")
c.drawRightString(width - 1*inch, height - 1.2*inch, "123 Business St")

# Items table
data = [
    ['Item', 'Qty', 'Price', 'Total'],
    ['Service A', '1', '$100.00', '$100.00'],
    ['Product B', '2', '$50.00', '$100.00'],
    ['', '', 'Total:', '$200.00'],
]

table = Table(data, colWidths=[3*inch, 0.75*inch, 1*inch, 1*inch])
table.setStyle(TableStyle([
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('LINEABOVE', (0, 0), (-1, 0), 1, colors.black),
    ('LINEBELOW', (0, 0), (-1, 0), 1, colors.black),
    ('LINEBELOW', (0, -1), (-1, -1), 1, colors.black),
    ('ALIGN', (1, 0), (-1, -1), 'RIGHT'),
]))

table.wrapOn(c, width, height)
table.drawOn(c, 1*inch, height - 4*inch)

c.save()
```

### Create Report

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, 
                                Table, TableStyle, PageBreak)
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.lib.units import inch

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
story = []
styles = getSampleStyleSheet()

# Title
story.append(Paragraph("Monthly Sales Report", styles['Title']))
story.append(Spacer(1, 0.25*inch))

# Executive Summary
story.append(Paragraph("Executive Summary", styles['Heading1']))
story.append(Paragraph(
    "This report summarizes sales performance for November 2024.",
    styles['Normal']
))
story.append(Spacer(1, 0.25*inch))

# Data table
story.append(Paragraph("Sales by Region", styles['Heading2']))

data = [
    ['Region', 'Sales', 'Growth'],
    ['North', '$120,000', '+15%'],
    ['South', '$95,000', '+8%'],
    ['East', '$110,000', '+12%'],
    ['West', '$105,000', '+10%'],
]

table = Table(data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472C4')),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 12),
    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
]))

story.append(table)
story.append(Spacer(1, 0.5*inch))

# Next section
story.append(PageBreak())
story.append(Paragraph("Detailed Analysis", styles['Heading1']))

doc.build(story)
```

### Create Certificate

```python
from reportlab.lib.pagesizes import landscape, letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch

c = canvas.Canvas("certificate.pdf", pagesize=landscape(letter))
width, height = landscape(letter)

# Border
c.setLineWidth(3)
c.rect(0.5*inch, 0.5*inch, width - inch, height - inch)

# Title
c.setFont("Helvetica-Bold", 36)
title = "Certificate of Achievement"
title_width = c.stringWidth(title, "Helvetica-Bold", 36)
c.drawString((width - title_width) / 2, height - 1.5*inch, title)

# Recipient
c.setFont("Helvetica", 16)
text = "This certificate is presented to"
text_width = c.stringWidth(text, "Helvetica", 16)
c.drawString((width - text_width) / 2, height - 2.5*inch, text)

# Name
c.setFont("Helvetica-Bold", 28)
name = "John Doe"
name_width = c.stringWidth(name, "Helvetica-Bold", 28)
c.drawString((width - name_width) / 2, height - 3.2*inch, name)

# Line under name
c.line(2*inch, height - 3.3*inch, width - 2*inch, height - 3.3*inch)

# Description
c.setFont("Helvetica", 14)
desc = "For outstanding performance in Data Engineering"
desc_width = c.stringWidth(desc, "Helvetica", 14)
c.drawString((width - desc_width) / 2, height - 4*inch, desc)

# Date and signature
c.setFont("Helvetica", 12)
c.drawString(1.5*inch, 1.5*inch, "Date: November 24, 2024")

c.line(width - 3*inch, 1.3*inch, width - 1*inch, 1.3*inch)
c.drawString(width - 2.8*inch, 1*inch, "Authorized Signature")

c.save()
```

## Key Features

### Text and Fonts

```python
# Canvas approach
c.setFont("Helvetica", 12)  # Regular
c.setFont("Helvetica-Bold", 14)  # Bold
c.setFont("Times-Roman", 10)  # Times

# Available fonts:
# - Helvetica, Helvetica-Bold, Helvetica-Oblique
# - Times-Roman, Times-Bold, Times-Italic
# - Courier, Courier-Bold, Courier-Oblique
```

### Colors

```python
from reportlab.lib.colors import red, blue, green, black, grey

c.setFillColor(red)
c.drawString(100, 700, "Red text")
c.setFillColor(black)
```

### Tables

```python
from reportlab.platypus import Table, TableStyle
from reportlab.lib import colors

data = [
    ['Column 1', 'Column 2', 'Column 3'],
    ['Data 1', 'Data 2', 'Data 3'],
]

table = Table(data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('GRID', (0, 0), (-1, -1), 1, colors.black),
]))
```

### Images

```python
# Canvas
c.drawImage("logo.png", 100, 700, width=100, height=50)

# Platypus
from reportlab.platypus import Image
img = Image("photo.jpg", width=300, height=200)
story.append(img)
```

### Page Breaks

```python
from reportlab.platypus import PageBreak

story.append(Paragraph("Page 1 content", styles['Normal']))
story.append(PageBreak())
story.append(Paragraph("Page 2 content", styles['Normal']))
```

### Headers and Footers

```python
def add_header_footer(canvas, doc):
    canvas.saveState()
    width, height = letter
    
    # Header
    canvas.setFont('Helvetica-Bold', 10)
    canvas.drawString(inch, height - 0.5*inch, "Report Header")
    
    # Footer
    canvas.setFont('Helvetica', 8)
    canvas.drawRightString(width - inch, 0.5*inch, f"Page {doc.page}")
    
    canvas.restoreState()

doc.build(story, onFirstPage=add_header_footer, 
          onLaterPages=add_header_footer)
```

## Tips and Best Practices

### Coordinate System
- Origin (0,0) is bottom-left
- Work from top: `y = height - margin`
- Use units for clarity: `from reportlab.lib.units import inch`

### Text Positioning
```python
y = height - 100  # Start from top
line_height = 20

c.drawString(100, y, "Line 1")
y -= line_height
c.drawString(100, y, "Line 2")
```

### Page Sizes
```python
from reportlab.lib.pagesizes import letter, A4, legal, landscape

# US Letter: 8.5" x 11"
doc = SimpleDocTemplate("file.pdf", pagesize=letter)

# A4
doc = SimpleDocTemplate("file.pdf", pagesize=A4)

# Landscape
doc = SimpleDocTemplate("file.pdf", pagesize=landscape(letter))
```

### Multi-page Canvas
```python
c = canvas.Canvas("multi.pdf", pagesize=letter)

# Page 1
c.drawString(100, 700, "Page 1")
c.showPage()  # Start new page

# Page 2
c.drawString(100, 700, "Page 2")
c.showPage()

c.save()
```

## Common Patterns

### Data Export to PDF
```python
import pandas as pd
from reportlab.platypus import SimpleDocTemplate, Table, Paragraph
from reportlab.lib.styles import getSampleStyleSheet

# Load data
df = pd.read_csv("data.csv")

doc = SimpleDocTemplate("export.pdf")
story = []
styles = getSampleStyleSheet()

story.append(Paragraph("Data Export", styles['Title']))

# Convert DataFrame to table
data = [df.columns.tolist()] + df.values.tolist()
table = Table(data)
story.append(table)

doc.build(story)
```

### Form with Fields
```python
c = canvas.Canvas("form.pdf", pagesize=letter)
width, height = letter

# Form title
c.setFont("Helvetica-Bold", 16)
c.drawString(100, height - 100, "Application Form")

# Fields
y = height - 150
c.setFont("Helvetica", 12)

fields = ["Name:", "Email:", "Phone:", "Address:"]
for field in fields:
    c.drawString(100, y, field)
    c.line(200, y, 500, y)  # Line for writing
    y -= 40

c.save()
```

## Error Handling

```python
try:
    c = canvas.Canvas("output.pdf", pagesize=letter)
    # ... drawing operations
    c.save()
    print("PDF created successfully")
except Exception as e:
    print(f"Error creating PDF: {e}")
```

## Success Criteria

A successful PDF includes:
1. **Readable content** - Appropriate fonts and sizes
2. **Proper layout** - Good spacing and alignment
3. **Professional appearance** - Clean design
4. **Complete data** - All required information
5. **Correct format** - Valid PDF file
6. **Appropriate page size** - Letter, A4, or custom

## Additional Resources

**Read reportlab_guide.md for:**
- Detailed Canvas techniques
- Advanced Platypus features
- Complex table styling
- Template examples
- Troubleshooting tips
