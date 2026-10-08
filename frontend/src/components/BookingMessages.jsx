import { CalendarDays, MessageCircle, Send } from "lucide-react";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

import { apiClient } from "../api";
import { unwrapApiList } from "../utils/apiCollections";

const getRequestErrorMessage = (error, fallback) => {
  const status = error.response?.status;
  const detail = error.response?.data?.detail;
  if (typeof detail === "string") return `${fallback} (${detail})`;
  if (status) return `${fallback} (HTTP ${status})`;
  if (error.message) return `${fallback} (${error.message})`;
  return fallback;
};

export default function BookingMessages({ bookings = [] }) {
  const { t, i18n } = useTranslation();
  const [bookingId, setBookingId] = useState("");
  const [messages, setMessages] = useState([]);
  const [body, setBody] = useState("");
  const [status, setStatus] = useState("");

  useEffect(() => {
    if (!bookingId && bookings[0]) setBookingId(String(bookings[0].id));
  }, [bookings, bookingId]);

  useEffect(() => {
    if (!bookingId) return;
    apiClient.get("/booking-messages/", { params: { booking: bookingId, ordering: "created_at" } })
      .then((response) => setMessages(unwrapApiList(response.data)))
      .catch((error) => setStatus(getRequestErrorMessage(error, t("messages.loadError"))));
  }, [bookingId, t]);

  const send = async (event) => {
    event.preventDefault();
    try {
      const response = await apiClient.post("/booking-messages/", { booking: Number(bookingId), body });
      setMessages((current) => [...current, response.data]);
      setBody("");
      setStatus(t("messages.sent"));
    } catch (error) {
      setStatus(error.response?.data?.body?.[0] || getRequestErrorMessage(error, t("messages.sendError")));
    }
  };

  const downloadCalendar = async () => {
    try {
      const response = await apiClient.get(`/bookings/${bookingId}/calendar.ics`, { responseType: "blob" });
      const url = URL.createObjectURL(response.data);
      const link = document.createElement("a");
      link.href = url;
      link.download = `ultimate-dj-reservation-${bookingId}.ics`;
      link.click();
      URL.revokeObjectURL(url);
    } catch (error) {
      setStatus(getRequestErrorMessage(error, t("messages.calendarError")));
    }
  };

  const downloadDocuments = async () => {
    try {
      const response = await apiClient.get(`/bookings/${bookingId}/documents/`, { responseType: "blob" });
      const url = URL.createObjectURL(response.data);
      const link = document.createElement("a");
      link.href = url;
      link.download = `ultimate-dj-dossier-${bookingId}.zip`;
      link.click();
      URL.revokeObjectURL(url);
    } catch (error) { setStatus(getRequestErrorMessage(error, t("messages.documentsError"))); }
  };

  if (!bookings.length) return null;
  return <section className="booking-messages" aria-labelledby="booking-messages-title">
    <div className="playlist-heading"><div><h2 id="booking-messages-title">{t("messages.title")}</h2><p>{t("messages.intro")}</p></div><MessageCircle /></div>
    <label>{t("messages.booking")}<select value={bookingId} onChange={(event) => setBookingId(event.target.value)}>{bookings.map((booking) => <option value={booking.id} key={booking.id}>{t("messages.bookingOption", { id: booking.id, date: booking.event_date })}</option>)}</select></label><div className="dj-action-buttons"><button className="document-button" type="button" onClick={downloadCalendar}><CalendarDays /> {t("messages.calendar")}</button><button className="document-button" type="button" onClick={downloadDocuments}>{t("messages.documents")}</button></div>
    <div className="messages-thread" aria-live="polite">{messages.map((message) => <article key={message.id}><strong>{message.sender_name}</strong><small>{t(`messages.role.${message.sender_role}`)} · {new Date(message.created_at).toLocaleString(i18n.language)}</small><p>{message.body}</p></article>)}{!messages.length && <p className="invoice-empty">{t("messages.empty")}</p>}</div>
    <form onSubmit={send}><label>{t("messages.write")}<textarea rows="3" maxLength="2000" value={body} onChange={(event) => setBody(event.target.value)} required /></label><button className="document-button" type="submit"><Send /> {t("messages.send")}</button></form>{status && <p className="form-message success" role="status">{status}</p>}
  </section>;
}
