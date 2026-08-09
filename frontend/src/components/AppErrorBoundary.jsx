import { Component } from "react";
import { RotateCcw, ShieldAlert } from "lucide-react";

export default class AppErrorBoundary extends Component {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error("Erreur React non récupérée", error, errorInfo);
  }

  render() {
    if (!this.state.hasError) return this.props.children;

    return (
      <main className="app-error-page" role="alert">
        <img src="/logo-ultimate-dj.png" alt="Ultimate DJ" />
        <ShieldAlert aria-hidden="true" />
        <p className="eyebrow">Incident temporaire</p>
        <h1>La page n’a pas pu s’afficher.</h1>
        <p>Rechargez l’application. Si le problème persiste, vérifiez que le backend Django est démarré.</p>
        <button className="primary-button" type="button" onClick={() => window.location.reload()}>
          <RotateCcw aria-hidden="true" /> Recharger l’application
        </button>
      </main>
    );
  }
}
