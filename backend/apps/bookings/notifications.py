from django.conf import settings
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.db import transaction

from apps.accounts.emailing import localized, preferred_language
from apps.accounts.models import Notification
from apps.accounts.notifications import create_notification_after_commit, notify_administrators_after_commit


def _send_after_commit(subject, message, recipients):
    recipients = [email for email in recipients if email]
    if not recipients:
        return
    transaction.on_commit(
        lambda: send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipients, fail_silently=settings.EMAIL_FAIL_SILENTLY)
    )


def _send_localized(user, subjects, messages, context):
    language = preferred_language(user)
    context = {
        key: localized(value, language) if isinstance(value, dict) and "fr" in value else value
        for key, value in context.items()
    }
    subject = localized(subjects, language).format(**context)
    message = localized(messages, language).format(**context)
    _send_after_commit(subject, message, [user.email])
    link = "/administration" if user.is_staff else ("/dj" if hasattr(user, "dj_profile") else "/compte")
    create_notification_after_commit(user, subject, message, Notification.BOOKING, link)


def notify_quote_created(quote):
    client_user = quote.client.user
    context = {"number": quote.pk, "date": quote.event_date.strftime("%d/%m/%Y")}
    _send_localized(
        client_user,
        {"fr": "Ultimate DJ - demande de devis n°{number} reçue", "en": "Ultimate DJ - quote request #{number} received", "nl": "Ultimate DJ - offerteaanvraag nr. {number} ontvangen"},
        {
            "fr": "Votre demande de devis n°{number} pour le {date} a bien été enregistrée. Vous serez averti de chaque décision dans votre espace client et par e-mail.",
            "en": "Your quote request #{number} for {date} has been recorded. You will be notified of each decision in your client area and by email.",
            "nl": "Uw offerteaanvraag nr. {number} voor {date} werd geregistreerd. U wordt via uw klantenruimte en per e-mail op de hoogte gehouden.",
        }, context,
    )
    notify_administrators_after_commit(
        {"fr": "Ultimate DJ - nouveau devis n°{number}", "en": "Ultimate DJ - new quote #{number}", "nl": "Ultimate DJ - nieuwe offerte nr. {number}"},
        {"fr": "Une nouvelle demande de devis n°{number} est à traiter pour le {date}.", "en": "A new quote request #{number} requires processing for {date}.", "nl": "Een nieuwe offerteaanvraag nr. {number} moet worden behandeld voor {date}."},
        context,
    )


def notify_quote_sent_to_dj(quote):
    """Avertit le DJ uniquement après la validation administrative du devis."""
    if not quote.requested_dj_id:
        return
    _send_localized(
        quote.requested_dj.user,
        {"fr": "Ultimate DJ - demande de prestation à examiner", "en": "Ultimate DJ - booking request to review", "nl": "Ultimate DJ - opdrachtaanvraag te beoordelen"},
        {
            "fr": "L'administration a validé la demande n°{number}, prévue le {date}. Vous pouvez maintenant l'accepter ou la refuser dans votre espace DJ.",
            "en": "The administration validated request #{number}, scheduled for {date}. You can now accept or decline it in your DJ area.",
            "nl": "De administratie valideerde aanvraag nr. {number}, gepland op {date}. U kunt deze nu aanvaarden of weigeren in uw DJ-ruimte.",
        },
        {"number": quote.pk, "date": quote.event_date.strftime("%d/%m/%Y")},
    )


def notify_quote_refused(quote):
    _send_localized(
        quote.client.user,
        {"fr": "Ultimate DJ - demande de devis n°{number} refusée par le DJ", "en": "Ultimate DJ - quote request #{number} declined by the DJ", "nl": "Ultimate DJ - offerteaanvraag nr. {number} geweigerd door de DJ"},
        {
            "fr": "Le DJ sollicité n'est pas disponible pour votre demande n°{number}. L'administration peut vous proposer un autre DJ.",
            "en": "The requested DJ is unavailable for quote #{number}. The administration can suggest another DJ.",
            "nl": "De gekozen DJ is niet beschikbaar voor aanvraag nr. {number}. De administratie kan een andere DJ voorstellen.",
        }, {"number": quote.pk},
    )
    notify_administrators_after_commit(
        {"fr": "Ultimate DJ - devis n°{number} refusé", "en": "Ultimate DJ - quote #{number} declined", "nl": "Ultimate DJ - offerte nr. {number} geweigerd"},
        {"fr": "Le DJ a refusé le devis n°{number}. Une autre affectation peut être proposée.", "en": "The DJ declined quote #{number}. Another assignment can be proposed.", "nl": "De dj heeft offerte nr. {number} geweigerd. Er kan een andere toewijzing worden voorgesteld."},
        {"number": quote.pk},
    )


