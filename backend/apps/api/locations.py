import json
import unicodedata
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from django.conf import settings
from django.core.cache import cache


class LocationSearchUnavailable(Exception):
    """Le fournisseur de géocodage ne peut pas répondre actuellement."""


BELGIAN_LOCATIONS = [
    ("Bruxelles", "Bruxelles-Capitale", "brussel brussels"),
    ("Anderlecht", "Bruxelles-Capitale", ""),
    ("Auderghem", "Bruxelles-Capitale", "oudergem"),
    ("Berchem-Sainte-Agathe", "Bruxelles-Capitale", "sint-agatha-berchem"),
    ("Etterbeek", "Bruxelles-Capitale", ""),
    ("Evere", "Bruxelles-Capitale", ""),
    ("Forest", "Bruxelles-Capitale", "vorst"),
    ("Ganshoren", "Bruxelles-Capitale", ""),
    ("Ixelles", "Bruxelles-Capitale", "elsene"),
    ("Jette", "Bruxelles-Capitale", ""),
    ("Koekelberg", "Bruxelles-Capitale", ""),
    ("Molenbeek-Saint-Jean", "Bruxelles-Capitale", "sint-jans-molenbeek molenbeek"),
    ("Saint-Gilles", "Bruxelles-Capitale", "sint-gillis"),
    ("Saint-Josse-ten-Noode", "Bruxelles-Capitale", "sint-joost-ten-node saint-josse"),
    ("Schaerbeek", "Bruxelles-Capitale", "schaarbeek"),
    ("Uccle", "Bruxelles-Capitale", "ukkel"),
    ("Watermael-Boitsfort", "Bruxelles-Capitale", "watermaal-bosvoorde"),
    ("Woluwe-Saint-Lambert", "Bruxelles-Capitale", "sint-lambrechts-woluwe"),
    ("Woluwe-Saint-Pierre", "Bruxelles-Capitale", "sint-pieters-woluwe"),
    ("Laeken", "Bruxelles-Capitale", "laken"),
    ("Matonge", "Bruxelles-Capitale", "matonge ixelles"),
    ("Marolles", "Bruxelles-Capitale", "marollen"),
    ("Sablon", "Bruxelles-Capitale", "zavel"),
    ("Quartier européen", "Bruxelles-Capitale", "quartier europeen european quarter europese wijk"),
    ("Mons", "Hainaut", "bergen"),
    ("Charleroi", "Hainaut", ""),
    ("Liège", "Liège", "luik liege"),
    ("Namur", "Namur", "namen"),
    ("Anvers", "Anvers", "antwerpen"),
    ("Gand", "Flandre-Orientale", "gent"),
    ("Bruges", "Flandre-Occidentale", "brugge"),
    ("Louvain", "Brabant flamand", "leuven"),
    ("Wavre", "Brabant wallon", ""),
    ("Arlon", "Luxembourg", "aarlen"),
    ("Hasselt", "Limbourg", ""),
]

CITY_TRANSLATIONS = {
    "Bruxelles": {"en": "Brussels", "nl": "Brussel"},
    "Auderghem": {"nl": "Oudergem"},
    "Berchem-Sainte-Agathe": {"nl": "Sint-Agatha-Berchem"},
    "Forest": {"nl": "Vorst"},
    "Ixelles": {"nl": "Elsene"},
    "Molenbeek-Saint-Jean": {"nl": "Sint-Jans-Molenbeek"},
    "Saint-Gilles": {"nl": "Sint-Gillis"},
    "Saint-Josse-ten-Noode": {"nl": "Sint-Joost-ten-Node"},
    "Schaerbeek": {"nl": "Schaarbeek"},
    "Uccle": {"nl": "Ukkel"},
    "Watermael-Boitsfort": {"nl": "Watermaal-Bosvoorde"},
    "Woluwe-Saint-Lambert": {"nl": "Sint-Lambrechts-Woluwe"},
    "Woluwe-Saint-Pierre": {"nl": "Sint-Pieters-Woluwe"},
    "Laeken": {"nl": "Laken"},
    "Marolles": {"nl": "Marollen"},
    "Sablon": {"nl": "Zavel"},
    "Quartier européen": {"en": "European Quarter", "nl": "Europese wijk"},
    "Mons": {"nl": "Bergen"},
    "Liège": {"nl": "Luik"},
    "Namur": {"nl": "Namen"},
    "Anvers": {"en": "Antwerp", "nl": "Antwerpen"},
    "Gand": {"en": "Ghent", "nl": "Gent"},
    "Bruges": {"nl": "Brugge"},
    "Louvain": {"en": "Leuven", "nl": "Leuven"},
    "Arlon": {"nl": "Aarlen"},
}

