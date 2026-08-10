import { Component } from "react";
import { RotateCcw, ShieldAlert } from "lucide-react";
import i18n from "../i18n";

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
        <p className="eyebrow">{i18n.t("error.eyebrow")}</p>
        <h1>{i18n.t("error.title")}</h1>
        <p>{i18n.t("error.text")}</p>
        <button className="primary-button" type="button" onClick={() => window.location.reload()}>
          <RotateCcw aria-hidden="true" /> {i18n.t("error.reload")}
        </button>
      </main>
    );
  }
}
