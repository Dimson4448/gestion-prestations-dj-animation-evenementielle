import { Star } from "lucide-react";
import { useState } from "react";
import { useTranslation } from "react-i18next";

const ratings = [5, 4, 3, 2, 1];
const stars = [1, 2, 3, 4, 5];

export default function ClientReviews({
  allowEarlyReview,
  comment,
  eligibleBookings,
  onBookingChange,
  onCommentChange,
  onRatingChange,
  onSubmit,
  pending,
  rating,
  reviewBookingId,
  reviews,
  statusMessage,
}) {
  const { i18n, t } = useTranslation();
  const [isOpen, setIsOpen] = useState(false);
  const panelId = "client-review-content";

  return (
    <div className="review-panel">
      <button
        aria-controls={panelId}
        aria-expanded={isOpen}
        className="playlist-heading review-panel-toggle"
        onClick={() => setIsOpen((current) => !current)}
        type="button"
      >
        <div><h3>{t("clientReviews.title")}</h3><p>{t("clientReviews.intro")}</p></div>
        <Star />
      </button>

      {isOpen && <div className="review-panel-content" id={panelId}>
        {allowEarlyReview && <p className="review-test-notice">{t("reviewTestMode")}</p>}
        {statusMessage && <p className={statusMessage.includes("Merci") ? "form-message success" : "invoice-empty"} role="status">{statusMessage}</p>}

        {eligibleBookings.length > 0 ? (
          <form className="playlist-form" onSubmit={onSubmit}>
          <label>
            {t("clientReviews.completedService")}
            <select value={reviewBookingId} onChange={(event) => onBookingChange(event.target.value)} required>
              <option value="">{t("clientReviews.select")}</option>
              {eligibleBookings.map((booking) => (
                <option value={booking.id} key={booking.id}>
                  {t("clientReviews.bookingOption", { id: booking.id, date: new Date(`${booking.event_date}T00:00:00`).toLocaleDateString(i18n.language) })}
                </option>
              ))}
            </select>
          </label>
          <label>
            {t("clientReviews.rating")}
            <select value={rating} onChange={(event) => onRatingChange(event.target.value)}>
              {ratings.map((value) => <option value={value} key={value}>{value} / 5</option>)}
            </select>
          </label>
          <label>
            {t("clientReviews.comment")}
            <textarea rows="3" maxLength="255" value={comment} onChange={(event) => onCommentChange(event.target.value)} placeholder={t("clientReviews.placeholder")} required />
          </label>
          <small>{t("clientReviews.characterCount", { count: comment.length })}</small>
          <button className="primary-button" type="submit" disabled={pending}>{pending ? t("clientReviews.sending") : t("clientReviews.send")}</button>
          </form>
        ) : (
          <p className="invoice-empty">{t("clientReviews.notAvailableYet")}</p>
        )}

        <div className="review-list">
          {reviews.map((review) => (
            <article key={review.id}>
              <div className="review-stars" aria-label={t("clientReviews.stars", { count: review.rating })}>
                {stars.map((value) => <Star key={value} className={value <= review.rating ? "filled" : ""} />)}
              </div>
              <p>{review.comment}</p>
              <span className={`review-status ${review.status}`}>{t(`clientReviews.status.${review.status}`, { defaultValue: t("clientReviews.status.pending") })}</span>
            </article>
          ))}
          {!reviews.length && <p className="invoice-empty">{t("clientReviews.empty")}</p>}
        </div>
      </div>}
    </div>
  );
}
