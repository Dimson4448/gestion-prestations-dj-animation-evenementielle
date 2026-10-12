import { useTranslation } from "react-i18next";
import usePublicBusiness from "../hooks/usePublicBusiness";

const content = {
  fr: {
    legal: [
      ["Éditeur et rôle du service", "Ultimate DJ est une plateforme de mise en relation et de gestion de prestations d'animation musicale. Elle centralise les devis, contrats, réservations, rendez-vous préparatoires, paiements et échanges. Le DJ désigné réalise la prestation ; Ultimate DJ organise le suivi administratif et technique du dossier."],
      ["Coordonnées et contact", "Pour toute question concernant le service, un dossier ou vos données, vous pouvez utiliser les coordonnées ci-dessous.", "business"],
      ["Réservation, paiements et facturation", "Avant tout paiement, le dossier présente la prestation, la date, le prix, l'acompte, le solde et les documents associés. Les données de carte bancaire ne sont jamais stockées par Ultimate DJ : elles sont traitées par Stripe. Le contrat et les documents du dossier précisent les modalités applicables à la réservation et au paiement."],
      ["Rétractation, annulation et remboursement", "Les documents liés à la réservation précisent les modalités d'annulation et de remboursement. Lorsqu'un droit de rétractation est applicable à un contrat conclu à distance, ses conditions et ses modalités sont communiquées avant la validation. Des règles particulières peuvent s'appliquer à une prestation de loisirs prévue à une date déterminée. Toute décision et tout remboursement sont conservés dans l'historique du dossier."],
      ["Avis, messages et contenus", "Les avis et messages doivent rester respectueux, exacts et pertinents. Tout contenu injurieux, discriminatoire, trompeur, illicite ou contenant des données personnelles inutiles peut être signalé, modéré ou retiré. Une demande de réexamen peut être adressée à Ultimate DJ."],
      ["Propriété intellectuelle et musique", "Les contenus, visuels, documents, marques et éléments de l'interface sont protégés. Les playlists sont des suggestions de titres et d'artistes : Ultimate DJ ne met aucun fichier musical protégé à disposition. Le DJ et l'organisateur de l'événement doivent respecter les licences et autorisations applicables à la diffusion musicale."],
      ["Responsabilité et droit applicable", "Les informations publiées sont maintenues avec soin. Ultimate DJ ne peut toutefois garantir l'absence totale d'erreur, d'indisponibilité temporaire ou d'interruption technique. Les présentes informations sont interprétées conformément au droit belge et aux règles européennes applicables."],
    ],
    privacy: [
      ["Gestion des données et contact", "Ultimate DJ traite les données nécessaires au fonctionnement de la plateforme. Pour toute question relative à vos données personnelles ou pour exercer vos droits, utilisez les coordonnées ci-dessous.", "business"],
      ["Données traitées et finalités", "Selon votre utilisation du service, nous traitons vos coordonnées, les informations liées à votre événement, vos messages, préférences musicales, documents contractuels, factures, données de suivi de paiement et journaux de sécurité. Ces données servent à répondre à une demande, préparer et exécuter un contrat, organiser une prestation, gérer les paiements, prévenir la fraude et assurer la sécurité du service."],
      ["Destinataires et prestataires", "Les données sont accessibles uniquement au client, au DJ concerné et aux administrateurs autorisés, selon leur rôle. Stripe traite les paiements ; l'hébergeur et le prestataire d'e-mail peuvent traiter les seules données nécessaires à leurs services. Ces prestataires appliquent leurs propres règles de confidentialité."],
      ["Durée de conservation", "Un compte sans dossier actif est désactivé ou anonymisé après une suppression autorisée. Les devis non aboutis sont conservés pendant 12 mois. Les contrats, factures et preuves de paiement sont archivés au moins 7 ans lorsque la loi l'exige. Les messages, avis et journaux de sécurité sont conservés seulement pendant la durée nécessaire à leur finalité, à la sécurité ou à la preuve d'un litige."],
      ["Cookies, stockage local et Stripe", "L'application utilise le stockage local du navigateur pour le choix de langue et l'authentification. Aucun outil publicitaire ou statistique non nécessaire n'est activé actuellement. Si de tels outils sont ajoutés, votre consentement sera demandé avant leur activation. Stripe peut utiliser ses propres cookies ou technologies similaires durant le paiement afin de sécuriser la transaction."],
      ["Vos droits et réclamations", "Vous pouvez demander l'accès à vos données, leur rectification, leur effacement lorsque cela est possible, la limitation du traitement, la portabilité ou vous opposer à certains usages. Contactez-nous d'abord afin que nous puissions examiner votre demande. Vous pouvez également introduire une réclamation auprès de l'Autorité de protection des données."],
      ["Sécurité et incidents", "Les accès sont protégés par authentification et contrôle des autorisations. En cas de violation de données, Ultimate DJ applique une procédure de détection, de correction, d'évaluation du risque et, lorsque requis, de notification à l'Autorité de protection des données et aux personnes concernées."],
    ],
  },
  en: {
    legal: [
      ["Service publisher and role", "Ultimate DJ is a platform that connects clients and DJs and manages music entertainment services. It centralises quotes, contracts, bookings, preparatory appointments, payments and exchanges. The selected DJ performs the service; Ultimate DJ manages the administrative and technical follow-up of the booking."],
      ["Contact details", "For questions about the service, a booking or your data, you can use the details below.", "business"],
      ["Bookings, payments and invoicing", "Before any payment, the booking displays the service, date, price, deposit, balance and related documents. Ultimate DJ never stores card data: it is processed by Stripe. The contract and booking documents set out the arrangements that apply to the booking and payment."],
      ["Withdrawal, cancellation and refunds", "The documents linked to a booking set out cancellation and refund arrangements. When a right of withdrawal applies to a distance contract, its conditions and process are communicated before confirmation. Specific rules may apply to leisure services scheduled for a specific date. Each decision and refund is recorded in the booking history."],
      ["Reviews, messages and content", "Reviews and messages must remain respectful, accurate and relevant. Content that is abusive, discriminatory, misleading, unlawful or contains unnecessary personal data may be reported, moderated or removed. A review request may be sent to Ultimate DJ."],
      ["Intellectual property and music", "Content, visuals, documents, brands and interface elements are protected. Playlists are song and artist suggestions only: Ultimate DJ does not provide protected music files. The DJ and event organiser must comply with licences and permissions applicable to music broadcasting."],
      ["Liability and applicable law", "Published information is maintained with care. Ultimate DJ cannot, however, guarantee the complete absence of errors, temporary unavailability or technical interruptions. These notices are interpreted in accordance with Belgian law and applicable European rules."],
    ],
    privacy: [
      ["Data management and contact", "Ultimate DJ processes the data needed to operate the platform. For questions about personal data or to exercise your rights, use the details below.", "business"],
      ["Data processed and purposes", "Depending on how you use the service, we process contact details, event information, messages, music preferences, contractual documents, invoices, payment follow-up data and security logs. This data is used to handle requests, prepare and perform contracts, organise services, manage payments, prevent fraud and secure the service."],
      ["Recipients and service providers", "Data is available only to the client, the relevant DJ and authorised administrators, according to their role. Stripe processes payments; the hosting and email providers may process only the data required for their services. These providers apply their own privacy rules."],
      ["Retention periods", "An account without an active booking is deactivated or anonymised after an approved deletion. Unsuccessful quotes are kept for 12 months. Contracts, invoices and payment evidence are archived for at least 7 years where required by law. Messages, reviews and security logs are retained only for as long as needed for their purpose, security or evidence in a dispute."],
      ["Cookies, local storage and Stripe", "The application uses browser local storage for language selection and authentication. No non-essential advertising or analytics tool is currently enabled. If such tools are added, your consent will be requested before they are activated. Stripe may use its own cookies or similar technologies during payment to secure the transaction."],
      ["Your rights and complaints", "You may request access to, correction or erasure of your data where possible, restriction of processing, portability, or object to certain uses. Please contact us first so that we can review your request. You may also lodge a complaint with the Belgian Data Protection Authority."],
      ["Security and incidents", "Access is protected by authentication and permission controls. In the event of a personal-data breach, Ultimate DJ applies a procedure for detection, correction and risk assessment and, where required, notifies the Belgian Data Protection Authority and affected individuals."],
    ],
  },
  nl: {
    legal: [
      ["Uitgever en rol van de dienst", "Ultimate DJ is een platform voor het in contact brengen van klanten en DJ's en voor het beheer van muzikale animatieprestaties. Het centraliseert offertes, contracten, reservaties, voorbereidende afspraken, betalingen en berichten. De gekozen DJ voert de prestatie uit; Ultimate DJ beheert de administratieve en technische opvolging van het dossier."],
      ["Contactgegevens", "Voor vragen over de dienst, een dossier of uw gegevens kunt u onderstaande gegevens gebruiken.", "business"],
      ["Reservaties, betalingen en facturatie", "Voor elke betaling toont het dossier de prestatie, datum, prijs, voorschot, saldo en documenten. Ultimate DJ bewaart nooit kaartgegevens: Stripe verwerkt deze. Het contract en de dossierdocumenten bepalen de regels voor de reservatie en betaling."],
      ["Herroeping, annulering en terugbetaling", "De documenten bij een reservatie bepalen de regels voor annulering en terugbetaling. Wanneer een herroepingsrecht geldt voor een overeenkomst op afstand, worden de voorwaarden en de procedure vóór de bevestiging meegedeeld. Voor vrijetijdsdiensten op een specifieke datum kunnen bijzondere regels gelden. Elke beslissing en terugbetaling wordt in de dossierhistoriek bewaard."],
      ["Beoordelingen, berichten en inhoud", "Beoordelingen en berichten moeten respectvol, correct en relevant blijven. Beledigende, discriminerende, misleidende, onwettige inhoud of inhoud met onnodige persoonsgegevens kan worden gemeld, gemodereerd of verwijderd. Een verzoek tot herziening kan aan Ultimate DJ worden gericht."],
      ["Intellectuele eigendom en muziek", "Inhoud, beelden, documenten, merken en interface-elementen zijn beschermd. Afspeellijsten zijn alleen suggesties van titels en artiesten: Ultimate DJ stelt geen beschermde muziekbestanden ter beschikking. De DJ en de organisator moeten de licenties en toestemmingen voor muziekweergave naleven."],
      ["Aansprakelijkheid en toepasselijk recht", "De gepubliceerde informatie wordt zorgvuldig bijgehouden. Ultimate DJ kan echter niet garanderen dat er nooit fouten, tijdelijke onbeschikbaarheid of technische onderbrekingen zijn. Deze vermeldingen worden geïnterpreteerd volgens het Belgische recht en de toepasselijke Europese regels."],
    ],
    privacy: [
      ["Gegevensbeheer en contact", "Ultimate DJ verwerkt gegevens die nodig zijn voor de werking van het platform. Gebruik onderstaande gegevens voor vragen over persoonsgegevens of om uw rechten uit te oefenen.", "business"],
      ["Verwerkte gegevens en doeleinden", "Afhankelijk van uw gebruik verwerken wij contactgegevens, evenementinformatie, berichten, muziekvoorkeuren, contractuele documenten, facturen, betalingsopvolging en beveiligingslogs. Deze gegevens worden gebruikt om aanvragen te behandelen, contracten voor te bereiden en uit te voeren, prestaties te organiseren, betalingen te beheren, fraude te voorkomen en de dienst te beveiligen."],
      ["Ontvangers en dienstverleners", "Gegevens zijn alleen beschikbaar voor de klant, de betrokken DJ en bevoegde beheerders, volgens hun rol. Stripe verwerkt betalingen; hosting- en e-mailproviders kunnen alleen de voor hun dienst nodige gegevens verwerken. Deze dienstverleners hanteren hun eigen privacyregels."],
      ["Bewaartermijnen", "Een account zonder actief dossier wordt na een goedgekeurde verwijdering gedeactiveerd of geanonimiseerd. Niet-geslaagde offertes worden 12 maanden bewaard. Contracten, facturen en betalingsbewijzen worden minstens 7 jaar gearchiveerd wanneer de wet dit vereist. Berichten, beoordelingen en beveiligingslogs blijven alleen bewaard zolang dit nodig is voor hun doel, veiligheid of bewijs in een geschil."],
      ["Cookies, lokale opslag en Stripe", "De toepassing gebruikt lokale opslag in de browser voor de taalkeuze en authenticatie. Er is momenteel geen niet-noodzakelijke advertentie- of analysetool actief. Als zulke tools worden toegevoegd, wordt uw toestemming gevraagd vóór activering. Stripe kan tijdens de betaling eigen cookies of soortgelijke technologieën gebruiken om de transactie te beveiligen."],
      ["Uw rechten en klachten", "U kunt inzage, correctie of verwijdering van uw gegevens vragen waar mogelijk, verwerking beperken, gegevensoverdraagbaarheid vragen of bezwaar maken tegen bepaalde gebruiken. Neem eerst contact met ons op zodat wij uw verzoek kunnen onderzoeken. U kunt ook een klacht indienen bij de Belgische Gegevensbeschermingsautoriteit."],
      ["Beveiliging en incidenten", "Toegang wordt beschermd door authenticatie en rechtenbeheer. Bij een datalek hanteert Ultimate DJ een procedure voor detectie, correctie en risicoanalyse en, wanneer vereist, voor melding aan de Belgische Gegevensbeschermingsautoriteit en de betrokken personen."],
    ],
  },
};

