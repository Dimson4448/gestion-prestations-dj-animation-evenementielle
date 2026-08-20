import { useEffect, useState } from "react";

import { apiClient } from "../api";
import { mapAvailableDjs } from "../utils/booking";
import { decoratePackages } from "../utils/catalogue";
import { filterAllowedEventTypes } from "../utils/eventTypes";
import { unwrapApiList } from "../utils/apiCollections";

export default function useCatalogue(eventDate) {
  const [packages, setPackages] = useState([]);
  const [catalogueStatus, setCatalogueStatus] = useState("Chargement du catalogue Django…");
  const [catalogueReady, setCatalogueReady] = useState(false);
  const [availableDjs, setAvailableDjs] = useState([]);
  const [publicAvailabilityStatus, setPublicAvailabilityStatus] = useState("Recherche des créneaux Django…");
  const [eventTypeRecords, setEventTypeRecords] = useState([]);

  useEffect(() => {
    let active = true;
    apiClient.get("/packages/").then((response) => {
      if (!active) return;
      const nextPackages = decoratePackages(unwrapApiList(response.data));
      setPackages(nextPackages);
      setCatalogueReady(nextPackages.length > 0);
      setCatalogueStatus(nextPackages.length
        ? "Catalogue synchronisé avec l’API locale"
        : "Aucune offre active dans le catalogue Django");
    }).catch(() => {
      if (!active) return;
      setPackages([]);
      setCatalogueReady(false);
      setCatalogueStatus("Catalogue indisponible · vérifiez la connexion au backend Django");
    });
    return () => { active = false; };
  }, []);

  useEffect(() => {
    if (!eventDate) return undefined;
    let active = true;
    setPublicAvailabilityStatus("Recherche des créneaux disponibles…");
    apiClient.get("/availability/", { params: { date: eventDate } }).then((response) => {
      if (!active) return;
      const records = mapAvailableDjs(unwrapApiList(response.data));
      setAvailableDjs(records);
      setPublicAvailabilityStatus(records.length
        ? "Disponibilités synchronisées avec Django"
        : "Aucun DJ disponible à cette date");
    }).catch(() => {
      if (!active) return;
      setAvailableDjs([]);
      setPublicAvailabilityStatus("Disponibilités indisponibles · vérifiez la connexion au backend Django");
    });
    return () => { active = false; };
  }, [eventDate]);

  useEffect(() => {
    let active = true;
    apiClient.get("/event-types/").then((response) => {
      if (!active) return;
      setEventTypeRecords(filterAllowedEventTypes(unwrapApiList(response.data)));
    }).catch(() => active && setEventTypeRecords([]));
    return () => { active = false; };
  }, []);

  return {
    availableDjs,
    catalogueReady,
    catalogueStatus,
    eventTypeRecords,
    packages,
    publicAvailabilityStatus,
  };
}
