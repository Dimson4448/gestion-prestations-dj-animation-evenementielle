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
  onSubmit,
}) {
  const { i18n, t } = useTranslation();

  return (
    <div className="appointment-panel">
      <div className="playlist-heading">
        <div>
          <h3>{t("clientAppointments.title")}</h3>
          <p>{t("clientAppointments.intro")}</p>
        </div>
        <CalendarDays />
      </div>

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
            <input type="datetime-local" value={appointmentDateTime} onChange={(event) => onDateTimeChange(event.target.value)} required />
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
            </div>
            <span className={`appointment-status ${appointment.status}`}>
              {t(`clientAppointments.status.${appointment.status}`, { defaultValue: t("clientAppointments.status.planned") })}
            </span>
          </article>
        ))}
      </div>
    </div>
  );
}
