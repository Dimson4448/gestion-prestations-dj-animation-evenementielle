from django.conf import settings
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from rest_framework_simplejwt.views import TokenRefreshView

from apps.api.views import ThrottledTokenObtainPairView
from apps.accounts.views import download_dj_application_document

from .views import home


admin.site.site_header = "Administration Ultimate DJ"
admin.site.site_title = "Administration Ultimate DJ"
admin.site.index_title = "Gestion des prestations DJ"


urlpatterns = [
    path("", home, name="home"),
    path("admin/dj-applications/<int:pk>/document/<str:document_type>/", download_dj_application_document, name="dj-application-document"),
    path("admin/", admin.site.urls),
    path("accounts/", include("django.contrib.auth.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/swagger/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    path("api/docs/redoc/", SpectacularRedocView.as_view(url_name="schema"), name="redoc"),
    path("api/v1/auth/token/", ThrottledTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/v1/auth/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/v1/", include("apps.api.urls")),
]

if settings.DEBUG:
    urlpatterns += staticfiles_urlpatterns()
