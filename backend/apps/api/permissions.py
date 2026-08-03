from rest_framework import permissions


class LecturePubliqueEcritureAdmin(permissions.BasePermission):
    message = "Seul un administrateur peut modifier cette ressource."

    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return bool(request.user and request.user.is_staff)


class UtilisateurAuthentifie(permissions.BasePermission):
    message = "Vous devez être connecté pour accéder à cette ressource."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)


class DJOuAdministration(permissions.BasePermission):
    message = "Seul un DJ ou un administrateur peut gérer les disponibilités."

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and (request.user.is_staff or hasattr(request.user, "dj_profile"))
        )


class AdministrationOuProprietaire(permissions.BasePermission):
    message = "Vous n'avez pas l'autorisation d'accéder à cette ressource."

    def has_object_permission(self, request, view, obj):
        if request.user and request.user.is_staff:
            return True

        client_profile = getattr(request.user, "client_profile", None)
        dj_profile = getattr(request.user, "dj_profile", None)

        if hasattr(obj, "client") and client_profile and obj.client_id == client_profile.id:
            return True
        if hasattr(obj, "dj") and dj_profile and obj.dj_id == dj_profile.id:
            return True
        if hasattr(obj, "booking"):
            booking = obj.booking
            if client_profile and booking.client_id == client_profile.id:
                return True
            if dj_profile and booking.dj_id == dj_profile.id:
                return True
        if hasattr(obj, "playlist"):
            booking = obj.playlist.booking
            if client_profile and booking.client_id == client_profile.id:
                return True
            if dj_profile and booking.dj_id == dj_profile.id:
                return True

        return False
