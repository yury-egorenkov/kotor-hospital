import yaml from 'js-yaml';

export const locales = ['cnr', 'en', 'ru', 'uk', 'tr', 'de', 'es', 'fr'] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = 'cnr';

// Vite-native eager import of all .yaml files as raw text
const yamlFiles = import.meta.glob('./*.yaml', { eager: true, query: '?raw', import: 'default' });

const translations: Record<string, Record<string, string>> = {};
for (const loc of locales) {
  const raw = yamlFiles[`./${loc}.yaml`];
  if (typeof raw === 'string') {
    translations[loc] = yaml.load(raw) as Record<string, string>;
  } else {
    translations[loc] = {};
  }
}

export const localeLabels: Record<Locale, string> = {
  cnr: 'ME',
  en: 'EN',
  ru: 'RU',
  uk: 'UA',
  tr: 'TR',
  de: 'DE',
  es: 'ES',
  fr: 'FR',
};

export const localeFlags: Record<Locale, string> = {
  cnr: '🇲🇪',
  en: '🇬🇧',
  ru: '🇷🇺',
  uk: '🇺🇦',
  tr: '🇹🇷',
  de: '🇩🇪',
  es: '🇪🇸',
  fr: '🇫🇷',
};

export function t(lang: string, key: string): string {
  return translations[lang]?.[key] ?? translations[defaultLocale]?.[key] ?? key;
}

export function getLangFromUrl(url: URL): Locale {
  const [, lang] = url.pathname.split('/');
  if (lang && locales.includes(lang as Locale)) {
    return lang as Locale;
  }
  return defaultLocale;
}

export function getLocalePath(lang: string, path: string = '/'): string {
  if (lang === defaultLocale) return path;
  return `/${lang}${path}`;
}

export function getAlternateLinks(currentPath: string = '/'): { lang: Locale; href: string }[] {
  return locales.map((lang) => ({
    lang,
    href: getLocalePath(lang, currentPath),
  }));
}
