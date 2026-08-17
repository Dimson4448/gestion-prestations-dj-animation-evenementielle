from pathlib import Path

from django.contrib.admin.views.decorators import staff_member_required
from django.http import FileResponse, Http404
from django.shortcuts import get_object_or_404

from .models import DJApplication


@staff_member_required
def download_dj_application_document(request, pk, document_type):
    application = get_object_or_404(DJApplication, pk=pk)
    documents = {
        "identity": application.identity_document,
        "insurance": application.insurance_document,
    }
    document = documents.get(document_type)
    if not document or not document.name:
        raise Http404("Justificatif introuvable.")
    try:
        stream = document.open("rb")
    except FileNotFoundError as exc:
        raise Http404("Justificatif introuvable.") from exc
    return FileResponse(stream, as_attachment=True, filename=Path(document.name).name)