def notify_quote_accepted(booking, contract, invoice):
    context = {
        "booking": booking.pk,
        "date": booking.event_date.strftime("%d/%m/%Y"),
        "contract": contract.contract_number,
        "invoice": invoice.invoice_number,
    }
    _send_localized(
        booking.client.user,
        {"fr": "Ultimate DJ - prestation n°{booking} acceptée", "en": "Ultimate DJ - booking #{booking} accepted", "nl": "Ultimate DJ - opdracht nr. {booking} aanvaard"},
        {
            "fr": "Votre prestation du {date} est acceptée. Le contrat {contract} et la facture d'acompte {invoice} sont disponibles dans votre espace client.",
            "en": "Your booking for {date} has been accepted. Contract {contract} and deposit invoice {invoice} are available in your client area.",
            "nl": "Uw opdracht van {date} werd aanvaard. Contract {contract} en voorschotfactuur {invoice} zijn beschikbaar in uw klantenruimte.",
        }, context,
    )
    notify_administrators_after_commit(
        {"fr": "Ultimate DJ - devis accepté, réservation n°{booking}", "en": "Ultimate DJ - quote accepted, booking #{booking}", "nl": "Ultimate DJ - offerte aanvaard, reservatie nr. {booking}"},
        {"fr": "La réservation n°{booking} a été créée pour le {date}. Contrat {contract} et facture {invoice} générés.", "en": "Booking #{booking} was created for {date}. Contract {contract} and invoice {invoice} were generated.", "nl": "Reservatie nr. {booking} werd aangemaakt voor {date}. Contract {contract} en factuur {invoice} werden aangemaakt."},
        context,
    )


def notify_contract_signed(contract):
    booking = contract.booking
    context = {"contract": contract.contract_number, "booking": booking.pk}
    _send_localized(
        booking.client.user,
        {"fr": "Ultimate DJ - contrat {contract} signé", "en": "Ultimate DJ - contract {contract} signed", "nl": "Ultimate DJ - contract {contract} ondertekend"},
        {
            "fr": "Votre signature du contrat {contract} a été enregistrée pour la réservation n°{booking}.",
            "en": "Your signature of contract {contract} has been recorded for booking #{booking}.",
            "nl": "Uw handtekening van contract {contract} werd geregistreerd voor reservatie nr. {booking}.",
        }, context,
    )
    notify_administrators_after_commit(
        {"fr": "Ultimate DJ - contrat {contract} signé", "en": "Ultimate DJ - contract {contract} signed", "nl": "Ultimate DJ - contract {contract} ondertekend"},
        {"fr": "Le contrat {contract} de la réservation n°{booking} vient d'être signé.", "en": "Contract {contract} for booking #{booking} was just signed.", "nl": "Contract {contract} voor reservatie nr. {booking} werd zojuist ondertekend."},
        context,
    )


def notify_balance_invoice_created(booking, invoice):
    _send_localized(
        booking.client.user,
        {"fr": "Ultimate DJ - facture de solde {invoice}", "en": "Ultimate DJ - balance invoice {invoice}", "nl": "Ultimate DJ - saldofactuur {invoice}"},
        {
            "fr": "La prestation n°{booking} est clôturée. Votre facture de solde {invoice}, d'un montant de {amount} EUR, est disponible dans votre espace client.",
            "en": "Booking #{booking} has been completed. Your balance invoice {invoice}, for {amount} EUR, is available in your client area.",
            "nl": "Opdracht nr. {booking} is voltooid. Uw saldofactuur {invoice} van {amount} EUR is beschikbaar in uw klantenruimte.",
        },
        {"booking": booking.pk, "invoice": invoice.invoice_number, "amount": f"{invoice.amount:.2f}"},
    )


def notify_booking_cancelled(booking, reason):
    _send_localized(
        booking.client.user,
        {"fr": "Ultimate DJ - réservation n°{booking} annulée", "en": "Ultimate DJ - booking #{booking} cancelled", "nl": "Ultimate DJ - reservatie nr. {booking} geannuleerd"},
        {
            "fr": "Votre réservation n°{booking} du {date} a été annulée.\n\nMotif : {reason}",
            "en": "Your booking #{booking} on {date} has been cancelled.\n\nReason: {reason}",
            "nl": "Uw reservatie nr. {booking} op {date} werd geannuleerd.\n\nReden: {reason}",
        },
        {"booking": booking.pk, "date": booking.event_date.strftime("%d/%m/%Y"), "reason": reason},
    )