REGION_TRANSLATIONS = {
    "Bruxelles-Capitale": {"en": "Brussels-Capital", "nl": "Brussel-Hoofdstad"},
    "Hainaut": {"nl": "Henegouwen"},
    "Liège": {"nl": "Luik"},
    "Namur": {"nl": "Namen"},
    "Anvers": {"en": "Antwerp", "nl": "Antwerpen"},
    "Flandre-Orientale": {"en": "East Flanders", "nl": "Oost-Vlaanderen"},
    "Flandre-Occidentale": {"en": "West Flanders", "nl": "West-Vlaanderen"},
    "Brabant flamand": {"en": "Flemish Brabant", "nl": "Vlaams-Brabant"},
    "Brabant wallon": {"en": "Walloon Brabant", "nl": "Waals-Brabant"},
    "Luxembourg": {"nl": "Luxemburg"},
    "Limbourg": {"en": "Limburg", "nl": "Limburg"},
}

COUNTRY_TRANSLATIONS = {"fr": "Belgique", "en": "Belgium", "nl": "België"}


def _search_key(value):
    normalized = unicodedata.normalize("NFKD", value.casefold())
    return "".join(character for character in normalized if not unicodedata.combining(character))


def _translated_name(value, language, translations):
    return translations.get(value, {}).get(language, value)


def _local_belgian_results(query, language):
    key = _search_key(query)
    matches = []
    for city, region, aliases in BELGIAN_LOCATIONS:
        translated_names = " ".join(CITY_TRANSLATIONS.get(city, {}).values())
        translated_regions = " ".join(REGION_TRANSLATIONS.get(region, {}).values())
        searchable = _search_key(f"{city} {translated_names} {region} {translated_regions} {aliases}")
        if key not in searchable:
            continue
        localized_city = _translated_name(city, language, CITY_TRANSLATIONS)
        localized_region = _translated_name(region, language, REGION_TRANSLATIONS)
        localized_country = COUNTRY_TRANSLATIONS.get(language, COUNTRY_TRANSLATIONS["fr"])
        matches.append({
            "label": f"{localized_city}, {localized_region}, {localized_country}",
            "city": localized_city,
            "country": localized_country,
            "country_code": "BE",
            "latitude": None,
            "longitude": None,
        })
    return matches


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

    language = language if language in {"fr", "en", "nl"} else "fr"
    local_cities = _local_belgian_results(normalized_query, language)
    parameters = urlencode([
        ("q", normalized_query),
        ("lang", language),
        ("limit", limit),
        ("lat", "50.8503"),
        ("lon", "4.3517"),
        ("location_bias_scale", "0.35"),
        ("layer", "city"),
        ("layer", "locality"),
        ("layer", "district"),
    ])
    request = Request(
        f"{settings.PHOTON_API_URL.rstrip('/')}?{parameters}",
        headers={"User-Agent": settings.GEOCODING_USER_AGENT, "Accept": "application/geo+json, application/json"},
    )
    try:
        with urlopen(request, timeout=settings.GEOCODING_TIMEOUT_SECONDS) as response:
            payload = json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
        if local_cities:
            cache.set(cache_key, local_cities[:limit], settings.GEOCODING_CACHE_SECONDS)
            return local_cities[:limit]
        raise LocationSearchUnavailable from exc

    cities = list(local_cities)
    seen = {city["label"].casefold() for city in local_cities}
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
