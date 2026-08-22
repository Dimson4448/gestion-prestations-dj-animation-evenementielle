const pagePaths = {
  accueil: "/",
  offres: "/offres",
  detail: "/detail",
  devis: "/devis",
  compte: "/compte",
  administration: "/administration",
  dj: "/dj",
};

const pagesByPath = new Map(Object.entries(pagePaths).map(([page, path]) => [path, page]));

export function getPageFromPath(pathname = "/") {
  const normalizedPath = `/${pathname}`.replace(/\/{2,}/g, "/").replace(/\/$/, "") || "/";
  return pagesByPath.get(normalizedPath) || "accueil";
}

export function getPageFromLocation(pathname = "/", hash = "") {
  if (hash.startsWith("#/")) {
    return getPageFromPath(hash.slice(1));
  }
  return getPageFromPath(pathname);
}

export function getPagePath(page) {
  return pagePaths[page] || pagePaths.accueil;
}
