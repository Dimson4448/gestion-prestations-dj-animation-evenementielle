const navigablePages = new Set(["accueil", "offres", "detail", "devis", "compte", "administration", "dj"]);

export function getPageFromHash(hash = "") {
  const target = hash.replace(/^#\/?/, "");
  return navigablePages.has(target) ? target : "accueil";
}

export function getPageHash(page) {
  return `#/${navigablePages.has(page) ? page : "accueil"}`;
}
