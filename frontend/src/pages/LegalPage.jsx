import { useTranslation } from "react-i18next";
import usePublicBusiness from "../hooks/usePublicBusiness";

const frenchContent = {
  legal: [
    ["Éditeur du service", "Ultimate DJ est une plateforme de mise en relation et de gestion de prestations d’animation musicale. Elle permet de préparer un devis, un contrat, une réservation et le suivi associé."],
    ["Nous contacter", "Pour toute question relative au service, à un dossier ou à vos données personnelles, contactez Ultimate DJ :", "contacts"],
    ["Responsabilité", "Les informations proposées sur le site sont mises à jour avec soin. Ultimate DJ ne peut toutefois garantir l’absence totale d’erreur, d’indisponibilité temporaire ou d’interruption technique. Les utilisateurs restent responsables des informations transmises dans leurs demandes, contrats et messages."],
    ["Contrats, paiements et remboursements", "Les devis, contrats, acomptes, annulations et remboursements sont encadrés par les documents liés à chaque réservation. Les données de carte bancaire ne sont jamais stockées par Ultimate DJ : les paiements sont traités par Stripe, prestataire de paiement sécurisé."],
    ["Propriété intellectuelle", "Les contenus, visuels, documents, marques et éléments de l’interface sont protégés. Toute reproduction, adaptation ou réutilisation sans autorisation préalable est interdite. Les œuvres musicales et marques tierces restent la propriété de leurs titulaires respectifs."],
    ["Droit applicable", "Les présentes informations sont interprétées conformément au droit belge et aux règles européennes applicables, notamment en matière de protection des données, de commerce électronique et de droit d’auteur."],
    ["Références juridiques", "Les obligations d’information et de vente à distance s’inscrivent notamment dans le Livre VI, articles VI.45 et suivants, du Code de droit économique belge. Les services électroniques relèvent également du Livre XII du Code de droit économique. La diffusion publique d’œuvres musicales reste soumise aux autorisations et droits applicables, notamment auprès de la SABAM."],
  ],
  privacy: [
    ["Responsable du traitement", "Ultimate DJ traite les données personnelles nécessaires à la gestion des demandes, réservations, contrats et paiements.", "contacts"],
    ["Données traitées", "Selon votre utilisation du service, nous pouvons traiter vos coordonnées, les informations liées à votre événement, vos échanges, préférences musicales, documents contractuels, factures et données de suivi de paiement. Les données bancaires ne transitent pas dans nos systèmes."],
    ["Finalités et fondements", "Les données sont utilisées pour répondre à une demande, préparer et exécuter un contrat, organiser une prestation, gérer les paiements, prévenir la fraude, assurer la sécurité du service et respecter nos obligations légales."],
    ["Destinataires et sécurité", "Seules les personnes ayant besoin des données y accèdent : le client, le DJ concerné et l’administration, selon leur rôle. Les accès sont protégés par authentification, contrôle des autorisations et mesures techniques adaptées. Stripe intervient comme prestataire de paiement."],
    ["Durée de conservation", "Les données sont conservées pendant la durée nécessaire au suivi du dossier et aux obligations légales applicables. Les pièces comptables et contractuelles peuvent être archivées lorsque leur conservation est obligatoire."],
    ["Vos droits, cookies et réclamations", "Vous pouvez demander l’accès à vos données, leur rectification, leur effacement lorsque cela est possible, la limitation de leur traitement ou vous opposer à certains usages. Les mécanismes strictement nécessaires à la session, à la sécurité et au choix de langue peuvent être utilisés. En cas de question ou de réclamation, contactez-nous d’abord par e-mail."],
    ["Références RGPD", "Le traitement des données est conçu en référence au Règlement (UE) 2016/679 : article 5 (principes de licéité, transparence et minimisation), article 6 (base légale), article 13 (information), articles 15 à 21 (droits des personnes) et article 32 (sécurité du traitement)."],
  ],
};