def notify_appointment_changed(appointment, actor):
    booking = appointment.booking
    recipient = booking.client.user if actor == "dj" else booking.dj.user
    context = {
        "booking": booking.pk,
        "date": appointment.scheduled_at.strftime("%d/%m/%Y %H:%M"),
        "status": {
            "fr": appointment.get_status_display(),
            "en": {"proposed": "proposed", "counter_proposed": "counter-proposed", "accepted": "accepted", "refused": "declined", "done": "completed", "cancelled": "cancelled"}.get(appointment.status, appointment.status),
            "nl": {"proposed": "voorgesteld", "counter_proposed": "tegenvoorstel", "accepted": "aanvaard", "refused": "geweigerd", "done": "voltooid", "cancelled": "geannuleerd"}.get(appointment.status, appointment.status),
        },
        "message": appointment.response_message or "—",
    }
    _send_localized(
        recipient,
        {"fr": "Ultimate DJ - rendez-vous de la réservation n°{booking}", "en": "Ultimate DJ - appointment for booking #{booking}", "nl": "Ultimate DJ - afspraak voor reservatie nr. {booking}"},
        {
            "fr": "Le rendez-vous préparatoire est maintenant « {status} » pour le {date}.\n\nMessage : {message}",
            "en": "The preparatory appointment is now “{status}” for {date}.\n\nMessage: {message}",
            "nl": "De voorbereidende afspraak staat nu op ‘{status}’ voor {date}.\n\nBericht: {message}",
        }, context,
    )


def notify_cancellation_requested(cancellation_request):
    administrators = list(get_user_model().objects.filter(is_staff=True, is_active=True))
    booking = cancellation_request.booking
    for administrator in administrators:
        _send_localized(
            administrator,
            {"fr": "Ultimate DJ - demande d'annulation n°{request}", "en": "Ultimate DJ - cancellation request #{request}", "nl": "Ultimate DJ - annuleringsverzoek nr. {request}"},
            {
                "fr": "Une demande d'annulation concerne la réservation n°{booking} du {date}.\n\nMotif : {reason}\n\nConnectez-vous à l'espace administrateur pour la traiter.",
                "en": "A cancellation request concerns booking #{booking} on {date}.\n\nReason: {reason}\n\nSign in to the administrator area to process it.",
                "nl": "Een annuleringsverzoek betreft reservatie nr. {booking} op {date}.\n\nReden: {reason}\n\nMeld u aan bij de beheerdersruimte om dit te behandelen.",
            },
            {"request": cancellation_request.pk, "booking": booking.pk, "date": booking.event_date.strftime("%d/%m/%Y"), "reason": cancellation_request.reason},
        )


def notify_cancellation_reviewed(cancellation_request):
    booking = cancellation_request.booking
    accepted = cancellation_request.status == cancellation_request.APPROVED
    context = {"booking": booking.pk, "date": booking.event_date.strftime("%d/%m/%Y"), "message": booking.cancellation_reason if accepted else cancellation_request.review_message}
    messages = ({
        "fr": "Votre demande d'annulation de la réservation n°{booking} du {date} a été acceptée.\n\nMotif : {message}",
        "en": "Your cancellation request for booking #{booking} on {date} has been approved.\n\nReason: {message}",
        "nl": "Uw annuleringsverzoek voor reservatie nr. {booking} op {date} werd goedgekeurd.\n\nReden: {message}",
    } if accepted else {
        "fr": "Votre demande d'annulation de la réservation n°{booking} du {date} a été refusée.\n\nRéponse : {message}",
        "en": "Your cancellation request for booking #{booking} on {date} has been rejected.\n\nResponse: {message}",
        "nl": "Uw annuleringsverzoek voor reservatie nr. {booking} op {date} werd geweigerd.\n\nAntwoord: {message}",
    })
    _send_localized(
        booking.client.user,
        ({"fr": "Ultimate DJ - demande d'annulation acceptée", "en": "Ultimate DJ - cancellation request approved", "nl": "Ultimate DJ - annuleringsverzoek goedgekeurd"} if accepted else {"fr": "Ultimate DJ - demande d'annulation refusée", "en": "Ultimate DJ - cancellation request rejected", "nl": "Ultimate DJ - annuleringsverzoek geweigerd"}),
        messages, context,
    )
