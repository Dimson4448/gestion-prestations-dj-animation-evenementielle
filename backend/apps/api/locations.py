import json
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from django.conf import settings
from django.core.cache import cache


class LocationSearchUnavailable(Exception):
    """Le fournisseur de géocodage ne peut pas répondre actuellement."""


def _city_label(properties):
    name = properties.get("name") or properties.get("city")
    if not name:
        return None
    region = properties.get("state") or properties.get("county")
    country = properties.get("country")
    parts = [name]
    if region and region.casefold() != name.casefold():
        parts.append(region)
    if country:
        parts.append(country)
    return ", ".join(parts)


def search_cities(query, language="fr", limit=8):
    normalized_query = " ".join(query.split())
    cache_key = f"location-search:{language}:{normalized_query.casefold()}:{limit}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached

    parameters = urlencode([
        ("q", normalized_query),
        ("lang", language if language in {"fr", "en", "nl"} else "fr"),
        ("limit", limit),
        ("lat", "50.8503"),
        ("lon", "4.3517"),
        ("location_bias_scale", "0.35"),
        ("layer", "city"),
        ("layer", "locality"),
    ])
    request = Request(
        f"{settings.PHOTON_API_URL.rstrip('/')}?{parameters}",
        headers={"User-Agent": settings.GEOCODING_USER_AGENT, "Accept": "application/geo+json, application/json"},
    )
    try:
        with urlopen(request, timeout=settings.GEOCODING_TIMEOUT_SECONDS) as response:
            payload = json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
        raise LocationSearchUnavailable from exc

    cities = []
    seen = set()
    for feature in payload.get("features", []):
        properties = feature.get("properties") or {}
        label = _city_label(properties)
        if not label or label.casefold() in seen:
            continue
        coordinates = (feature.get("geometry") or {}).get("coordinates") or []
        cities.append({
            "label": label,
            "city": properties.get("name") or properties.get("city"),
            "country": properties.get("country", ""),
            "country_code": properties.get("countrycode", "").upper(),
            "latitude": coordinates[1] if len(coordinates) > 1 else None,
            "longitude": coordinates[0] if coordinates else None,
        })
        seen.add(label.casefold())

    cities.sort(key=lambda city: city["country_code"] != "BE")
    cities = cities[:limit]
    cache.set(cache_key, cities, settings.GEOCODING_CACHE_SECONDS)
    return cities
