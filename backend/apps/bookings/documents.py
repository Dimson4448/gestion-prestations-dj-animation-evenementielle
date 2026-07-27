from io import BytesIO

from django.utils import timezone
from django.utils.html import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


NAVY = colors.HexColor("#0B1020")
CYAN = colors.HexColor("#00C8F0")
MAGENTA = colors.HexColor("#FF2E88")
LIGHT = colors.HexColor("#F3F6FA")
MUTED = colors.HexColor("#526079")


def _styles():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name="Brand", parent=styles["Title"], textColor=NAVY, fontSize=22, leading=26))
    styles.add(ParagraphStyle(name="DocumentTitle", parent=styles["Heading1"], textColor=MAGENTA, fontSize=15))
    styles.add(ParagraphStyle(name="Section", parent=styles["Heading2"], textColor=NAVY, fontSize=11, spaceBefore=8))
    styles.add(ParagraphStyle(name="Right", parent=styles["BodyText"], alignment=TA_RIGHT, textColor=MUTED))
    styles.add(ParagraphStyle(name="Small", parent=styles["BodyText"], fontSize=8, leading=11, textColor=MUTED))
    return styles


def _header_footer(canvas, document):
    canvas.saveState()
    width, height = A4
    canvas.setFillColor(NAVY)
    canvas.rect(0, height - 14 * mm, width, 14 * mm, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0, height - 14 * mm, 45 * mm, 2 * mm, fill=1, stroke=0)
    canvas.setFillColor(MAGENTA)
    canvas.rect(45 * mm, height - 14 * mm, 25 * mm, 2 * mm, fill=1, stroke=0)
    canvas.setFillColor(MUTED)
    canvas.setFont("Helvetica", 8)
    canvas.drawString(18 * mm, 12 * mm, "Ultimate DJ - Document généré par l'application")
    canvas.drawRightString(width - 18 * mm, 12 * mm, f"Page {document.page}")
    canvas.restoreState()


def _document(story):
    output = BytesIO()
    document = SimpleDocTemplate(
        output,
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=24 * mm,
        bottomMargin=22 * mm,
        title="Ultimate DJ",
        author="Ultimate DJ",
    )
    document.build(story, onFirstPage=_header_footer, onLaterPages=_header_footer)
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


def build_contract_pdf(contract):
    styles = _styles()
    booking = contract.booking
    client = booking.client
    signed = timezone.localtime(contract.signed_by_client_at).strftime("%d/%m/%Y à %H:%M") if contract.signed_by_client_at else "Non signé"
    story = [
        Spacer(1, 6 * mm),
        Paragraph("ULTIMATE <font color='#00A9D6'>DJ</font>", styles["Brand"]),
        Paragraph("CONTRAT DE PRESTATION DJ", styles["DocumentTitle"]),
        Paragraph(f"Contrat {escape(contract.contract_number)}", styles["Right"]),
        Spacer(1, 8 * mm),
        Paragraph("Parties", styles["Section"]),
        _details_table([
            ("Prestataire", "Ultimate DJ - Belgique"),
            ("Client", client.user.get_full_name() or client.user.username),
            ("Adresse de facturation", f"{client.billing_address}, {client.billing_postal_code} {client.billing_city}"),
            ("E-mail", client.user.email or "Non renseigné"),
        ], styles),
        Paragraph("Prestation", styles["Section"]),
        _details_table([
            ("Événement", booking.event_type.name),
            ("Formule", booking.package.name),
            ("DJ", booking.dj.stage_name),
            ("Date et horaire", f"{booking.event_date:%d/%m/%Y}, de {booking.start_time:%H:%M} à {booking.end_time:%H:%M}"),
            ("Lieu", f"{booking.venue.name}, {booking.venue.street}, {booking.venue.postal_code} {booking.venue.city}"),
            ("Montant total", f"{booking.total_amount:.2f} EUR"),
            ("Acompte requis", f"{booking.deposit_required:.2f} EUR"),
        ], styles),
        Paragraph("Conditions", styles["Section"]),
        Paragraph(escape(contract.refund_policy), styles["BodyText"]),
        Spacer(1, 4 * mm),
        Paragraph("Signature électronique", styles["Section"]),
        _details_table([("Statut", contract.get_status_display()), ("Signé par le client", signed)], styles),
        Spacer(1, 8 * mm),
        Paragraph("La signature électronique confirme l'acceptation des informations de prestation et des conditions affichées dans ce document.", styles["Small"]),
    ]
    return _document(story)


def build_invoice_pdf(invoice):
    styles = _styles()
    booking = invoice.booking
    client = booking.client
    story = [
        Spacer(1, 6 * mm),
        Paragraph("ULTIMATE <font color='#00A9D6'>DJ</font>", styles["Brand"]),
        Paragraph("FACTURE D'ACOMPTE", styles["DocumentTitle"]),
        Paragraph(f"Facture {escape(invoice.invoice_number)}", styles["Right"]),
        Spacer(1, 8 * mm),
        _details_table([
            ("Émetteur", "Ultimate DJ - Belgique"),
            ("Client", client.user.get_full_name() or client.user.username),
            ("Adresse de facturation", f"{client.billing_address}, {client.billing_postal_code} {client.billing_city}"),
            ("Date d'émission", timezone.localtime(invoice.issued_at).strftime("%d/%m/%Y")),
            ("Date d'échéance", timezone.localtime(invoice.due_at).strftime("%d/%m/%Y")),
            ("Statut", invoice.get_status_display()),
        ], styles),
        Paragraph("Détail", styles["Section"]),
        _details_table([
            ("Prestation", f"Acompte - {booking.package.name}"),
            ("Événement", f"{booking.event_type.name} du {booking.event_date:%d/%m/%Y}"),
            ("Réservation", f"N° {booking.pk}"),
            ("Montant de l'acompte", f"{invoice.amount:.2f} EUR"),
            ("Montant total de la prestation", f"{booking.total_amount:.2f} EUR"),
        ], styles),
        Spacer(1, 9 * mm),
        Paragraph(f"<b>TOTAL À PAYER : {invoice.amount:.2f} EUR</b>", styles["DocumentTitle"]),
        Spacer(1, 5 * mm),
        Paragraph("Le paiement en ligne est traité de manière sécurisée par Stripe. La facture passe automatiquement au statut payé après confirmation du paiement.", styles["Small"]),
    ]
    return _document(story)