export default function LegalPage({ type }) {
  const { t, i18n } = useTranslation();
  const business = usePublicBusiness();
  const key = type === "privacy" ? "privacy" : "legal";
  const language = i18n.language.startsWith("nl") ? "nl" : i18n.language.startsWith("en") ? "en" : "fr";
  const labels = language === "nl"
    ? { address: "Adres", email: "E-mail", phone: "Telefoon", company: "Ondernemingsnummer", vat: "Btw-nummer" }
    : language === "en"
      ? { address: "Address", email: "Email", phone: "Phone", company: "Company number", vat: "VAT number" }
      : { address: "Adresse", email: "E-mail", phone: "Téléphone", company: "Numéro d'entreprise", vat: "Numéro de TVA" };
  const details = [
    business.address && { label: labels.address, value: business.address },
    business.company_number && { label: labels.company, value: business.company_number },
    business.vat_number && { label: labels.vat, value: business.vat_number },
    business.email && { label: labels.email, value: business.email, href: `mailto:${business.email}` },
    business.phone && { label: labels.phone, value: business.phone, href: `tel:${business.phone.replace(/\s/g, "")}` },
  ].filter(Boolean);

  return (
    <section className="section-wrap legal-page">
      <p className="eyebrow dark">{business.legal_name || "Ultimate DJ"}</p>
      <h1>{t(`legalPages.${key}.title`)}</h1>
      {content[language][key].map(([heading, text, extra]) => (
        <article key={heading}>
          <h2>{heading}</h2>
          <p>{text}</p>
          {extra === "business" && details.length > 0 && (
            <dl className="legal-contact-details">
              {details.map((detail) => <div key={detail.label}><dt>{detail.label}</dt><dd>{detail.href ? <a href={detail.href}>{detail.value}</a> : detail.value}</dd></div>)}
            </dl>
          )}
        </article>
      ))}
    </section>
  );
}
