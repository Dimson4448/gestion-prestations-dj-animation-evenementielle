export default function SiteFooter({ onNavigate }) {
  return (
    <footer>
      <img src="/logo-ultimate-dj.png" alt="Ultimate DJ" />
      <p>Réserver. Mixer. Célébrer.</p>
      <nav aria-label="Navigation de pied de page">
        <button onClick={() => onNavigate("offres")}>Offres</button>
        <button onClick={() => onNavigate("devis")}>Devis</button>
        <button onClick={() => onNavigate("compte")}>Mon compte</button>
        <a href="http://127.0.0.1:8000/admin/" target="_blank" rel="noreferrer">Administration</a>
      </nav>
      <small>© 2026 Ultimate DJ · Version beta 0.2.0</small>
    </footer>
  );
}