const translatedContent = {
  en: {
    legal: [
      ["Service publisher", "Ultimate DJ is a platform for connecting clients and DJs and managing music entertainment services. It supports quotes, contracts, bookings and related follow-up."],
      ["Contact us", "For any question about the service, a booking file or your personal data, contact Ultimate DJ:", "contacts"],
      ["Liability", "Information on the website is maintained with care. Ultimate DJ cannot guarantee the complete absence of errors, temporary unavailability or technical interruptions."],
      ["Contracts, payments and refunds", "Quotes, contracts, deposits, cancellations and refunds are governed by the documents linked to each booking. Ultimate DJ never stores card data: payments are handled by Stripe."],
      ["Intellectual property and applicable law", "Content, visuals, documents, brands and interface elements are protected. These notices are interpreted in accordance with Belgian law and applicable European rules."],
      ["Legal references", "Information and distance-selling obligations are notably based on Book VI, Articles VI.45 and following, of the Belgian Code of Economic Law. Electronic services also fall under Book XII of that Code. Public music broadcasting remains subject to applicable licences and rights, including SABAM where relevant."],
    ],
    privacy: [
      ["Data controller", "Ultimate DJ processes personal data needed to manage requests, bookings, contracts and payments.", "contacts"],
      ["Data processed and purposes", "We may process contact details, event information, messages, music preferences, contractual documents, invoices and payment follow-up data in order to provide and secure the service."],
      ["Recipients, security and retention", "Only the client, relevant DJ and administration access data according to their role. Access is protected through authentication and permission controls. Accounting and contractual records may be archived when required."],
      ["Your rights, cookies and complaints", "You may request access, correction, erasure where possible, restriction of processing or object to certain uses. Necessary session, security and language mechanisms may be used. For questions or complaints, contact us first by email."],
      ["GDPR references", "Data processing is designed with reference to Regulation (EU) 2016/679: Article 5 (lawfulness, transparency and minimisation), Article 6 (legal basis), Article 13 (information), Articles 15 to 21 (data-subject rights) and Article 32 (security of processing)."],
    ],
  },
  nl: {
    legal: [
      ["Uitgever van de dienst", "Ultimate DJ is een platform voor het in contact brengen van klanten en DJ’s en voor het beheer van muzikale animatieprestaties. Het ondersteunt offertes, contracten, reservaties en de bijbehorende opvolging."],
      ["Contact", "Neem voor vragen over de dienst, een dossier of uw persoonsgegevens contact op met Ultimate DJ:", "contacts"],
      ["Aansprakelijkheid", "De informatie op de website wordt zorgvuldig bijgehouden. Ultimate DJ kan echter niet garanderen dat er nooit fouten, tijdelijke onbeschikbaarheid of technische onderbrekingen zijn."],
      ["Contracten, betalingen en terugbetalingen", "Offertes, contracten, voorschotten, annuleringen en terugbetalingen worden geregeld door de documenten bij elke reservatie. Ultimate DJ bewaart nooit kaartgegevens: betalingen worden verwerkt door Stripe."],
      ["Intellectuele eigendom en toepasselijk recht", "Inhoud, beelden, documenten, merken en interface-elementen zijn beschermd. Deze vermeldingen worden geïnterpreteerd volgens het Belgische recht en de toepasselijke Europese regels."],
      ["Juridische referenties", "De informatie- en afstandsverkoopverplichtingen steunen onder meer op Boek VI, artikelen VI.45 en volgende, van het Belgische Wetboek van economisch recht. Elektronische diensten vallen eveneens onder Boek XII. Openbare muziekweergave blijft onderworpen aan toepasselijke licenties en rechten, waaronder SABAM waar relevant."],
    ],
    privacy: [
      ["Verwerkingsverantwoordelijke", "Ultimate DJ verwerkt persoonsgegevens die nodig zijn voor aanvragen, reservaties, contracten en betalingen.", "contacts"],
      ["Verwerkte gegevens en doeleinden", "Wij kunnen contactgegevens, evenementinformatie, berichten, muziekvoorkeuren, contractuele documenten, facturen en betalingsopvolging verwerken om de dienst aan te bieden en te beveiligen."],
      ["Ontvangers, beveiliging en bewaring", "Alleen de klant, betrokken DJ en administratie krijgen toegang volgens hun rol. Toegang wordt beschermd door authenticatie en rechtenbeheer. Boekhoudkundige en contractuele documenten kunnen worden gearchiveerd wanneer bewaring verplicht is."],
      ["Uw rechten, cookies en klachten", "U kunt inzage, correctie, verwijdering waar mogelijk, beperking van verwerking of bezwaar vragen. Noodzakelijke mechanismen voor sessie, veiligheid en taalkeuze kunnen worden gebruikt. Neem bij vragen of klachten eerst per e-mail contact op."],
      ["AVG-referenties", "De gegevensverwerking is ontworpen met verwijzing naar Verordening (EU) 2016/679: artikel 5 (rechtmatigheid, transparantie en minimalisering), artikel 6 (rechtsgrond), artikel 13 (informatie), artikelen 15 tot en met 21 (rechten van betrokkenen) en artikel 32 (beveiliging van de verwerking)."],
    ],
  },
};

export default function LegalPage({ type }) {
  const { t, i18n } = useTranslation();
  const business = usePublicBusiness();
  const key = type === "privacy" ? "privacy" : "legal";
  const language = i18n.language.startsWith("nl") ? "nl" : i18n.language.startsWith("en") ? "en" : "fr";
  const sections = language === "fr" ? frenchContent[key] : translatedContent[language][key];
  const labels = language === "nl" ? { address: "Adres", email: "E-mail", phone: "Telefoon" } : language === "en" ? { address: "Address", email: "Email", phone: "Phone" } : { address: "Adresse", email: "E-mail", phone: "Téléphone" };
  const contacts = [
    business.address && { label: labels.address, value: business.address },
    business.email && { label: labels.email, value: business.email, href: `mailto:${business.email}` },
    business.phone && { label: labels.phone, value: business.phone, href: `tel:${business.phone.replace(/\s/g, "")}` },
  ].filter(Boolean);

  return <section className="section-wrap legal-page"><p className="eyebrow dark">{business.legal_name || "Ultimate DJ"}</p><h1>{t(`legalPages.${key}.title`)}</h1>{sections.map(([heading, text, details]) => <article key={heading}><h2>{heading}</h2><p>{text}</p>{details === "contacts" && contacts.length > 0 && <dl className="legal-contact-details">{contacts.map((detail) => <div key={detail.label}><dt>{detail.label}</dt><dd>{detail.href ? <a href={detail.href}>{detail.value}</a> : detail.value}</dd></div>)}</dl>}</article>)}</section>;
}
