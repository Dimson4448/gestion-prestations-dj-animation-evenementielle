import { CalendarDays, CreditCard, FileText, Music2 } from "lucide-react";

const features = [
  { icon: CalendarDays, title: "Disponibilités DJ", text: "Choix d'un DJ selon une date et un créneau disponible." },
  { icon: FileText, title: "Devis et contrat", text: "Simulation de devis puis génération d'un contrat personnalisé." },
  { icon: CreditCard, title: "Acompte Stripe", text: "Réservation confirmée après paiement sécurisé de l'acompte." },
  { icon: Music2, title: "Playlist", text: "Styles musicaux et chansons spécifiques pour l'événement." },
];

export default function App() {
  return (
    <main className="app-shell">
      <section className="hero">
        <div>
          <p className="eyebrow">Ultimate DJ</p>
          <h1>Gestion des prestations DJ et animation événementielle</h1>
          <p className="lead">
            Starter kit React connecté au futur backend Django REST. Cette première version prépare les parcours métier :
            offres, devis, disponibilité, acompte, contrat et playlist.
          </p>
          <div className="actions">
            <a href="http://localhost:8000/api/docs/swagger/">Swagger API</a>
            <a href="http://localhost:8000/admin/">Administration Django</a>
          </div>
        </div>
      </section>

      <section className="feature-grid">
        {features.map(({ icon: Icon, title, text }) => (
          <article key={title} className="feature-card">
            <Icon aria-hidden="true" />
            <h2>{title}</h2>
            <p>{text}</p>
          </article>
        ))}
      </section>
    </main>
  );
}
