import { useEffect, useState } from "react";

import { apiClient, publicRequestConfig } from "../api";
import { mapAvailableDjs } from "../utils/booking";
import { decoratePackages } from "../utils/catalogue";
import { filterAllowedEventTypes } from "../utils/eventTypes";
import { unwrapApiList } from "../utils/apiCollections";

const getAllAvailabilitiesForDate = async (date) => {
  let nextPage = `/availability/?date=${encodeURIComponent(date)}`;
  const slots = [];

  while (nextPage) {
    const response = await apiClient.get(nextPage, publicRequestConfig);
    slots.push(...unwrapApiList(response.data));
    nextPage = response.data?.next || null;
  }

  return slots;
};

export default function useCatalogue(eventDate) {
  const [packages, setPackages] = useState([]);
  const [catalogueStatus, setCatalogueStatus] = useState("Chargement du catalogue Django…");
  const [catalogueReady, setCatalogueReady] = useState(false);
  const [availableDjs, setAvailableDjs] = useState([]);
  const [availableSlots, setAvailableSlots] = useState([]);
  const [catalogueDjs, setCatalogueDjs] = useState([]);
  const [publicPlaylists, setPublicPlaylists] = useState([]);
  const [publicReviews, setPublicReviews] = useState([]);
  const [publicAvailabilityStatus, setPublicAvailabilityStatus] = useState("Recherche des créneaux Django…");
  const [eventTypeRecords, setEventTypeRecords] = useState([]);

  useEffect(() => {
    let active = true;
    Promise.all([
      apiClient.get("/packages/", publicRequestConfig),
      apiClient.get("/djs/", { ...publicRequestConfig, params: { ordering: "stage_name" } }),
      apiClient.get("/playlists/public/", publicRequestConfig),
      apiClient.get("/reviews/public/", { ...publicRequestConfig, params: { ordering: "-created_at" } }),
    ]).then(([packagesResponse, djsResponse, playlistsResponse, reviewsResponse]) => {
      if (!active) return;
      const nextPackages = decoratePackages(unwrapApiList(packagesResponse.data));
      setPackages(nextPackages);
      setCatalogueDjs(unwrapApiList(djsResponse.data));
      setPublicPlaylists(unwrapApiList(playlistsResponse.data));
      setPublicReviews(unwrapApiList(reviewsResponse.data));
      setCatalogueReady(nextPackages.length > 0);
      setCatalogueStatus(nextPackages.length
        ? "Catalogue synchronisé avec l’API locale"
        : "Aucune offre active dans le catalogue Django");
    }).catch(() => {
      if (!active) return;
      setPackages([]);
      setCatalogueDjs([]);
      setPublicPlaylists([]);
      setPublicReviews([]);
      setCatalogueReady(false);
      setCatalogueStatus("Catalogue indisponible · vérifiez la connexion au backend Django");
    });
    return () => { active = false; };
  }, []);

  useEffect(() => {
    if (!eventDate) return undefined;
    let active = true;
    setPublicAvailabilityStatus("Recherche des créneaux disponibles…");
    getAllAvailabilitiesForDate(eventDate).then((slots) => {
      if (!active) return;
      const records = mapAvailableDjs(slots);
      setAvailableDjs(records);
      setAvailableSlots(slots);
      setPublicAvailabilityStatus(records.length
        ? "Disponibilités synchronisées avec Django"
        : "Aucun DJ disponible à cette date");
    }).catch(() => {
      if (!active) return;
      setAvailableDjs([]);
      setAvailableSlots([]);
      setPublicAvailabilityStatus("Disponibilités indisponibles · vérifiez la connexion au backend Django");
    });
    return () => { active = false; };
  }, [eventDate]);

  useEffect(() => {
    let active = true;
    apiClient.get("/event-types/", publicRequestConfig).then((response) => {
      if (!active) return;
      setEventTypeRecords(filterAllowedEventTypes(unwrapApiList(response.data)));
    }).catch(() => active && setEventTypeRecords([]));
    return () => { active = false; };
  }, []);

  return {
    availableDjs,
    availableSlots,
    catalogueDjs,
    catalogueReady,
    catalogueStatus,
    eventTypeRecords,
    packages,
    publicPlaylists,
    publicReviews,
    publicAvailabilityStatus,
  };
}
