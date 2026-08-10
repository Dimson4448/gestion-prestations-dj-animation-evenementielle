import { Children, cloneElement, isValidElement } from "react";
import { useTranslation } from "react-i18next";

const translatedProps = ["aria-label", "placeholder", "title"];

const preserveSpacing = (value, translated) => {
  const leading = value.match(/^\s*/)?.[0] || "";
  const trailing = value.match(/\s*$/)?.[0] || "";
  return `${leading}${translated}${trailing}`;
};

export default function LocalizedContent({ children }) {
  const { t, i18n } = useTranslation("interface");

  const translateNode = (node) => {
    if (typeof node === "string") {
      const key = node.trim();
      if (!key || !i18n.exists(key, { ns: "interface" })) return node;
      return preserveSpacing(node, t(key));
    }
    if (!isValidElement(node)) return node;

    const nextProps = {};
    translatedProps.forEach((prop) => {
      const value = node.props[prop];
      if (typeof value === "string" && i18n.exists(value, { ns: "interface" })) nextProps[prop] = t(value);
    });
    if (node.props.children !== undefined) {
      nextProps.children = Children.map(node.props.children, translateNode);
    }
    return cloneElement(node, nextProps);
  };

  return Children.map(children, translateNode);
}
