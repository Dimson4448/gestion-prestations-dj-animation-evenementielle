import { CreditCard, FileText, Music2, Sparkles } from "lucide-react";
import { useTranslation } from "react-i18next";

const benefitItems = [
  { icon: FileText, key: "documents" },
  { icon: CreditCard, key: "payments" },
  { icon: Music2, key: "playlist" },
  { icon: Sparkles, key: "review" },
];

export default function AccountBenefits() {
  const { t } = useTranslation();

  return (
    <aside className="account-benefits">
      <p className="eyebrow">{t("authentication.guidance.eyebrow")}</p>
      <h2>{t("authentication.guidance.title")}</h2>

      {benefitItems.map(({ icon: Icon, key }) => (
        <div key={key}>
          <Icon />
          <span>{t(`authentication.guidance.${key}`)}</span>
        </div>
      ))}
    </aside>
  );
}
