from django.shortcuts import render

from apps.accounts.models import DJProfile
from apps.availability.models import DJAvailability
from apps.catalog.models import Package


def home(request):
    """Page d'accueil du frontend serveur Django, selon la structure du cours."""
    context = {
        "packages": Package.objects.filter(is_active=True).order_by("base_price")[:3],
        "package_count": Package.objects.filter(is_active=True).count(),
        "dj_count": DJProfile.objects.filter(is_available=True).count(),
        "availability_count": DJAvailability.objects.filter(
            status=DJAvailability.AVAILABLE,
        ).count(),
    }
    return render(request, "home.html", context)
