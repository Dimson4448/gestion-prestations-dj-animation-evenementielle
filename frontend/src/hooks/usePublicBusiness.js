import { useEffect, useState } from "react";

import { getPublicBusinessInfo } from "../api";

const publicBusinessFallback = {
  legal_name: "Ultimate DJ",
  address: "",
  email: "ultimate.dj.be@gmail.com",
  phone: "+32 465 77 98 48",
};

export default function usePublicBusiness() {
  const [business, setBusiness] = useState(publicBusinessFallback);

  useEffect(() => {
    let active = true;
    getPublicBusinessInfo().then((data) => {
      if (!active) return;
      setBusiness((current) => ({
        ...current,
        ...Object.fromEntries(Object.entries(data).filter(([, value]) => Boolean(value))),
      }));
    }).catch(() => {});
    return () => { active = false; };
  }, []);

  return business;
}
