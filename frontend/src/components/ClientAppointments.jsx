import { CalendarDays } from "lucide-react";
import { useTranslation } from "react-i18next";

export default function ClientAppointments({
  appointmentBookingId,
  appointmentDateTime,
  appointmentMode,
  appointmentNotes,
  appointments,
  appointmentPending,
  appointmentStatus,
  eligibleBookings,
  onBookingChange,
  onDateTimeChange,
  onModeChange,
  onNotesChange,
  onRespond,
  onSubmit,
}) {
  const { i18n, t } = useTranslation();
  const selectedBooking = eligibleBookings.find((booking) => String(booking.id) === String(appointmentBookingId));
  const latestDate = selectedBooking
    ? new Date(new Date(`${selectedBooking.event_date}T${selectedBooking.start_time}`).getTime() - 24 * 60 * 60 * 1000)
    : null;
  const latestDateTime = latestDate && !Number.isNaN(latestDate.getTime())
    ? `${latestDate.getFullYear()}-${String(latestDate.getMonth() + 1).padStart(2, "0")}-${String(latestDate.getDate()).padStart(2, "0")}T${String(latestDate.getHours()).padStart(2, "0")}:${String(latestDate.getMinutes()).padStart(2, "0")}`
    : undefined;

  return (
    <div className="appointment-panel" id="client-appointments">
      <div className="playlist-heading">
        <div>
          <h3>{t("clientAppointments.title")}</h3>
          <p>{t("clientAppointments.intro")}</p>
        </div>
        <CalendarDays />
      </div>

      <div className="appointment-rule"><CalendarDays /><p><strong>{t("clientAppointments.ruleTitle")}</strong><span>{t("clientAppointments.ruleText")}</span></p></div>

      {appointmentStatus && (
        <p className={appointmentStatus.includes("planifié") ? "form-message success" : "invoice-empty"} role="status">
          {appointmentStatus}
        </p>
      )}

      {eligibleBookings.length > 0 && (
        <form className="playlist-form" onSubmit={onSubmit}>
          <label>
            {t("clientAppointments.booking")}
            <select value={appointmentBookingId} onChange={(event) => onBookingChange(event.target.value)} required>
              <option value="">{t("clientAppointments.select")}</option>
              {eligibleBookings.map((booking) => (
                <option value={booking.id} key={booking.id}>
                  {t("clientAppointments.bookingOption", {
                    id: booking.id,
                    date: new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language),
                  })}
                </option>
              ))}
            </select>
          </label>
          <label>
            {t("clientAppointments.dateTime")}
            <input type="datetime-local" max={latestDateTime} value={appointmentDateTime} onChange={(event) => onDateTimeChange(event.target.value)} required />
            {latestDate && <small>{t("clientAppointments.latest", { date: latestDate.toLocaleString(i18n.language) })}</small>}
          </label>
          <label>
            {t("clientAppointments.mode")}
            <select value={appointmentMode} onChange={(event) => onModeChange(event.target.value)}>
              <option value="online">{t("clientAppointments.online")}</option>
              <option value="in_person">{t("clientAppointments.inPerson")}</option>
            </select>
          </label>
          <label>
            {t("clientAppointments.notes")}
            <textarea rows="2" value={appointmentNotes} onChange={(event) => onNotesChange(event.target.value)} placeholder={t("clientAppointments.notesPlaceholder")} />
          </label>
          <button className="primary-button" type="submit" disabled={appointmentPending}>
            {appointmentPending ? t("clientAppointments.planning") : t("clientAppointments.plan")}
          </button>
        </form>
      )}

      {eligibleBookings.length === 0 && appointments.length === 0 && (
        <p className="invoice-empty">{t("clientAppointments.unavailable")}</p>
      )}

      <div className="appointment-list">
        {appointments.map((appointment) => (
          <article key={appointment.id}>
            <div>
              <strong>{new Date(appointment.scheduled_at).toLocaleString(i18n.language)}</strong>
              <span>{t("clientAppointments.summary", {
                id: appointment.booking,
                mode: t(appointment.mode === "online" ? "clientAppointments.online" : "clientAppointments.inPerson"),
              })}</span>
              {appointment.notes && <small>{appointment.notes}</small>}
              {appointment.response_message && <small className="appointment-response">{t("clientAppointments.djResponse")}: {appointment.response_message}</small>}
            </div>
            <div className="appointment-client-actions">
              <span className={`appointment-status ${appointment.status}`}>{t(`clientAppointments.status.${appointment.status}`, { defaultValue: appointment.status })}</span>
              {appointment.status === "counter_proposed" && <div><button className="document-button" type="button" onClick={() => onRespond(appointment.id, "accepted")} disabled={appointmentPending}>{t("clientAppointments.acceptCounter")}</button><button className="document-button danger-button" type="button" onClick={() => onRespond(appointment.id, "refused")} disabled={appointmentPending}>{t("clientAppointments.refuseCounter")}</button></div>}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}
