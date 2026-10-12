import { CheckCircle2, Circle } from "lucide-react";

const Step = ({ done, children }) => <li className={done ? "done" : ""}>{done ? <CheckCircle2 /> : <Circle />}<span>{children}</span></li>;

export default function AdminCaseTimeline({ booking, quote, payments = [] }) {
  if (!booking) return null;
  const quoteSent = ["sent", "accepted"].includes(quote?.status);
  const djAccepted = quote?.dj_decision === "accepted" || quote?.status === "accepted";
  const depositPaid = Boolean(booking.deposit_paid);
  const completed = ["performed", "paid"].includes(booking.status);
  const balancePaid = booking.status === "paid" || payments.some((payment) => payment.booking === booking.id && payment.status === "paid" && Number(payment.amount) > Number(booking.deposit_required));
  return <details className="case-timeline"><summary>Historique du dossier</summary><ol>
    <Step done>Demande de devis créée</Step>
    <Step done={quoteSent}>Devis envoyé au client</Step>
    <Step done={djAccepted}>DJ accepté et réservation créée</Step>
    <Step done={depositPaid}>Contrat signé et acompte payé</Step>
    <Step done={booking.status === "confirmed" || completed}>Rendez-vous préparatoire et playlist reçus</Step>
    <Step done={completed}>Prestation clôturée</Step>
    <Step done={balancePaid}>Solde payé</Step>
  </ol></details>;
}
