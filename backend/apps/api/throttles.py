from rest_framework.throttling import SimpleRateThrottle


class IpRateThrottle(SimpleRateThrottle):
    """Limite une action par adresse IP, même si une session existe déjà."""

    def get_cache_key(self, request, view):
        return self.cache_format % {"scope": self.scope, "ident": self.get_ident(request)}


class LoginRateThrottle(IpRateThrottle):
    scope = "login"


class AccountActionRateThrottle(IpRateThrottle):
    scope = "account_action"
