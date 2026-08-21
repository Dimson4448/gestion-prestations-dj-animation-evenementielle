from io import BytesIO
from pathlib import Path

from django.conf import settings
from django.utils import timezone
from django.utils.html import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas as pdf_canvas
from reportlab.platypus import Image, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


NAVY = colors.HexColor("#0B1020")
CYAN = colors.HexColor("#00C8F0")
MAGENTA = colors.HexColor("#FF2E88")
GOLD = colors.HexColor("#FFC247")
PURPLE = NAVY
PURPLE_LIGHT = colors.HexColor("#EAF9FD")
CYAN_DARK = colors.HexColor("#008FB2")
LIGHT = colors.HexColor("#F3F6FA")
MUTED = colors.HexColor("#526079")
LOGO_PATH = Path(settings.BASE_DIR) / "static" / "images" / "logo-ultimate-dj.png"


class ConditionalPageNumberCanvas(pdf_canvas.Canvas):
    """Affiche la pagination uniquement lorsque le document compte plusieurs pages."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        page_count = len(self._saved_page_states)
        for page_state in self._saved_page_states:
            self.__dict__.update(page_state)
            if page_count > 1:
                self.saveState()
                self.setFillColor(colors.white)
                self.setFont("Helvetica", 8)
                self.drawRightString(A4[0] - 18 * mm, 7 * mm, f"Page {self._pageNumber} / {page_count}")
                self.restoreState()
            super().showPage()
        super().save()


def _styles():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name="Brand", parent=styles["Title"], textColor=NAVY, fontSize=22, leading=26))
    styles.add(ParagraphStyle(name="DocumentTitle", parent=styles["Heading1"], textColor=MAGENTA, fontSize=15))
    styles.add(ParagraphStyle(name="Section", parent=styles["Heading2"], textColor=NAVY, fontSize=11, spaceBefore=8))
    styles.add(ParagraphStyle(name="Right", parent=styles["BodyText"], alignment=TA_RIGHT, textColor=MUTED))
    styles.add(ParagraphStyle(name="Small", parent=styles["BodyText"], fontSize=8, leading=11, textColor=MUTED))
    styles.add(ParagraphStyle(name="InvoiceHero", parent=styles["Title"], textColor=NAVY, fontSize=30, leading=32, alignment=TA_RIGHT))
    styles.add(ParagraphStyle(name="InvoiceNumber", parent=styles["Heading2"], textColor=colors.white, fontSize=14, leading=18, alignment=TA_CENTER))
    styles.add(ParagraphStyle(name="BoxTitle", parent=styles["Heading2"], textColor=CYAN_DARK, fontSize=10, leading=13, spaceAfter=5))
    styles.add(ParagraphStyle(name="InvoiceTotal", parent=styles["Heading2"], textColor=colors.white, fontSize=12, leading=16))
    styles.add(ParagraphStyle(name="InvoiceTableHeader", parent=styles["Small"], textColor=colors.white, fontSize=8, leading=10))
    return styles


def _header_footer(canvas, document):
    canvas.saveState()
    width, height = A4
    canvas.setFillColor(NAVY)
    canvas.rect(0, height - 14 * mm, width, 14 * mm, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0, height - 14 * mm, width / 2, 2 * mm, fill=1, stroke=0)
    canvas.setFillColor(MAGENTA)
    canvas.rect(width / 2, height - 14 * mm, width / 2, 2 * mm, fill=1, stroke=0)
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, width, 16 * mm, fill=1, stroke=0)
    canvas.setFillColor(GOLD)
    canvas.rect(0, 16 * mm, width, 1.2 * mm, fill=1, stroke=0)
    canvas.setFillColor(colors.white)
    canvas.setFont("Helvetica", 8)
    canvas.drawString(18 * mm, 7 * mm, f"{settings.BUSINESS_LEGAL_NAME} - Votre événement, votre ambiance")
    canvas.restoreState()


def _document(story, *, top_margin=24 * mm, bottom_margin=22 * mm):
    output = BytesIO()
    document = SimpleDocTemplate(
        output,
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=top_margin,
        bottomMargin=bottom_margin,
        title=settings.BUSINESS_LEGAL_NAME,
        author=settings.BUSINESS_LEGAL_NAME,
    )
    document.build(
        story,
        onFirstPage=_header_footer,
        onLaterPages=_header_footer,
        canvasmaker=ConditionalPageNumberCanvas,
    )
    return output.getvalue()


def _details_table(rows, styles):
    data = [[Paragraph(f"<b>{escape(str(label))}</b>", styles["BodyText"]), Paragraph(escape(str(value)), styles["BodyText"])] for label, value in rows]
    table = Table(data, colWidths=[52 * mm, 104 * mm], hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, -1), LIGHT),
        ("TEXTCOLOR", (0, 0), (-1, -1), NAVY),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#D6DEEA")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))
    return table


def _invoice_lines_table(invoice, booking, description, styles):
    header = [
        Paragraph("<b>DESCRIPTION</b>", styles["InvoiceTableHeader"]),
        Paragraph("<b>DATE</b>", styles["InvoiceTableHeader"]),
        Paragraph("<b>QTÉ</b>", styles["InvoiceTableHeader"]),
        Paragraph("<b>PRIX UNITAIRE</b>", styles["InvoiceTableHeader"]),
        Paragraph("<b>TOTAL</b>", styles["InvoiceTableHeader"]),
    ]
    line = [
        Paragraph(escape(description), styles["BodyText"]),
        Paragraph(booking.event_date.strftime("%d/%m/%Y"), styles["BodyText"]),
        Paragraph("1", styles["BodyText"]),
        Paragraph(f"{invoice.amount:.2f} EUR", styles["Right"]),
        Paragraph(f"{invoice.amount:.2f} EUR", styles["Right"]),
    ]
    table = Table([header, line], colWidths=[64 * mm, 27 * mm, 13 * mm, 27 * mm, 27 * mm], hAlign="LEFT")
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("BACKGROUND", (0, 1), (-1, -1), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#C8D2E1")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("ALIGN", (2, 0), (-1, -1), "RIGHT"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return table


def _invoice_totals_table(invoice, paid_amount, refunded_amount, styles):
    remaining = max(invoice.amount - paid_amount + refunded_amount, 0)
    rows = [
        [Paragraph("Sous-total", styles["BodyText"]), Paragraph(f"{invoice.amount:.2f} EUR", styles["Right"])],
        [Paragraph("Montant encaissé", styles["BodyText"]), Paragraph(f"{paid_amount:.2f} EUR", styles["Right"])],
        [Paragraph("Remboursé", styles["BodyText"]), Paragraph(f"{refunded_amount:.2f} EUR", styles["Right"])],
        [Paragraph("<font color='#FFFFFF'><b>RESTE À PAYER</b></font>", styles["BodyText"]), Paragraph(f"<font color='#FFFFFF'><b>{remaining:.2f} EUR</b></font>", styles["Right"])],
    ]
    table = Table(rows, colWidths=[52 * mm, 38 * mm], hAlign="RIGHT")
    table.setStyle(TableStyle([
        ("LINEABOVE", (0, -1), (-1, -1), 1.2, MAGENTA),
        ("BACKGROUND", (0, -1), (-1, -1), NAVY),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
    ]))
    return table


def _money(amount):
    return f"{amount:,.2f} EUR".replace(",", " ").replace(".", ",")


def _invoice_party_box(title, rows, styles):
    content = [Paragraph(escape(str(value)), styles["BodyText"]) for value in rows if value]
    box = Table([
        [Paragraph(title, styles["BoxTitle"])],
        [content],
    ], colWidths=[75 * mm], rowHeights=[9 * mm, None], minRowHeights=[9 * mm, 30 * mm])
    box.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#9DDDEA")),
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE_LIGHT),
        ("LINEBELOW", (0, 0), (-1, 0), 1.2, CYAN),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 9),
        ("RIGHTPADDING", (0, 0), (-1, -1), 9),
        ("TOPPADDING", (0, 0), (-1, 0), 6),
        ("BOTTOMPADDING", (0, 0), (-1, 0), 4),
        ("TOPPADDING", (0, 1), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 1), (-1, -1), 7),
    ]))
    return box


def _invoice_status_label(invoice):
    return {
        invoice.DRAFT: "BROUILLON",
        invoice.SENT: "EN ATTENTE DE PAIEMENT",
        invoice.PAID: "PAYÉE",
        invoice.CANCELLED: "ANNULÉE",
    }.get(invoice.status, invoice.get_status_display().upper())


def _brand_logo(styles):
    if not LOGO_PATH.is_file():
        return Paragraph("ULTIMATE <font color='#00A9D6'>DJ</font>", styles["Brand"])

    logo = Image(str(LOGO_PATH), width=24 * mm, height=27 * mm)
    logo.hAlign = "LEFT"
    return logo


def _brand_identity(styles, width):
    brand_style = styles["Brand"]
    if width <= 64 * mm:
        brand_style = ParagraphStyle(name="BrandCompact", parent=styles["Brand"], fontSize=15, leading=18)
    details = [
        Paragraph("<b>ULTIMATE <font color='#00C8F0'>DJ</font></b>", brand_style),
        Paragraph("DJ & animation événementielle", styles["Small"]),
    ]
    if settings.BUSINESS_PHONE:
        details.append(Paragraph(escape(settings.BUSINESS_PHONE), styles["Small"]))
    if settings.BUSINESS_EMAIL:
        details.append(Paragraph(escape(settings.BUSINESS_EMAIL), styles["Small"]))
    block = Table([[_brand_logo(styles), details]], colWidths=[27 * mm, width - 27 * mm])
    block.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
    ]))
    return block


def business_identity_rows(primary_label):
    rows = [(primary_label, settings.BUSINESS_LEGAL_NAME)]
    optional_fields = [
        ("Adresse du prestataire", settings.BUSINESS_ADDRESS),
        ("Numéro d'entreprise", settings.BUSINESS_COMPANY_NUMBER),
        ("Numéro de TVA", settings.BUSINESS_VAT_NUMBER),
        ("E-mail du prestataire", settings.BUSINESS_EMAIL),
        ("Téléphone du prestataire", settings.BUSINESS_PHONE),
        ("IBAN", settings.BUSINESS_IBAN),
    ]
    rows.extend((label, value) for label, value in optional_fields if value)
    return rows


def build_contract_pdf(contract):
    styles = _styles()
    styles.add(ParagraphStyle(
        name="ContractSmall",
        parent=styles["Small"],
        fontSize=8.5,
        leading=10.4,
        textColor=colors.HexColor("#27344D"),
    ))
    styles.add(ParagraphStyle(name="ContractTitle", parent=styles["InvoiceHero"], fontSize=26, leading=27))
    booking = contract.booking
    client = booking.client
    quote = booking.quote
    signed = timezone.localtime(contract.signed_by_client_at).strftime("%d/%m/%Y à %H:%M") if contract.signed_by_client_at else "En attente de signature"
    company_lines = [settings.BUSINESS_LEGAL_NAME, "DJ & animation événementielle"]
    company_lines.extend(filter(None, [settings.BUSINESS_ADDRESS, f"N° d’entreprise : {settings.BUSINESS_COMPANY_NUMBER}" if settings.BUSINESS_COMPANY_NUMBER else "", f"TVA : {settings.BUSINESS_VAT_NUMBER}" if settings.BUSINESS_VAT_NUMBER else "", settings.BUSINESS_PHONE, settings.BUSINESS_EMAIL]))
    client_lines = [client.user.get_full_name() or client.user.username, client.billing_address, f"{client.billing_postal_code} {client.billing_city}", client.phone, client.user.email]

    reference = Table([
        [Paragraph("CONTRAT DE PRESTATION", styles["ContractTitle"])],
        [Paragraph("DJ & ANIMATION ÉVÉNEMENTIELLE", styles["Right"])],
        [Paragraph(f"N° {escape(contract.contract_number)}", styles["InvoiceNumber"])],
        [Paragraph(f"<b>Date du contrat :</b> {timezone.localtime(contract.created_at):%d/%m/%Y}<br/><b>Date de l’événement :</b> {booking.event_date:%d/%m/%Y}<br/><b>Lieu :</b> {escape(booking.venue.name)}, {escape(booking.venue.city)}", styles["BodyText"])],
    ], colWidths=[94 * mm])
    reference.setStyle(TableStyle([
        ("BACKGROUND", (0, 2), (0, 2), NAVY),
        ("TOPPADDING", (0, 2), (0, 2), 5), ("BOTTOMPADDING", (0, 2), (0, 2), 5),
        ("TOPPADDING", (0, 3), (0, 3), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 8), ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ]))
    header = Table([[_brand_identity(styles, 64 * mm), reference]], colWidths=[64 * mm, 94 * mm])
    header.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP")]))
    def contract_party_box(title, lines):
        content = [Paragraph(escape(str(value)), styles["ContractSmall"]) for value in lines if value]
        box = Table([
            [Paragraph(title, styles["BoxTitle"])],
            [content],
        ], colWidths=[75 * mm], rowHeights=[8 * mm, None], minRowHeights=[8 * mm, 23 * mm])
        box.setStyle(TableStyle([
            ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#9DDDEA")),
            ("BACKGROUND", (0, 0), (-1, 0), PURPLE_LIGHT),
            ("LINEBELOW", (0, 0), (-1, 0), 1.1, CYAN),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 7), ("RIGHTPADDING", (0, 0), (-1, -1), 7),
            ("TOPPADDING", (0, 0), (-1, 0), 4), ("BOTTOMPADDING", (0, 0), (-1, 0), 3),
            ("TOPPADDING", (0, 1), (-1, -1), 5), ("BOTTOMPADDING", (0, 1), (-1, -1), 5),
        ]))
        return box

    parties = Table([[
        contract_party_box("PRESTATAIRE", company_lines),
        contract_party_box("CLIENT", client_lines),
    ]], colWidths=[79 * mm, 79 * mm])
    parties.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 4)]))

    sections = [
        ("1. OBJET DU CONTRAT", f"Le prestataire s’engage à assurer une prestation de DJ et d’animation pour l’événement {booking.event_type.name}."),
        ("2. PRESTATIONS INCLUSES", f"Formule {booking.package.name}. {booking.package.description} Durée convenue : {quote.duration_hours} heures. DJ affecté : {booking.dj.stage_name}."),
        ("3. HORAIRES", f"Début : {booking.event_date:%d/%m/%Y} à {booking.start_time:%H:%M}. Fin : {(booking.end_date or booking.event_date):%d/%m/%Y} à {booking.end_time:%H:%M}."),
        ("4. TARIF ET PAIEMENT", f"Montant total : {_money(booking.total_amount)}. Acompte demandé : {_money(booking.deposit_required)}. Le solde est réglé selon les échéances des factures émises."),
        ("5. OBLIGATIONS DU CLIENT", "Le client garantit l’accès au lieu, une alimentation électrique adaptée, la sécurité des installations et le respect des horaires convenus."),
        ("6. ANNULATION", contract.refund_policy),
        ("7. DISPOSITIONS DIVERSES", "Le présent contrat est soumis au droit belge. Toute modification de la prestation doit être confirmée par écrit par les deux parties."),
    ]
    section_rows = []
    for title, body in sections:
        section_rows.append([Paragraph(title, styles["BoxTitle"]), Paragraph(escape(str(body)), styles["ContractSmall"])])
    clauses = Table(section_rows, colWidths=[39 * mm, 55 * mm])
    clauses.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#B9DDE7")),
        ("LINEBELOW", (0, 0), (-1, -2), 0.4, colors.HexColor("#D6EAF0")),
        ("BACKGROUND", (0, 0), (0, -1), PURPLE_LIGHT),
        ("LINEAFTER", (0, 0), (0, -1), 1, CYAN),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 7), ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))

    balance = booking.total_amount - booking.deposit_required
    price_box = Table([
        [Paragraph("DÉTAIL DU PRIX", styles["BoxTitle"]), ""],
        [Paragraph(escape(booking.package.name), styles["ContractSmall"]), Paragraph(_money(booking.total_amount), styles["Right"])],
        [Paragraph("Acompte requis", styles["ContractSmall"]), Paragraph(f"- {_money(booking.deposit_required)}", styles["Right"])],
        [Paragraph("<font color='#FFFFFF'><b>SOLDE RESTANT DÛ</b></font>", styles["ContractSmall"]), Paragraph(f"<font color='#FFFFFF'><b>{_money(balance)}</b></font>", styles["Right"])],
    ], colWidths=[35 * mm, 27 * mm])
    price_box.setStyle(TableStyle([
        ("SPAN", (0, 0), (-1, 0)), ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#B9DDE7")),
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE_LIGHT),
        ("LINEBELOW", (0, 0), (-1, 0), 1.1, CYAN),
        ("BACKGROUND", (0, -1), (-1, -1), NAVY), ("TEXTCOLOR", (0, -1), (-1, -1), colors.white),
        ("LINEABOVE", (0, -2), (-1, -2), 0.8, MAGENTA),
        ("LEFTPADDING", (0, 0), (-1, -1), 7), ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    info_box = contract_party_box("INFORMATIONS COMPLÉMENTAIRES", [
        f"Invités estimés : {quote.guest_count}",
        f"Type d’événement : {booking.event_type.name}",
        f"Lieu : {booking.venue.name}, {booking.venue.street}, {booking.venue.postal_code} {booking.venue.city}",
        f"Préférences musicales : {quote.music_preferences or 'À définir avec le DJ'}",
    ])
    right_column = Table([[price_box], [Spacer(1, 4 * mm)], [info_box]], colWidths=[64 * mm])
    right_column.setStyle(TableStyle([("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 0)]))
    body = Table([[clauses, right_column]], colWidths=[94 * mm, 64 * mm])
    body.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 4)]))

    signature = Table([
        [Paragraph("<b>LE PRESTATAIRE</b>", styles["BoxTitle"]), Paragraph("<b>LE CLIENT</b>", styles["BoxTitle"])],
        [Paragraph(f"{escape(settings.BUSINESS_LEGAL_NAME)}<br/><br/>Signature : ____________________", styles["ContractSmall"]), Paragraph(f"{escape(client.user.get_full_name() or client.user.username)}<br/>Statut : {escape(contract.get_status_display())}<br/>Signature électronique : {escape(signed)}", styles["ContractSmall"])],
    ], colWidths=[79 * mm, 79 * mm], rowHeights=[7 * mm, 18 * mm])
    signature.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#B9DDE7")), ("LINEAFTER", (0, 0), (0, -1), 0.8, colors.HexColor("#B9DDE7")),
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE_LIGHT),
        ("LINEBELOW", (0, 0), (-1, 0), 1.1, CYAN),
        ("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 9), ("RIGHTPADDING", (0, 0), (-1, -1), 9),
        ("TOPPADDING", (0, 0), (-1, -1), 4), ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    story = [
        header, Spacer(1, 3 * mm), parties, Spacer(1, 2.5 * mm),
        Paragraph("Le présent contrat définit les conditions dans lesquelles Ultimate DJ fournit au client la prestation décrite ci-dessous.", styles["ContractSmall"]),
        Spacer(1, 2.5 * mm), body, Spacer(1, 3 * mm), signature,
    ]
    if booking.status == booking.CANCELLED or contract.status == contract.CANCELLED:
        story.append(Paragraph(f"<b>CONTRAT ANNULÉ :</b> {escape(booking.cancellation_reason or 'motif non renseigné')}", styles["Small"]))
    return _document(story, top_margin=18 * mm, bottom_margin=17 * mm)


def build_invoice_pdf(invoice):
    styles = _styles()
    booking = invoice.booking
    client = booking.client
    invoice_titles = {
        invoice.DEPOSIT: "FACTURE D'ACOMPTE",
        invoice.BALANCE: "FACTURE DE SOLDE",
        invoice.FULL: "FACTURE DE PRESTATION",
    }
    detail_labels = {invoice.DEPOSIT: "Acompte", invoice.BALANCE: "Solde", invoice.FULL: "Prestation complète"}
    payments = list(invoice.payments.prefetch_related("refunds").all())
    paid_amount = sum((payment.amount for payment in payments if payment.status in {payment.PAID, payment.REFUNDED}), 0)
    refunded_amount = sum((refund.amount for payment in payments for refund in payment.refunds.all() if refund.status == refund.SUCCEEDED), 0)
    company_lines = [settings.BUSINESS_LEGAL_NAME, "DJ & animation événementielle"]
    company_lines.extend(filter(None, [settings.BUSINESS_ADDRESS, f"N° d’entreprise : {settings.BUSINESS_COMPANY_NUMBER}" if settings.BUSINESS_COMPANY_NUMBER else "", f"TVA : {settings.BUSINESS_VAT_NUMBER}" if settings.BUSINESS_VAT_NUMBER else "", settings.BUSINESS_PHONE, settings.BUSINESS_EMAIL]))
    client_lines = [
        client.user.get_full_name() or client.user.username,
        client.billing_address,
        f"{client.billing_postal_code} {client.billing_city}",
        client.phone,
        client.user.email,
    ]
    invoice_reference = Table([
        [Paragraph("FACTURE", styles["InvoiceHero"])],
        [Paragraph(f"N° {escape(invoice.invoice_number)}<br/><font size='8'>{invoice_titles[invoice.invoice_type]}</font>", styles["InvoiceNumber"])],
        [Paragraph(f"<b>Date de facture :</b> {timezone.localtime(invoice.issued_at):%d/%m/%Y}<br/><b>Date d’échéance :</b> {timezone.localtime(invoice.due_at):%d/%m/%Y}<br/><b>Référence prestation :</b> UDJ-PREST-{booking.pk:06d}", styles["BodyText"])],
    ], colWidths=[78 * mm])
    invoice_reference.setStyle(TableStyle([
        ("BACKGROUND", (0, 1), (0, 1), PURPLE),
        ("TOPPADDING", (0, 1), (0, 1), 7),
        ("BOTTOMPADDING", (0, 1), (0, 1), 7),
        ("TOPPADDING", (0, 2), (0, 2), 8),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ]))
    event_box = Table([[
        Paragraph("<b>ÉVÉNEMENT</b>", styles["BoxTitle"]),
        Paragraph(f"<b>{escape(booking.event_type.name)}</b><br/>{escape(booking.package.name)}", styles["BodyText"]),
        Paragraph(f"<b>Date :</b> {booking.event_date:%d/%m/%Y}<br/>{booking.start_time:%H:%M} au {(booking.end_date or booking.event_date):%d/%m/%Y} {booking.end_time:%H:%M}", styles["BodyText"]),
        Paragraph(f"<b>Lieu :</b> {escape(booking.venue.name)}<br/>{escape(booking.venue.city)}", styles["BodyText"]),
    ]], colWidths=[28 * mm, 48 * mm, 39 * mm, 43 * mm])
    event_box.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 0.8, colors.HexColor("#9DDDEA")),
        ("BACKGROUND", (0, 0), (0, 0), PURPLE_LIGHT),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    header = Table([[_brand_identity(styles, 80 * mm), invoice_reference]], colWidths=[80 * mm, 78 * mm])
    header.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP")]))
    parties = Table([[
        _invoice_party_box("PRESTATAIRE", company_lines, styles),
        _invoice_party_box("FACTURÉ À", client_lines, styles),
    ]], colWidths=[79 * mm, 79 * mm])
    parties.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 4)]))
    payment_box = _invoice_party_box("MODE DE PAIEMENT", [
        "Paiement en ligne sécurisé par Stripe",
        f"IBAN : {settings.BUSINESS_IBAN}" if settings.BUSINESS_IBAN else "",
        f"Communication : {invoice.invoice_number}",
    ], styles)
    status_box = Table([[Paragraph(f"STATUT : {_invoice_status_label(invoice)}", styles["BoxTitle"])]], colWidths=[75 * mm])
    status_box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#FFF4D6") if invoice.status == invoice.SENT else PURPLE_LIGHT),
        ("BOX", (0, 0), (-1, -1), 0.8, GOLD),
        ("LEFTPADDING", (0, 0), (-1, -1), 9), ("RIGHTPADDING", (0, 0), (-1, -1), 9),
        ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    story = [
        Spacer(1, 3 * mm), header, Spacer(1, 7 * mm), parties, Spacer(1, 6 * mm), event_box,
        Spacer(1, 7 * mm),
        _invoice_lines_table(invoice, booking, f"{detail_labels[invoice.invoice_type]} - {booking.package.name} - réservation n°{booking.pk}", styles),
        Spacer(1, 7 * mm),
        Table([[payment_box, _invoice_totals_table(invoice, paid_amount, refunded_amount, styles)]], colWidths=[79 * mm, 79 * mm], style=[("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 4)]),
        Spacer(1, 6 * mm), status_box, Spacer(1, 5 * mm),
        Paragraph("Merci pour votre confiance.", styles["Small"]),
        Paragraph(f"Montant total de la prestation : {_money(booking.total_amount)}.", styles["Small"]),
    ]
    if invoice.status == invoice.CANCELLED:
        story.extend([
            Paragraph(f"<b>Document annulé :</b> {escape(booking.cancellation_reason or 'facture annulée à la suite de la régularisation du dossier.')}", styles["Small"]),
        ])
    return _document(story)
